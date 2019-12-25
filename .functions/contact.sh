#!/bin/sh

contact() {
  : "${CONTACTS_DIR:?'CONTACTS_DIR ENV Var not set'}"
  if [ -d "${CONTACTS_DIR}" ]; then
    if [ $# -eq 0 ]; then
      file=$(ls --color=never -1 "${CONTACTS_DIR}" | \
        fzf \
        --multi \
        --select-1 \
        --exit-0 \
        --preview="cat ${CONTACTS_DIR}/{}" \
        --preview-window=right:70%:wrap)
      [ -n $file ] && ${EDITOR:-vim} "${CONTACTS_DIR}/${file}"
    else
      case "$1" in
        "-d")
          rm "${CONTACTS_DIR}"/"$2"
          ;;
        *)
          ${EDITOR:-vim} "${CONTACTS_DIR}"/"$*"
          ;;
      esac
    fi
  fi
}
