local msg = require 'mp.msg'
local utils = require 'mp.utils'

local options = {
    username = "",
    password = "",
    apikey = "",
    secret = "",
    scrobble_threshold = 240,
    scrobble_percentage = 0.5,
    enable_radio = true,
    enable_local = true,
    parse_patterns = true,
}
require "mp.options".read_options(options, "mpvscrobble")

-- ============================================================================
-- Helpers
-- ============================================================================
local function first_nonempty(...)
    for i = 1, select("#", ...) do
        local v = select(i, ...)
        if v and v ~= "" then return v end
    end
    return nil
end

local function normalize_icy(s)
    if not s then return s end

    -- trim
    s = s:match("^%s*(.-)%s*$")

    -- normalize common dash-like Unicode to ASCII '-'
    -- NOTE: If you prefer not to include Unicode em dash in your file, you can remove that line.
    s = s:gsub("–", "-")
         :gsub("—", "-")
         :gsub("−", "-")
         :gsub("﹣", "-")
         :gsub("－", "-")

    -- normalize colon spacing
    s = s:gsub("%s*:%s*", ": ")

    -- strip common suffixes
    s = s:gsub("%s+on%s+[^%-]+$", "")
         :gsub("%s+%-+%s+[^%-]+$", "")

    -- collapse whitespace
    s = s:gsub("%s+", " ")

    return s
end

local function parse_icy_title(icy_title)
    if not icy_title or icy_title == "" then
        return nil
    end

    icy_title = normalize_icy(icy_title)
    msg.debug("Parsing ICY: " .. icy_title)

    local title, artist

    -- "Title by Artist"
    title, artist = icy_title:match("^(.+)%s+by%s+(.+)$")
    if title and artist then
        return {
            artist = artist:match("^%s*(.-)%s*$"),
            title = title:match("^%s*(.-)%s*$")
        }
    end

    -- "Artist - Title" (split on first dash group)
    artist, title = icy_title:match("^(.-)%s*%-%s*(.+)$")
    if artist and title and artist ~= "" and title ~= "" then
        return {
            artist = artist:match("^%s*(.-)%s*$"),
            title = title:match("^%s*(.-)%s*$")
        }
    end

    -- "Artist: Title"
    artist, title = icy_title:match("^(.-)%s*:%s*(.+)$")
    if artist and title and artist ~= "" and title ~= "" then
        return {
            artist = artist:match("^%s*(.-)%s*$"),
            title = title:match("^%s*(.-)%s*$")
        }
    end

    return nil
end

-- ============================================================================
-- Session Cache Management
-- ============================================================================
local function get_session_cache_path()
    local cache_base = os.getenv("HOME") .. "/.cache"
    local cache_dir = cache_base .. "/mpv"
    os.execute("mkdir -p " .. cache_dir)
    return cache_dir .. "/mpvscrobble.session"
end

local function load_cached_session()
    local path = get_session_cache_path()
    local file = io.open(path, "r")

    if file then
        local session_key = file:read("*all")
        file:close()

        if session_key and session_key ~= "" then
            session_key = session_key:gsub("^%s*(.-)%s*$", "%1")
            msg.info("[*] Loaded cached session key")
            return session_key
        end
    end

    return nil
end

local function save_session(session_key)
    local path = get_session_cache_path()
    local file = io.open(path, "w")

    if file then
        file:write(session_key)
        file:close()
        msg.verbose("[*] Session key cached to: " .. path)
        return true
    else
        msg.warn("[!] Failed to cache session key")
        return false
    end
end

local function clear_cached_session()
    local path = get_session_cache_path()
    os.remove(path)
    msg.info("[*] Cleared cached session")
end

-- ============================================================================
-- MD5 Implementation (via md5sum subprocess)
-- ============================================================================
local function md5_sum(str)
    local cmd = "md5sum"

    local result = mp.command_native({
        name = "subprocess",
        playback_only = false,
        capture_stdout = true,
        stdin_data = str,
        args = {cmd}
    })

    if result.status == 0 then
        local hash = result.stdout:match("^(%x+)")
        return hash
    end

    msg.error("[!] Failed to compute MD5 hash")
    return nil
