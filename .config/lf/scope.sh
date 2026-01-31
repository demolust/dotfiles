#!/usr/bin/bash

set -x
set -o noclobber -o noglob -o nounset -o pipefail
IFS=$'\n'

## Script orginally taken from `ranger`

## If the option `set previewer` is set to point to this script,
## then this script will be called and its output will be displayed in lf.
## ANSI color codes are supported.
## STDIN is disabled, so interactive scripts won't work properly

## This script is considered a configuration file and must be updated manually.
## It will be left untouched if you upgrade lf.

## Because of some automated testing we do on the script #'s for comments need
## to be doubled up. Code that is commented out, because it's an alternative for
## example, gets only one #.

## Script arguments
FILE_PATH="${1}" # Full path of the highlighted file
PV_WIDTH="${2}"  # Width of the preview pane (number of fitting characters)
## shellcheck disable=SC2034 # PV_HEIGHT is provided for convenience and unused
PV_HEIGHT="${3}" # Height of the preview pane (number of fitting characters)
PV_POS_X="${4}"
PV_POS_Y="${5}"
IMAGE_CACHE_PATH="${6}"
PV_IMAGE_ENABLED="${7}" ## 'True' if image previews are enabled, 'False' otherwise.

FILE_EXTENSION="${FILE_PATH##*.}"
FILE_EXTENSION_LOWER="$(printf "%s" "${FILE_EXTENSION}" | tr '[:upper:]' '[:lower:]')"

## Settings
#HIGHLIGHT_SIZE_MAX=262143 ## 256KiB
HIGHLIGHT_SIZE_MAX=1048576 ## 1MB
HIGHLIGHT_TABWIDTH=${HIGHLIGHT_TABWIDTH:-8}
HIGHLIGHT_STYLE=${HIGHLIGHT_STYLE:-pablo}
HIGHLIGHT_OPTIONS="--replace-tabs=${HIGHLIGHT_TABWIDTH} --style=${HIGHLIGHT_STYLE} ${HIGHLIGHT_OPTIONS:-}"
PYGMENTIZE_STYLE=${PYGMENTIZE_STYLE:-autumn}
OPENSCAD_IMGSIZE=${RNGR_OPENSCAD_IMGSIZE:-1000,1000}
OPENSCAD_COLORSCHEME=${RNGR_OPENSCAD_COLORSCHEME:-Tomorrow Night}

draw() {
  FILE_PATH="$(readlink -f -- "$1" | sed 's/\\/\\\\/g;s/"/\\"/g')"
  printf '{"action":"add","identifier":"preview","x":%d,"y":%d,"width":%d,"height":%d,"scaler":"contain","scaling_position_x":0.5,"scaling_position_y":0.5,"path":"%s"}\n' \
    "${PV_POS_X}" "${PV_POS_Y}" "${PV_WIDTH}" "${PV_HEIGHT}" "${FILE_PATH}" > "$FIFO_UEBERZUG"
  ## This is to signal lf not to cache the result of the previewer script
  exit 1
}

create_file_hash() {
  FILE_PV_CACHE="${IMAGE_CACHE_PATH}/$(stat --printf '%n\0%i\0%F\0%s\0%W\0%Y' -- "$(readlink -f -- "$1")" | sha256sum | cut -d' ' -f1).jpg"
}

create_cache() {
  if ! [ -f "${FILE_PV_CACHE}" ]; then
    ## Use the specific command to create the cache file
    "$@"
  fi
  ## Displays the file to lf
  draw "${FILE_PV_CACHE}"
}

