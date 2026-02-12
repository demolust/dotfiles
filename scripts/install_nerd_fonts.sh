#! /bin/bash

#https://ostechnix.com/install-nerd-fonts-to-add-glyphs-in-your-code-on-linux/
#https://wiki.archlinux.org/title/XDG_Base_Directory
#https://unix.stackexchange.com/questions/57658/how-to-utilize-xdg-directories-and-paths-in-bash
#https://help.gnome.org/admin/system-admin-guide/stable/fonts-user.html.en
# This script will install fonts to 'XDG_DATA_HOME/fonts' typically translated to '~/.local/share/fonts'

set -euo pipefail

bash_script_path=$(readlink -f "$(dirname "$0")")
current_date=$(date +'%Y-%m-%d')
tmp_dir=$(mktemp -d)

XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
dest_fonts_path="${XDG_DATA_HOME}/fonts"

[[ -d "${dest_fonts_path}" ]] ||mkdir -p "${dest_fonts_path}"
printf "Directory in which the fonts will be installed %s\n" "${dest_fonts_path}"

fonts_to_be_installed=( LiberationMono Hermit )
repo="ryanoasis/nerd-fonts"

for font in "${fonts_to_be_installed[@]}"; do
  printf "Downloading and installing %s\n" "${font}"
  font_tar_name="${font}.tar.xz"
  tmp_font_dir="${tmp_dir}/${font}"
  tmp_font_tar_filename="${tmp_dir}/${font_tar_name}"
  font_url=$(curl -s "https://api.github.com/repos/${repo}/releases/latest" | \
               jq -r ".assets[] | select(.name == \"$font_tar_name\") | .browser_download_url")
  printf "Fonts will be downloaded from %s\n" "${font_url}"
  if [[ -z "${font_url}" ]]; then
    printf "Error: Could not find download URL for %s\n" "$font" >&2
    continue
  fi
  mkdir -p "${tmp_font_dir}"
  wget -q "${font_url}" -O "${tmp_font_tar_filename}"
  tar -xvf "${tmp_font_tar_filename}" -C "${tmp_font_dir}"
done

rsync -havzP "${tmp_dir}/" "${dest_fonts_path}" --exclude="*.tar.xz"
fc-cache -fv "${dest_fonts_path}"

printf "Cleanup of temporal files\n"
rm -rvf "${tmp_dir}"