end

-- ============================================================================
-- HTTP Request using mpv subprocess + curl
-- ============================================================================
local function http_post(url, body)
    local result = mp.command_native({
        name = "subprocess",
        playback_only = false,
        capture_stdout = true,
        capture_stderr = true,
        args = {
            "curl",
            "-s",
            "-X", "POST",
            "-H", "Content-Type: application/x-www-form-urlencoded",
            "-H", "User-Agent: mpvscrobbler/1.0",
            "-d", body,
            url
        }
    })

    if result.status ~= 0 then
        msg.error("[!] HTTP request failed: " .. (result.stderr or "unknown error"))
        return nil
    end

    return result.stdout
end

-- ============================================================================
-- URL Encode
-- ============================================================================
local function url_encode(str)
    if str then
        str = string.gsub(str, "\n", "\r\n")
        str = string.gsub(str, "([^%w%-%.%_%~ ])",
            function(c) return string.format("%%%02X", string.byte(c)) end)
        str = string.gsub(str, " ", "+")
    end
    return str
end

local function dict_to_query(params)
    local parts = {}
    for k, v in pairs(params) do
        table.insert(parts, url_encode(k) .. "=" .. url_encode(v))
    end
    return table.concat(parts, "&")
end

-- ============================================================================
-- Last.fm API
-- ============================================================================
local LastFM = {
    apikey = options.apikey,
    secret = options.secret,
    base_url = "https://ws.audioscrobbler.com/2.0/",
    session = nil,
    username = nil,
    password = nil,
}
LastFM.__index = LastFM

function LastFM:new(o)
    o = o or {}
    setmetatable(o, self)
    return o
end

local function toapistring(v)
    if type(v) == "boolean" then
        return v and "1" or "0"
    end
    return tostring(v)
end

function LastFM:request(endpoint, params)
    params = params or {}
    params.api_key = self.apikey
    params.format = "json"
    params.method = endpoint

    if not self.session and endpoint ~= "auth.getMobileSession" then
        self:getMobileSession()
    end

    if self.session then
        params.sk = self.session
    end

    for k, v in pairs(params) do
        if v ~= nil then
            params[k] = toapistring(v)
        end
    end

    local sorted = {}
    for k in pairs(params) do
        if k ~= "format" then
            table.insert(sorted, k)
        end
    end
    table.sort(sorted)

    local tosign = ""
    for _, k in ipairs(sorted) do
        tosign = tosign .. k .. params[k]
    end

    local signature = md5_sum(tosign .. self.secret)
    if not signature then
        error("[!] Failed to create API signature")
    end
    params.api_sig = signature

    local body = dict_to_query(params)
    msg.debug("POST " .. endpoint)

    local response = http_post(self.base_url, body)
    if not response then
        error("[!] HTTP request failed")
    end

    local data = utils.parse_json(response)
    if not data then
        error("[!] Failed to parse JSON response")
    end

    if data.error then
        if data.error == 9 then
            msg.warn("[!] Session expired, re-authenticating...")
            clear_cached_session()
            self.session = nil

            if endpoint ~= "auth.getMobileSession" then
                return self:request(endpoint, params)
            end
        end
        error("[!] Last.fm API error " .. data.error .. ": " .. (data.message or "Unknown error"))
    end

    return data
end

function LastFM:getMobileSession()
    msg.verbose("[/] Authenticating with Last.fm")
    local res = self:request("auth.getMobileSession", {
        username = self.username,
        password = self.password,
    })

    if res.session and res.session.key then
        self.session = res.session.key
        save_session(self.session)
        msg.info("[*] Successfully authenticated as: " .. self.username)
    else
        error("[!] Failed to retrieve session key")
    end
end