handle_extension() {
  case "${FILE_EXTENSION_LOWER}" in
  ## Archive
  a | ace | alz | arc | arj | bz | bz2 | cab | cpio | deb | gz | jar | lha | lz | \
    lzh | lzma | lzo | rpm | rz | t7z | tar | tbz | tbz2 | tgz | tlz | txz | tZ | \
    tzo | war | xpi | xz | Z | zip)
    atool --list -- "${FILE_PATH}" && exit 0
    bsdtar --list --file "${FILE_PATH}" && exit 0
    tar vvtf "${FILE_PATH}" && exit 0
    exit 0
    ;;
  rar)
    ## Avoid password prompt by providing empty password
    unrar l -p- -- "${FILE_PATH}" | grep -A 200 'Attributes' | awk '{out = ""; for (i = 5; i <= NF; i++) {out = out " " $i}; print $2" "$3" "out}' | column --table && exit 0
    exit 0
    ;;
  7z)
    ## Avoid password prompt by providing empty password
    7z l -p -- "${FILE_PATH}" && exit 0
    exit 0
    ;;

  ## PDF
  pdf)
    ## Preview as text conversion
    pdftotext -l 10 -nopgbrk -q -- "${FILE_PATH}" - |
      fmt -w "${PV_WIDTH}" && exit 0
    mutool draw -F txt -i -- "${FILE_PATH}" 1-10 |
      fmt -w "${PV_WIDTH}" && exit 0
    exiftool "${FILE_PATH}" | tr -s '  ' | fmt -s && exit 0
    exit 0
    ;;

  ## BitTorrent
  torrent)
    transmission-show -- "${FILE_PATH}" && exit 0
    exit 0
    ;;

  ## OpenDocument
  odt | ods | odp | sxw)
    ## Preview as text conversion
    odt2txt "${FILE_PATH}" && exit 0
    ## Preview as markdown conversion
    pandoc -s -t markdown -- "${FILE_PATH}" && exit 0
    exit 0
    ;;

  ## XLSX
  xlsx)
    ## Preview as csv conversion
    ## Uses: https://github.com/dilshod/xlsx2csv
    xlsx2csv -- "${FILE_PATH}" && exit 0
    exit 0
    ;;

  pptx)
    while IFS= read -r SUBFILE; do
        unzip -p -- "${FILE_PATH}" "${SUBFILE}" | grep -oP '(?<=\<a:t\>).*?(?=\</a:t\>)'
    done < <(unzip -Z1 -- "${FILE_PATH}" | grep ppt/slides/slide | sort -V) && exit 0
    exit 0
    ;;

  ppt)
    catppt -- "${FILE_PATH}" && exit 0
    exit 0
    ;;

  ## HTML
  htm | html | xhtml)
    ## Preview as text conversion
    w3m -dump "${FILE_PATH}" && exit 0
    lynx -dump -- "${FILE_PATH}" && exit 0
    elinks -dump "${FILE_PATH}" && exit 0
    pandoc -s -t markdown -- "${FILE_PATH}" && exit 0
    ;;

  ## JSON
  json)
    jq --color-output . "${FILE_PATH}" && exit 0
    python -m json.tool -- "${FILE_PATH}" && exit 0
    ;;

  ## Direct Stream Digital/Transfer (DSDIFF) and wavpack aren't detected
  ## by file(1).
  dff | dsf | wv | wvc)
    mediainfo "${FILE_PATH}" | tr -s '  ' | fmt -s && exit 0
    exiftool "${FILE_PATH}" | tr -s '  ' | fmt -s && exit 0
    ;; # Continue with next handler on failure

  ## doc
  doc)
    catdoc -- "${FILE_PATH}" && exit 0
    exit 0
    ;;

  iso)
    iso-info --no-header -l "${FILE_PATH}" && exit 0
    ;;

  esac
}

