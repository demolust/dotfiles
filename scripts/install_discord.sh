#! /bin/bash

set -e

echo "Discord must no be installed by any other method or this will crash with the system package database"
echo "This script requieres root/sudo"
echo "Continue??[y/n]"
read -r Continue
response=$(echo "${Continue}" | tr '[:upper:]' '[:lower:]')
if [[ ${response} == "n"* ]]; then
	exit 1
fi

### To gather sudo privilages
sudo true

echo "Stoping all possible running instances of Discord"
if pgrep Discord ; then
	sudo pkill Discord || echo finished
	sleep 1
	sudo pkill -9 Discord || echo finished
fi

base_dir_path="/opt"
desktop_files_path="/usr/share/applications"
bin_dir="/usr/bin"

bash_script_path=$(readlink -f "$(dirname "$0")")
tmp_dir=$(mktemp -d)
current_date=$(date +'%Y_%m_%d_%R:%S')

discord_tar_url="https://discord.com/api/download?platform=linux&format=tar.gz"

discord_file_name="discord_${current_date}.tgz"
discord_tar_path="${tmp_dir}/${discord_file_name}"

discord_path="${base_dir_path}/Discord"
discord_post_install_path="${discord_path}/postinst.sh"
discord_icon_path="${discord_path}/discord.png"
discord_desktop_path="${discord_path}/discord.desktop"
discord_bin_path="${discord_path}/Discord"
discord_final_bin_path="${bin_dir}/Discord"

echo "Downloading latest tar from discord.com and storing it as ${discord_tar_path}"
wget -nv "${discord_tar_url}" -O "${discord_tar_path}"

if [ -d "${discord_path}" ]; then
  sudo find "${base_dir_path}" -name "Discord_*" -type d -mtime +1 -exec rm -rf {} \; || true
	backup_dir="${discord_path}_${current_date}"
	echo "Creating a backup of the previous install as ${backup_dir}"
	sudo mv "${discord_path}" "${backup_dir}"
fi

echo "Decompresing tar file ${discord_tar_path} to ${base_dir_path}"
sudo tar -xvzf "${discord_tar_path}" -C "${base_dir_path}"

echo "Creating a symlink of ${discord_bin_path} to ${discord_final_bin_path}"
sudo ln -sf "${discord_bin_path}" "${discord_final_bin_path}"

sudo sed -i "s:Icon=.*:Icon=${discord_icon_path}:g" "${discord_desktop_path}"
sudo sed -i "s:Exec=.*:Exec=${discord_final_bin_path}:g" "${discord_desktop_path}"
echo "Creating the Desktop File from ${discord_desktop_path} to ${desktop_files_path}"
sudo cp -rvf "${discord_desktop_path}" "${desktop_files_path}"

echo "Deleting original tar files"
rm -rvf "${tmp_dir}"

echo "Executing discord postinstall script"
echo "${discord_post_install_path}"
sudo "${discord_post_install_path}"