function LastFM:now_playing(info)
    local params = {
        artist = info.artist,
        track = info.title,
    }

    if info.album then params.album = info.album end
    if info.album_artist then params.albumArtist = info.album_artist end
    if info.track_number then params.trackNumber = info.track_number end
    if info.duration then params.duration = math.floor(info.duration) end

    self:request("track.updateNowPlaying", params)
end

function LastFM:scrobble(info)
    local params = {
        ["artist[0]"] = info.artist,
        ["track[0]"] = info.title,
        ["timestamp[0]"] = info.start_time,
    }

    if info.album then params["album[0]"] = info.album end
    if info.album_artist then params["albumArtist[0]"] = info.album_artist end
    if info.track_number then params["trackNumber[0]"] = info.track_number end
    if info.duration then params["duration[0]"] = math.floor(info.duration) end
    if info.chosen ~= nil then params["chosenByUser[0]"] = info.chosen end

    self:request("track.scrobble", params)
end

-- ============================================================================
-- Tracker
-- ============================================================================
local Tracker = {
    lastfm = nil,
    playing = nil,
    scrobbled = false,
    duration = nil,
}
Tracker.__index = Tracker

function Tracker:new(o)
    o = o or {}
    setmetatable(o, self)
    return o
end

function Tracker:start(arg)
    local playing = {
        artist = arg.artist,
        title = arg.title,
        album = arg.album,
        album_artist = arg.album_artist,
        track_number = arg.track_number,
        duration = arg.duration,
        start_time = tonumber(arg.start_time) or os.time(),
        chosen = true,
    }

    local track_changed = not self.playing or (
        self.playing.artist ~= playing.artist
        or self.playing.title ~= playing.title
        or self.playing.album ~= playing.album
    )

    if track_changed then
        if self.playing and self.scrobbled then
            local success, err = pcall(function()
                self.lastfm:scrobble(self.playing)
            end)
            if success then
                msg.info('[✓] Scrobbled: "' .. self.playing.title .. '" by ' .. self.playing.artist)
            else
                msg.error("[!] Failed to scrobble: " .. tostring(err))
            end
        end

        self.playing = playing
        self.scrobbled = false
        self.duration = playing.duration

        local success, err = pcall(function()
            self.lastfm:now_playing(playing)
        end)
        if success then
            msg.info('[♫ ] Now playing: "' .. playing.title .. '" by ' .. playing.artist)
        else
            msg.error("[!] Failed to update now playing: " .. tostring(err))
        end
    end
end

function Tracker:update_position(position)
    if not self.playing or self.scrobbled then
        return
    end

    local should_scrobble = false

    if position >= options.scrobble_threshold then
        should_scrobble = true
    end

    if self.duration and position >= (self.duration * options.scrobble_percentage) then
        should_scrobble = true
    end

    if should_scrobble then
        self.scrobbled = true
        msg.verbose("[-] Track eligible for scrobbling (played " .. math.floor(position) .. "s)")
    end
end

function Tracker:stop()
    if self.playing and self.scrobbled then
        local success, err = pcall(function()
            self.lastfm:scrobble(self.playing)
        end)
        if success then
            msg.info('[✓] Scrobbled: "' .. self.playing.title .. '" by ' .. self.playing.artist)
        else
            msg.error("[!] Failed to scrobble on stop: " .. tostring(err))
        end
    end
    self.playing = nil
    self.scrobbled = false
    self.duration = nil
end

-- ============================================================================
-- Metadata plumbing
-- ============================================================================
local tracker = nil
local current_track = nil
local is_radio = false

local function get_file_metadata()
    local metadata = mp.get_property_native("metadata")
    if not metadata then return nil end

    local artist = metadata.artist or metadata.ARTIST or metadata.album_artist or metadata.ALBUM_ARTIST
    local title = metadata.title or metadata.TITLE
    local album = metadata.album or metadata.ALBUM

    if artist and title then
        return {
            artist = artist,
            title = title,
            album = album,
            album_artist = metadata.album_artist or metadata.ALBUM_ARTIST,
            track_number = metadata.track or metadata.TRACK,
        }
    end
    return nil
