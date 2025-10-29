#!/usr/bin/env python3
import sys, os, json, re, base64, argparse, urllib.request, urllib.parse, time
import sqlite3, shutil, tempfile, configparser

AUDIO_CT_HINTS = (
    "audio/mpeg",
    "audio/mp3",
    "audio/mp2",
    "audio/mpeg3",
    "video/mpeg",
    "application/octet-stream",
    "application/vnd.apple.mpegurl",  # m3u8
    "application/dash+xml",          # mpd
)
MANIFEST_RE = re.compile(r'\.(m3u8|mpd)(\?|$)', re.I)
MEDIA_RE = re.compile(r'\.(mp3|mpeg|m3u8|mpd)(\?|$)', re.I)
SAFE_NAME_RE = re.compile(r"[^A-Za-z0-9._-]+")

KEEP_REQ_HEADERS = {"cookie","authorization","user-agent","referer","origin"}

DEFAULT_UA = "Mozilla/5.0 (X11; Linux x86_64; rv:115.0) Gecko/20100101 Firefox/115.0"

def safe_name(s: str) -> str:
    s = s.strip().strip(".")
    s = SAFE_NAME_RE.sub("_", s)
    return s[:140] or "media"

def ext_for(mime: str, url: str) -> str:
    mime = (mime or "").lower()
    u = (url or "").lower()
    if mime.startswith("audio/mpeg") or ".mp3" in u:
        return ".mp3"
    if "mpeg" in mime or u.endswith(".mpeg"):
        return ".mpeg"
    if MANIFEST_RE.search(u) or "mpegurl" in mime or "dash+xml" in mime:
        return ".txt"
    return ".bin"

def headers_list_to_dict(hlist):
    return {(h.get("name") or "").lower(): h.get("value") for h in (hlist or [])}

def is_media_candidate(url, mime, resp_headers):
    mime_l = (mime or "").lower()
    url_l = (url or "").lower()
    if MEDIA_RE.search(url_l):
        return True
    ct = (resp_headers.get("content-type") or "").lower()
    if any(h in mime_l for h in AUDIO_CT_HINTS): return True
    if any(h in ct for h in AUDIO_CT_HINTS): return True
    return False

def content_range_total(resp_headers):
    cr = (resp_headers.get("content-range") or "").strip()
    m = re.match(r"^bytes\s+\d+-\d+/(\d+|\*)$", cr, re.I)
    if not m:
        return None
    return None if m.group(1) == "*" else int(m.group(1))

def pick_media_entries(har_entries):
    out = []
    for e in har_entries:
        req = e.get("request", {}) or {}
        resp = e.get("response", {}) or {}
        url = req.get("url") or ""
        mime = (resp.get("content", {}) or {}).get("mimeType") or ""
        resp_headers = headers_list_to_dict(resp.get("headers"))
        if is_media_candidate(url, mime, resp_headers):
            out.append(e)
    return out

def body_bytes_from_entry(e):
    content = (e.get("response", {}) or {}).get("content") or {}
    text = content.get("text")
    if not text:
        return None
    try:
        if content.get("encoding") == "base64":
            return base64.b64decode(text)
        return text.encode("latin1", errors="ignore")
    except Exception:
        return None

def carry_req_headers(e):
    h = headers_list_to_dict((e.get("request", {}) or {}).get("headers"))
    out = {}
    for k in KEEP_REQ_HEADERS:
        if k in h and h[k]:
            if k == "referer":
                out["Referer"] = h[k]
            elif k == "user-agent":
                out["User-Agent"] = h[k]
            elif k == "origin":
                out["Origin"] = h[k]
            else:
                out[k.capitalize() if k=="cookie" else k] = h[k]
    return out

# LibreWolf cookie helpers

def librewolf_profiles_root():
    env = os.environ.get("LW_PROFILE_DIR")
    if env and os.path.isdir(env):
        return env
    candidates = [
        os.path.expanduser("~/.librewolf"),
        os.path.expanduser("~/.mozilla/librewolf"),
        os.path.expanduser("~/.var/app/io.gitlab.librewolf-community/.librewolf"),
    ]
    for p in candidates:
        if os.path.isdir(p):
            return p
    return None