handle_image() {
  ## Size of the preview if there are multiple options or it has to be
  ## rendered from vector graphics. If the conversion program allows
  ## specifying only one dimension while keeping the aspect ratio, the width
  ## will be used.
  local DEFAULT_SIZE="600x400"
  local mimetype="${1}"
  case "${mimetype}" in
  ## SVG
  #image/svg+xml | image/svg)
  #  convert -- "${FILE_PATH}" "${IMAGE_CACHE_PATH}" && exit 0
  #  exit 0
  #  ;;

  ## DjVu
  #image/vnd.djvu)
  #  ddjvu -format=tiff -quality=90 -page=1 -size="${DEFAULT_SIZE}" \
  #    - "${IMAGE_CACHE_PATH}" <"${FILE_PATH}" &&
  #    exit 0
  #  ;;

  ## CSV image preview
  text/plain | text/csv)
    ## Special check: Only convert if the extension is .csv
    if [[ "${FILE_EXTENSION_LOWER}" == csv ]]; then
      if [ -p "$FIFO_UEBERZUG" ]; then
        ## Create the pdf and rename it to avoid confusion
        !  [[ -d "${IMAGE_CACHE_PATH}/docs" ]] && mkdir -p "${IMAGE_CACHE_PATH}/docs"
        FILENAME="$(basename "${FILE_PATH}")"
        BASE_FILENAME="${FILENAME%.*}"
        PDF_FILENAME="${BASE_FILENAME}.pdf"
        CACHE_FILE="${IMAGE_CACHE_PATH}/docs/${PDF_FILENAME}"
        if ! [ -f "${CACHE_FILE}" ]; then
        unoconvert_firstpage_pdf "${FILE_PATH}" "${CACHE_FILE}"
        #unoconvert_firstpage_pdf -i "${FILE_PATH}" -o "${CACHE_FILE}"
        #unoconvert --filter-options PageRange=1 -- "${FILE_PATH}" "${CACHE_FILE}"
        #soffice --headless "-env:UserInstallation=file:///tmp/LibreOffice_Conversion_${USER}" --convert-to 'pdf:calc_pdf_Export:{"PageRange":{"type":"string","value":"1"}}' --outdir "${IMAGE_CACHE_PATH}/docs" "${FILENAME}"
        fi
        create_file_hash "${FILE_PATH}"
        create_cache pdftoppm -f 1 -l 1 \
          -scale-to-x "${DEFAULT_SIZE%x*}" \
          -scale-to-y -1 \
          -singlefile \
          -jpeg -tiffcompression jpeg \
          -- "${CACHE_FILE}" "${FILE_PV_CACHE%.*}"
      fi
      exit 0
    else
      handle_extension
    fi
  ;;

  ## Word Processing / Text Documents
  application/vnd.openxmlformats-officedocument.wordprocessingml.document|\
  application/vnd.oasis.opendocument.text|\
  application/msword)
    if [ -p "$FIFO_UEBERZUG" ]; then
      ## Create the pdf and rename it to avoid confusion
      !  [[ -d "${IMAGE_CACHE_PATH}/docs" ]] && mkdir -p "${IMAGE_CACHE_PATH}/docs"
      FILENAME="$(basename "${FILE_PATH}")"
      BASE_FILENAME="${FILENAME%.*}"
      PDF_FILENAME="${BASE_FILENAME}.pdf"
      CACHE_FILE="${IMAGE_CACHE_PATH}/docs/${PDF_FILENAME}"
      if ! [ -f "${CACHE_FILE}" ]; then
        unoconvert_firstpage_pdf "${FILE_PATH}" "${CACHE_FILE}"
        #unoconvert_firstpage_pdf -i "${FILE_PATH}" -o "${CACHE_FILE}"
        #unoconvert --filter-options PageRange=1 -- "${FILE_PATH}" "${CACHE_FILE}"
        #soffice --headless "-env:UserInstallation=file:///tmp/LibreOffice_Conversion_${USER}" --convert-to 'pdf:writer_pdf_Export:{"PageRange":{"type":"string","value":"1"}}' --outdir "${IMAGE_CACHE_PATH}/docs" "${FILENAME}"

      fi
      create_file_hash "${FILE_PATH}"
      create_cache pdftoppm -f 1 -l 1 \
        -scale-to-x "${DEFAULT_SIZE%x*}" \
        -scale-to-y -1 \
        -singlefile \
        -jpeg -tiffcompression jpeg \
        -- "${CACHE_FILE}" "${FILE_PV_CACHE%.*}"
    fi
    exit 0
  ;;

  ##  Spreadsheet Documents
  application/vnd.oasis.opendocument.spreadsheet|\
  application/vnd.openxmlformats-officedocument.spreadsheetml.sheet|\
  application/vnd.ms-excel)
    if [ -p "$FIFO_UEBERZUG" ]; then
      ## Create the pdf and rename it to avoid confusion
      !  [[ -d "${IMAGE_CACHE_PATH}/docs" ]] && mkdir -p "${IMAGE_CACHE_PATH}/docs"
      FILENAME="$(basename "${FILE_PATH}")"
      BASE_FILENAME="${FILENAME%.*}"
      PDF_FILENAME="${BASE_FILENAME}.pdf"
      CACHE_FILE="${IMAGE_CACHE_PATH}/docs/${PDF_FILENAME}"
      if ! [ -f "${CACHE_FILE}" ]; then
        unoconvert_firstpage_pdf "${FILE_PATH}" "${CACHE_FILE}"
        #unoconvert_firstpage_pdf -i "${FILE_PATH}" -o "${CACHE_FILE}"
        #unoconvert --filter-options PageRange=1 -- "${FILE_PATH}" "${CACHE_FILE}"
        #soffice --headless "-env:UserInstallation=file:///tmp/LibreOffice_Conversion_${USER}" --convert-to 'pdf:calc_pdf_Export:{"PageRange":{"type":"string","value":"1"}}' --outdir "${IMAGE_CACHE_PATH}/docs" "${FILENAME}"
      fi
      create_file_hash "${FILE_PATH}"
      create_cache pdftoppm -f 1 -l 1 \
        -scale-to-x "${DEFAULT_SIZE%x*}" \
        -scale-to-y -1 \
        -singlefile \
        -jpeg -tiffcompression jpeg \
        -- "${CACHE_FILE}" "${FILE_PV_CACHE%.*}"
    fi
    exit 0
  ;;

  ## Presentation Documents
  application/vnd.oasis.opendocument.presentation|\
  application/vnd.openxmlformats-officedocument.presentationml.presentation|\
  application/vnd.ms-powerpoint)
    if [ -p "$FIFO_UEBERZUG" ]; then
      ## Create the pdf and rename it to avoid confusion
      !  [[ -d "${IMAGE_CACHE_PATH}/docs" ]] && mkdir -p "${IMAGE_CACHE_PATH}/docs"
      FILENAME="$(basename "${FILE_PATH}")"
      BASE_FILENAME="${FILENAME%.*}"
      PDF_FILENAME="${BASE_FILENAME}.pdf"
      CACHE_FILE="${IMAGE_CACHE_PATH}/docs/${PDF_FILENAME}"
      if ! [ -f "${CACHE_FILE}" ]; then
        unoconvert_firstpage_pdf "${FILE_PATH}" "${CACHE_FILE}"
        #unoconvert_firstpage_pdf -i "${FILE_PATH}" -o "${CACHE_FILE}"
        #unoconvert --filter-options PageRange=1 -- "${FILE_PATH}" "${CACHE_FILE}"
        #soffice --headless "-env:UserInstallation=file:///tmp/LibreOffice_Conversion_${USER}" --convert-to 'pdf:draw_pdf_Export:{"PageRange":{"type":"string","value":"1"}}' --outdir "${IMAGE_CACHE_PATH}/docs" "${FILENAME}"
      fi
      create_file_hash "${FILE_PATH}"
      create_cache pdftoppm -f 1 -l 1 \
        -scale-to-x "${DEFAULT_SIZE%x*}" \
        -scale-to-y -1 \
        -singlefile \
        -jpeg -tiffcompression jpeg \
        -- "${CACHE_FILE}" "${FILE_PV_CACHE%.*}"
    fi
    exit 0
  ;;

  image/gif)
    if [ -p "$FIFO_UEBERZUG" ]; then
      ## Create the thumbnail at orginal size and rename it to avoid confusion
      create_file_hash "${FILE_PATH}"
      TEMP_IMG="${FILE_PV_CACHE}"
      if ! [ -f "${TEMP_IMG}" ]; then
        ffmpegthumbnailer -i "${FILE_PATH}" -o "${TEMP_IMG}" -s 0
      fi
      ## Re-scale the image down to an acceptable size to be shown as preview
      create_file_hash "${TEMP_IMG}"
      create_cache magick -- "${TEMP_IMG}" -thumbnail "${DEFAULT_SIZE}" "${FILE_PV_CACHE}"
    fi
    exit 0
    ;;

  ## Image
  image/*)
    if [ -p "$FIFO_UEBERZUG" ]; then
      ## ueberzug doesn't handle image orientation correctly
      local UNSHARP=0x.5
      orientation="$(identify -format '%[orientation]\n' -- "${FILE_PATH}")"
      if [ -n "$orientation" ] &&
        [ "$orientation" != Undefined ] &&
        [ "$orientation" != TopLeft ]; then
        create_file_hash "${FILE_PATH}"
        create_cache magick -- "${FILE_PATH}" -thumbnail "${DEFAULT_SIZE}" -unsharp "${UNSHARP}" -auto-orient "${FILE_PV_CACHE}"
      else
        create_file_hash "${FILE_PATH}"
        create_cache magick -- "${FILE_PATH}" -thumbnail "${DEFAULT_SIZE}" -unsharp "${UNSHARP}" "${FILE_PV_CACHE}"
      fi
    fi
    exit 0
    ;;

  ## Video
  video/*)
    if [ -p "$FIFO_UEBERZUG" ]; then
      ## Create the thumbnail at orginal size and rename it to avoid confusion
      create_file_hash "${FILE_PATH}"
      TEMP_IMG="${FILE_PV_CACHE}"
      if ! [ -f "${TEMP_IMG}" ]; then
        ffmpegthumbnailer -i "${FILE_PATH}" -o "${TEMP_IMG}" -s 0
      fi
      ## Re-scale the image down to an acceptable size to be shown as preview
      create_file_hash "${TEMP_IMG}"
      create_cache magick -- "${TEMP_IMG}" -thumbnail "${DEFAULT_SIZE}" "${FILE_PV_CACHE}"
    fi
    exit 0
    ;;

  ## PDF
  application/pdf)
    if [ -p "$FIFO_UEBERZUG" ]; then
      create_file_hash "${FILE_PATH}"
      create_cache pdftoppm -f 1 -l 1 \
        -scale-to-x "${DEFAULT_SIZE%x*}" \
        -scale-to-y -1 \
        -singlefile \
        -jpeg -tiffcompression jpeg \
        -- "${FILE_PATH}" "${FILE_PV_CACHE%.*}"
    fi
    exit 0
    ;;

  ## ePub, MOBI, FB2 (using Calibre)
  application/epub+zip | application/x-mobipocket-ebook | \
    application/x-fictionbook+xml)
    if [ -p "$FIFO_UEBERZUG" ]; then
      create_file_hash "${FILE_PATH}"
      ## So far no need to use the `-s "${DEFAULT_SIZE%x*}"` flag as it resizes both axis
      create_cache gnome-epub-thumbnailer "${FILE_PATH}" "${FILE_PV_CACHE}"
    fi
    exit 0
    ;;

  ## Font
  application/font* | application/*opentype | font/*)
    create_file_hash "${FILE_PATH}"
    FILE_PV_CACHE_2=${FILE_PV_CACHE/'jpg'/'png'}
    if fontimage -o "${FILE_PV_CACHE_2}" \
      --pixelsize "120" \
      --fontname \
      --pixelsize "80" \
      --text "  ABCDEFGHIJKLMNOPQRSTUVWXYZ  " \
      --text "  abcdefghijklmnopqrstuvwxyz  " \
      --text "  0123456789.:,;(*!?') ff fl fi ffi ffl  " \
      --text "  The quick brown fox jumps over the lazy dog.  " \
      "${FILE_PATH}"; then
      create_cache magick -- "${FILE_PV_CACHE_2}" -thumbnail "${DEFAULT_SIZE}" "${FILE_PV_CACHE}"
    else
      handle_fallback
    fi
    ;;

  ## Preview archives using the first image inside.
  # (Very useful for comic book collections for example.)
  #application/zip | application/x-rar | application/x-7z-compressed | \
  #  application/x-xz | application/x-bzip2 | application/x-gzip | application/x-tar)
  #  local fn=""
  #  local fe=""
  #  local zip=""
  #  local rar=""
  #  local tar=""
  #  local bsd=""
  #  case "${mimetype}" in
  #  application/zip) zip=1 ;;
  #  application/x-rar) rar=1 ;;
  #  application/x-7z-compressed) ;;
  #  *) tar=1 ;;
  #  esac
  #  { [ "$tar" ] && fn=$(tar --list --file "${FILE_PATH}"); } ||
  #    { fn=$(bsdtar --list --file "${FILE_PATH}") && bsd=1 && tar=""; } ||
  #    { [ "$rar" ] && fn=$(unrar lb -p- -- "${FILE_PATH}"); } ||
  #    { [ "$zip" ] && fn=$(zipinfo -1 -- "${FILE_PATH}"); } || return

  #  fn=$(echo "$fn" | python -c "import sys; import mimetypes as m; \
  #               [ print(l, end='') for l in sys.stdin if \
  #                 (m.guess_type(l[:-1])[0] or '').startswith('image/') ]" |
  #    sort -V | head -n 1)
  #  [ "$fn" = "" ] && return
  #  [ "$bsd" ] && fn=$(printf '%b' "$fn")

  #  [ "$tar" ] && tar --extract --to-stdout \
  #    --file "${FILE_PATH}" -- "$fn" >"${IMAGE_CACHE_PATH}" && exit 0
  #  fe=$(echo -n "$fn" | sed 's/[][*?\]/\\\0/g')
  #  [ "$bsd" ] && bsdtar --extract --to-stdout \
  #    --file "${FILE_PATH}" -- "$fe" >"${IMAGE_CACHE_PATH}" && exit 0
  #  [ "$bsd" ] || [ "$tar" ] && rm -- "${IMAGE_CACHE_PATH}"
  #  [ "$rar" ] && unrar p -p- -inul -- "${FILE_PATH}" "$fn" > \
  #    "${IMAGE_CACHE_PATH}" && exit 0
  #  [ "$zip" ] && unzip -pP "" -- "${FILE_PATH}" "$fe" > \
  #    "${IMAGE_CACHE_PATH}" && exit 0
  #  [ "$rar" ] || [ "$zip" ] && rm -- "${IMAGE_CACHE_PATH}"
  #  ;;
  esac

  #openscad_image() {
  #  TMPPNG="$(mktemp -t XXXXXX.png)"
  #  openscad --colorscheme="${OPENSCAD_COLORSCHEME}" \
  #    --imgsize="${OPENSCAD_IMGSIZE/x/,}" \
  #    -o "${TMPPNG}" "${1}"
  #  mv "${TMPPNG}" "${IMAGE_CACHE_PATH}"
  #}

  #case "${FILE_EXTENSION_LOWER}" in
  ## 3D models
  ## OpenSCAD only supports png image output, and ${IMAGE_CACHE_PATH}
  ## is hardcoded as jpeg. So we make a tempfile.png and just
  ## move/rename it to jpg. This works because image libraries are
  ## smart enough to handle it.
  #csg | scad)
  #  openscad_image "${FILE_PATH}" && exit 0
  #  ;;
  #3mf | amf | dxf | off | stl)
  #  openscad_image <(echo "import(\"${FILE_PATH}\");") && exit 0
  #  ;;
  #esac
}

handle_mime() {
  local mimetype="${1}"
  case "${mimetype}" in
  ## RTF and DOC
  text/rtf | *msword)
    ## Preview as text conversion
    ## note: catdoc does not always work for .doc files
    ## catdoc: http://www.wagner.pp.ru/~vitus/software/catdoc/
    catdoc -- "${FILE_PATH}" && exit 0
    exit 0
    ;;

  ## DOCX, ePub, FB2 (using markdown)
  ## You might want to remove "|epub" and/or "|fb2" below if you have
  ## uncommented other methods to preview those formats
  *wordprocessingml.document | */epub+zip | */x-fictionbook+xml)
    ## Preview as markdown conversion
    pandoc -s -t markdown -- "${FILE_PATH}" && exit 0
    exit 0
    ;;

  ## XLS
  *ms-excel)
    ## Preview as csv conversion
    ## xls2csv comes with catdoc:
    ##   http://www.wagner.pp.ru/~vitus/software/catdoc/
    xls2csv -- "${FILE_PATH}" && exit 0
    exit 0
    ;;

  ## Text
  text/* | */xml | application/javascript)
    ## Syntax highlight
    if [[ "$(tput colors)" -ge 256 ]]; then
      local pygmentize_format='terminal256'
      local highlight_format='xterm256'
    else
      local pygmentize_format='terminal'
      local highlight_format='ansi'
    fi
    env COLORTERM=8bit bat --color=always --style="plain" \
      -- "${FILE_PATH}" | head -n "$(tput lines)" && exit 0
    pygmentize -f "${pygmentize_format}" -O "style=${PYGMENTIZE_STYLE}" \
      -- "${FILE_PATH}" | head -n "$(tput lines)" && exit 0
    env HIGHLIGHT_OPTIONS="${HIGHLIGHT_OPTIONS}" highlight \
      --out-format="${highlight_format}" \
      --force -- "${FILE_PATH}" | head -n "$(tput lines)" && exit 0
    exit 0
    ;;

  ## DjVu
  image/vnd.djvu)
    ## Preview as text conversion (requires djvulibre)
    djvutxt "${FILE_PATH}" | fmt -w "${PV_WIDTH}" && exit 0
    exiftool "${FILE_PATH}" | tr -s '  ' | fmt -s && exit 0
    exit 0
    ;;

  ## Image
  image/*)
    ## Preview as text conversion
    #img2txt --gamma=0.6 --width="${PV_WIDTH}" -- "${FILE_PATH}" && exit 0
    exiftool "${FILE_PATH}" | tr -s '  ' | fmt -s && exit 0
    exit 0
    ;;

  ## Video and audio
  video/* | audio/*)
    mediainfo "${FILE_PATH}" | tr -s '  ' | fmt -s && exit 0
    exiftool "${FILE_PATH}" | tr -s '  ' | fmt -s && exit 0
    exit 0
    ;;

  ## JSON
  application/json)
    jq --color-output . "${FILE_PATH}" && exit 0
    python -m json.tool -- "${FILE_PATH}" && exit 0
    exit 0
    ;;

  esac
}

handle_fallback() {
  echo '----- File Type Classification -----' && file --dereference --brief -- "${FILE_PATH}" && exit 0
  exit 0
}

MIMETYPE="$(file --dereference --brief --mime-type -- "${FILE_PATH}")"
if [[ "${PV_IMAGE_ENABLED}" == true ]]; then
  handle_image "${MIMETYPE}"
fi
handle_extension
handle_mime "${MIMETYPE}"
handle_fallback

exit 0