end

local function check_if_radio()
    local path = mp.get_property("path")
    return path and (path:match("^https?://") or path:match("^icy://"))
end

local function start_new_track(info)
    if not info or not info.artist or not info.title then
        return
    end

    current_track = info

    if not is_radio then
        info.duration = mp.get_property_number("duration")
    end

    tracker:start(info)
end

local function on_metadata_change()
    if not is_radio or not options.enable_radio then return end

    local metadata = mp.get_property_native("metadata")
    if not metadata then return end

    -- Prefer ICY keys first for radio
    local icy_title  = first_nonempty(metadata["icy-title"], metadata["ICY-TITLE"], metadata.icy_title)
    local icy_artist = first_nonempty(metadata["icy-artist"], metadata["ICY-ARTIST"], metadata.icy_artist)

    local title  = first_nonempty(icy_title, metadata.title, metadata.TITLE)
    local artist = first_nonempty(icy_artist, metadata.artist, metadata.ARTIST, metadata.album_artist, metadata.ALBUM_ARTIST)

    local parsed = nil

    if icy_artist and title then
        parsed = {
            artist = icy_artist:match("^%s*(.-)%s*$"),
            title  = title:match("^%s*(.-)%s*$")
        }
        msg.debug("Using ICY artist + title: " .. parsed.artist .. " | " .. parsed.title)
    elseif title and options.parse_patterns then
        parsed = parse_icy_title(title)
        if parsed then
            msg.debug("Parsed from ICY title: " .. parsed.artist .. " | " .. parsed.title)
        end
    elseif artist and title then
        parsed = {
            artist = artist:match("^%s*(.-)%s*$"),
            title  = title:match("^%s*(.-)%s*$")
        }
        msg.debug("Using generic artist + title: " .. parsed.artist .. " | " .. parsed.title)
    end

    if not parsed and title then
        local t = normalize_icy(title)
        parsed = { artist = "Unknown Artist", title = t }
        msg.debug("Using raw title only: " .. t)
    end

    if not parsed then
        msg.debug("No usable metadata in stream")
        return
    end

    if not current_track or current_track.title ~= parsed.title or current_track.artist ~= parsed.artist then
        start_new_track(parsed)
    end
end

local function on_track_change()
    if is_radio or not options.enable_local then return end

    local metadata = get_file_metadata()
    if metadata then
        if not current_track or current_track.title ~= metadata.title or current_track.artist ~= metadata.artist then
            start_new_track(metadata)
        end
    end
end

local function on_time_update()
    if current_track then
        local position = mp.get_property_number("time-pos")
        if position then
            tracker:update_position(position)
        end
    end
end

local function on_end_file()
    if current_track then
        tracker:stop()
        current_track = nil
    end
end

local function on_file_loaded()
    is_radio = check_if_radio()
    current_track = nil

    if is_radio then
        msg.info("[+] Radio stream detected")
        on_metadata_change()
    else
        msg.info("[+] Local file detected")
        on_track_change()
    end
end

-- ============================================================================
-- Initialize
-- ============================================================================
if options.username == "" or options.password == "" then
    msg.error("=== Last.fm credentials not configured! ===")
    msg.error("Create ~/.config/mpv/script-opts/mpvscrobble.conf with:")
    msg.error("username=your_username")
    msg.error("password=your_password")
    msg.error(string.rep("=", 43))
else
    local lastfm = LastFM:new({
        username = options.username,
        password = options.password,
    })

    local cached_session = load_cached_session()
    if cached_session then
        lastfm.session = cached_session
    end

    tracker = Tracker:new({ lastfm = lastfm })

    msg.info("[*] Last.fm scrobbler initialized for: " .. options.username)

    mp.observe_property("metadata", "native", on_metadata_change)
    mp.observe_property("time-pos", "number", on_time_update)
    mp.register_event("file-loaded", on_file_loaded)
    mp.register_event("end-file", on_end_file)
    mp.observe_property("playlist-pos", "number", on_track_change)
end