def find_default_profile_path():
    root = librewolf_profiles_root()
    if not root:
        return None
    ini = os.path.join(root, "profiles.ini")
    if not os.path.exists(ini):
        return None
    cfg = configparser.RawConfigParser()
    cfg.read(ini)
    chosen = None
    for section in cfg.sections():
        if not section.startswith("Profile"):
            continue
        if cfg.get(section, "Default", fallback="0") == "1":
            chosen = section
            break
    if not chosen:
        for section in cfg.sections():
            if section.startswith("Profile"):
                chosen = section
                break
    if not chosen:
        return None
    path = cfg.get(chosen, "Path", fallback="")
    is_rel = cfg.get(chosen, "IsRelative", fallback="1") == "1"
    return os.path.join(root, path) if is_rel else path

def domain_variants(host):
    parts = (host or "").split(".")
    out = set()
    for i in range(len(parts)-1):
        d = "." + ".".join(parts[i:])
        out.add(d)
        out.add(d.lstrip("."))
    out.add(host or "")
    return out

def get_librewolf_cookie_header_for(url):
    prof = find_default_profile_path()
    if not prof:
        return None
    db_path = os.path.join(prof, "cookies.sqlite")
    if not os.path.exists(db_path):
        return None
    with tempfile.TemporaryDirectory() as td:
        tmpdb = os.path.join(td, "cookies.sqlite")
        shutil.copy2(db_path, tmpdb)
        conn = sqlite3.connect(tmpdb)
        try:
            cur = conn.cursor()
            u = urllib.parse.urlparse(url)
            host = u.hostname or ""
            path = u.path or "/"
            is_secure = 1 if u.scheme == "https" else 0
            like_domains = tuple(sorted(domain_variants(host)))
            if not like_domains:
                return None
            qmarks = ",".join(["?"]*len(like_domains))
            sql = f"""
            SELECT name, value, host, path, isSecure, expiry
            FROM moz_cookies
            WHERE host IN ({qmarks})
              AND (? LIKE path || '%' OR path = '/')
              AND (isSecure = 0 OR isSecure = ?)
            """
            params = like_domains + (path, is_secure)
            cur.execute(sql, params)
            jar = {}
            for name, value, host, cpath, secure, expiry in cur.fetchall():
                jar[name] = value
            if not jar:
                return None
            return "; ".join(f"{k}={v}" for k, v in jar.items())
        finally:
            conn.close()

# HTTP helpers

def open_with_headers(url, headers, timeout=30):
    req = urllib.request.Request(url, headers=headers)
    return urllib.request.urlopen(req, timeout=timeout)

def ranged_download(url, base_headers, out_path, start_at=0, chunk_size=1024*1024, max_tries=5):
    written = 0
    pos = start_at
    tries = 0
    with open(out_path, "ab") as f:
        while True:
            rng_header = f"bytes={pos}-{pos + chunk_size - 1}"
            h = dict(base_headers)
            h["Range"] = rng_header
            try:
                with open_with_headers(url, h) as resp:
                    status = getattr(resp, "status", resp.getcode())
                    data = resp.read()
                if not data:
                    break
                f.write(data)
                written += len(data)
                pos += len(data)
                time.sleep(0.05)
                if status == 200 and len(data) < chunk_size:
                    break
                if len(data) < chunk_size:
                    break
                tries = 0
            except Exception:
                tries += 1
                if tries >= max_tries:
                    break
                time.sleep(0.2 * tries)
    return written

def merge_cookie_sources(url, har_headers):
    # prefer HAR Cookie if present, else live LibreWolf cookie
    ck = har_headers.get("Cookie") or har_headers.get("cookie")
    if ck and ck.strip():
        return ck
    live = get_librewolf_cookie_header_for(url)
    return live

def out_name_for(url, mime, idx):
    parsed = urllib.parse.urlparse(url or "")
    base = os.path.basename(parsed.path) or f"media_{idx}"
    base = base.split("?")[0]
    base = safe_name(base)
    if "." not in base:
        base += ext_for(mime, url)
    return base

def list_entries(entries):
    rows = []
    for i, e in enumerate(entries):
        url = e.get("request", {}).get("url", "")
        resp = e.get("response", {})
        mime = (resp.get("content", {}) or {}).get("mimeType", "")
        status = resp.get("status")
        size = (resp.get("content", {}) or {}).get("size", 0)
        rows.append((i, status, mime or "-", url))
    return rows

def print_yt_dlp_suggestion(url, har_headers):
    # Assemble yt-dlp with live cookies if needed
    ck = merge_cookie_sources(url, har_headers)
    ua = har_headers.get("User-Agent") or DEFAULT_UA
    ref = har_headers.get("Referer")
    parts = ["yt-dlp"]
    if ck:
        parts += ["--add-header", f"Cookie: {ck}"]
    if ua:
        parts += ["--add-header", f"User-Agent: {ua}"]
    if ref:
        parts += ["--add-header", f"Referer: {ref}"]
    parts += [url, "-o", "%(title)s.%(ext)s"]
    print("Detected HLS or DASH manifest. Use this:")
    print(" ".join(parts))

def download_from_entry(e, out_dir, chunk_size):
    req = e.get("request", {}) or {}
    resp = e.get("response", {}) or {}
    url = req.get("url") or ""
    mime = (resp.get("content", {}) or {}).get("mimeType") or ""
    resp_headers = headers_list_to_dict(resp.get("headers"))
    req_headers = carry_req_headers(e)

    if MANIFEST_RE.search(url):
        print_yt_dlp_suggestion(url, req_headers)
        return None

    os.makedirs(out_dir, exist_ok=True)
    base = out_name_for(url, mime, 0)
    out_path = os.path.join(out_dir, base)

    seeded = 0
    body = body_bytes_from_entry(e)
    if body:
        with open(out_path, "wb") as f:
            f.write(body)
        seeded = len(body)
        print(f"Seeded {base} with {seeded} bytes from HAR.")

    # Build headers for network requests
    headers = dict(req_headers)
    headers.setdefault("User-Agent", DEFAULT_UA)
    ck = merge_cookie_sources(url, headers)
    if ck:
        headers["Cookie"] = ck

    # If no seed, try starting at 0 without Range
    if not seeded:
        try:
            with open_with_headers(url, headers) as r0:
                data0 = r0.read()
            with open(out_path, "wb") as f:
                f.write(data0)
            seeded = len(data0)
            print(f"Fetched initial chunk, {seeded} bytes.")
        except Exception as ex:
            print(f"Initial fetch failed, {ex}")
            return None

    total_hint = content_range_total(resp_headers)
    need_more = True if not total_hint or seeded < total_hint else False
    if seeded in (1024*1024, 1024*1024 - 1, 1024*1024 + 1):
        need_more = True

    if need_more:
        got = ranged_download(url, headers, out_path, start_at=seeded, chunk_size=chunk_size)
        if got > 0:
            print(f"Extended by {got} bytes. Final size {seeded + got} bytes.")
        else:
            print("Server did not allow more range reads, file may be partial.")

    return out_path

def main():
    ap = argparse.ArgumentParser(description="Extract or fetch media from a HAR with HAR headers and LibreWolf cookies.")
    ap.add_argument("har", help="Path to HAR file")
    ap.add_argument("-o", "--out", help="Output directory", default="har_media_out")
    ap.add_argument("-i", "--index", type=int, help="Media entry index to download")
    ap.add_argument("-l", "--list", action="store_true", help="List media candidates")
    ap.add_argument("-c", "--chunk", type=int, default=1024*1024, help="Range chunk size in bytes")
    args = ap.parse_args()

    with open(args.har, "rb") as f:
        har = json.load(f)
    entries = (har.get("log") or {}).get("entries") or []

    media = pick_media_entries(entries)
    if not media:
        print("No media entries found.")
        sys.exit(2)

    if args.list or args.index is None:
        print("Media candidates:")
        for i, (idx, status, mime, url) in enumerate(list_entries(media)):
            print(f"[{i}] {status} {mime}  {url}")
        if args.list and args.index is None:
            return

    idx = args.index if args.index is not None else 0
    if idx < 0 or idx >= len(media):
        print(f"Index {idx} out of range. Use --list to see entries.")
        sys.exit(3)

    out_path = download_from_entry(media[idx], args.out, args.chunk)
    if out_path:
        print(f"Done. Saved to: {out_path}")
    else:
        print("No file saved. See notes above for yt-dlp or errors.")

if __name__ == "__main__":
    main()
