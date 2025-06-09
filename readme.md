# Programs & Configurations

For all the programs that are installed from a language package manager or that are needed to be manually compiled will start to look into a hosting local Jenkins instance to be able to build them and deposit the binary to a local artifactory repo, this to avoid need to compile for every machine were they are used, and then create a bash script to gather only the latest updated software, so that these binaries can be installed on `~/.local/bin/`

The second option is to create a bash script that gets all the latest Github releases and then installs them to `~/.local/bin/`

## Fedora systems (Fedora 41)

As of Feb 2025 on Fedora 41

- fzf is from the official Fedora repos or if is outdated then compiled from the git repo
- alacritty is from the official Fedora repos or if is outdated compiled from the git repo
- neovim is from the official Fedora repos or if is outdated then compiled from the git repo
- tmux is from the official Fedora repos or if is outdated then compiled from the git repo
- bat is from the official Fedora repos or if is outdated then installed from cargo
- git-delta is from the official Fedora repos or if is outdated then installed from cargo
- eza is from the official Fedora repos or if is outdated then installed from cargo
- fd-find is from the official Fedora repos or if is outdated then installed from cargo
- ripgrep is from the official Fedora repos or if is outdated then installed from cargo
- sd is from the official Fedora repos or if is outdated then installed from cargo
- zoxide is from the official Fedora repos or if is outdated then installed from cargo
- procs is from the official Fedora repos or if is outdated then installed from cargo
- uv is from the official Fedora repos or from pip since it's a binary
- python3-pygments is from the official Fedora repo
- thefuck is installed from the official Fedora repos or from uv
- tldr python wrapper is from the official Feoda repo or if is outdated then installed from uv

- zsh is from the official Fedora repos
- dotnet, rust/cargo, nodejs/npm, python/pip, golang are from the official Fedora repos
- podman is from the official Fedora repos
- ranger is from the official Fedora repos
- pwsh is from the Microsoft repo
- yt-dlp is from the official Fedora repos
- trash-cli is from the official Fedora repos
- ncdu is from the official Fedora repos
- powerline is from the official Fedora repos
- picocom is from the official Fedora repos

- wezterm is from a copr repo
- ani-cli is from a copr repo
- lazygit is from a copr repo or from github using go install cmd
- lf is from a copr or from github using go install cmd
- glow is from a copr or from github using go install cmd
- opera is from the custom repo, needs a fix for videos from <https://github.com/Ld-Hagen/fix-opera-linux-ffmpeg-widevine.git>

- dropbox is from the official Dropbox page
- discord is from the script install_discord.sh

- starship is from cargo
- du-dust is from cargo
- xh is from cargo
- md-tui is from cargo
- mdcat is from cargo
- sshs is from cargo
- curlie is installed from github using go install cmd

- posting is from uv
- glances is from uv
- frogmouth is from uv
- mdv is from uv
- xlsx2csv is from uv

### TBD

- httpie

### Other apps

- nvme-cli, sysstat, fuse, squashfuse, cpu-x are from the official Fedora repos
- libxcrypt-compat & openssl-devel are dependencies that needed to be installed manually
- Build tools and other build dependencies are installed as needed
- htop, btop, nvtop & powertop are from the official Fedora repos
- ark is from the official Fedora repos
- nomacs is from the official Fedora repos
- okular & other KDE apps are from the official Fedora repos
- p7zip, unrar, vlc, cmus, ffmpeg, steam, lutris & codecs are from the rpmfusion repos
- transmission, qBitorrent & KTorrent are from the official Fedora repos
- LibreOffice is from the official Fedora repos
- wireshark is from the official Fedora repos
- ncurses is from the official Fedora repos
- id3v2 is from the official Fedora repos
- pdftk-java is from the official Fedora repos
- libcdio is from the official Fedora repos
- atool is from the official Fedora repos
- catdoc is from the official Fedora repos
- pandoc is from the official Fedora repos
- poppler-utils is from the official Fedora repos
- ffmpegthumbnailer is from the official Fedora repos
- ImageMagick is from the official Fedora repos
- fontforge is from the official Fedora repos
- mediainfo is from the official Fedora repos
- perl-Image-ExifTool is from the official Fedora repos
- odt2txt is from the official Fedora repos
- elinks is from the official Fedora repos
- lynx is from the official Fedora repos
- w3m & w3m-img are from the official Fedora repos
- parallel is from the official Fedora repos
- discount is from the official Fedora repos
- playerctl is from the official Fedora repos
- NetworkManager-tui is from the official Fedora repos
- wireguard-tools is from the official Fedora repos

## From flatpak

- QuodLibet
- KiCAD
- OnlyOffice
- Obsidian
- Flatseal
- Bottles
- LocalSend
- FreeCAD

### Other apps

- Xournalpp
- Scrivano
- Saber
- Rnote
- Pinta
- Celluloid
- Gear Level

### Unused old apps

- Joplin is from an AppImage
- P3x OneNote is from Github

### Manual installs

Typically used for packages not built for Fedora, or on other OS'es

#### cargo installs

Programs that are frequently used

As of Feb 2025, Fedora 41 does not ship `du-dust`, `startship`, `xh` & has outdated packages of `eza`, `fd-find`, `zoxide` 

```bash
cargo install --locked bat
cargo install --locked git-delta
cargo install --locked du-dust
cargo install --locked eza
cargo install --locked fd-find
cargo install --locked ripgrep
cargo install --locked sd
cargo install --locked starship
cargo install --locked xh
cargo install --locked zoxide
cargo install --locked tree-sitter-cli
cargo install --locked procs
```

Other programs that are not used frequently

```bash
cargo install --locked mdcat
cargo install --locked md-tui
cargo install --git https://github.com/quantumsheep/sshs
```

#### go installs

As of Feb 2025, Fedora 41 does not ship `curlie` and the copr repo of `glow` is outdated 

Programs that are frequently used

```bash
env CGO_ENABLED=0 go install -v -ldflags="-s -w" github.com/gokcehan/lf@latest
go install -v github.com/charmbracelet/glow@latest
go install -v github.com/rs/curlie@latest
go install -v github.com/jesseduffield/lazygit@latest
go install -v github.com/dundee/gdu/v5/cmd/gdu@latest
```

#### pip installs

First install `uv` python packager binary to be able to use it

```bash
pip install --user uv
```

Packages used in `zsh` integrations

```bash
pip install --user --upgrade libtmux
```

Packages used in `wikiman` build scripts

When installing `simplemediawiki` via pip need to port the code to run on modern Python versions

```bash
pip install --user --upgrade cssselect
pip install --user --upgrade kitchen
pip install --user --upgrade simplemediawiki
```

#### uv installs

`uv` allows isolation on python packages installations, leaving a less clustered path on `~/.local/bin`

Programs that are frequently used

As of Feb 2025, Fedora 41 ships Python 3.13, which is not supported on `posting`, is possible to side install Python 3.12 or Python 3.11

```bash
uv tool install --python 3.11 posting
uv tool install glances
uv tool install tldr
uv tool install trash-cli
uv tool install thefuck
uv tool install Pygments
uv tool install xlsx2csv
```

Other programs that are not used frequently

```bash
uv tool install mdv
uv tool install frogmouth
uv tool install Markdown # (?)
```

Packages for esp32 mcu's interaction
When installing `esptool` via pip it automatically installs `intelhex` as a dependency and places them in path, to avoid issues installing them with `uv` is recommended

```bash
uv tool install esptool
uv tool install rshell
uv tool install adafruit-ampy
uv tool install intelhex
uv tool install Unidecode # (?)
```

## Ranger previews

These are the programs that should be installed on the system to be able to display previews, which are then later used in `lf`

Previews for html files
- elinks
- lynx
- w3m

Previews for general files as text
- pygmentize (python3 pygments)
- stat (coreutils) && tput (ncurses)
- catdoc
- pandoc

Previews for archives (gz,tar,etc)
- atool
- rar
- 7z

Previews for ISO
- iso-info (libcdio)

Previews for pdf as text
- pdftotext (poppler-utils)
- mupdf

Previews of pdfs as thumbnails
- pdftoppm (poppler-utils)

Previews for word style documents
- odt2txt

Previews for excel style documents
- xlsx2csv (From gtihub)

Previews for media files metadata
- mediainfo
- exiftool (perl-Image-ExifTool)

Previews for torrent metadata
- transmission-show (transmission-common)

Image previews
- w3mimgdisplay (w3m-img)
- identify && magick/convert (ImageMagick)

Video thumbnails
- ffmpegthumbnailer

For other files
- epub-thumbnailer (From github)
- ebook-meta (calibre)
- ddjvu
- djvutxt

## Decompressing specific file types

These are the programs that should be installed on the system to be able to decompress a specific filetyp using `ark`, in addition to the default ones of a typical system installation such as `gzip`, `bzip2`, `zip`, etc

- libarchive : Tar, DEB, RPM, ISO, AppImage, XAR and CAB format support	
- p7zip : 7Z and Zip format support
- unzip : Legacy Zip format support
- unrar : RAR decompression support
- unarchiver : RAR and LHA format support
- lzop : LZO format support
- lrzip : LRZ format support
- arj : ARJ format support
- libzip : Zip format support

## Special need software

- wikiman is built from git, as well as the same for the sources, need to update some config to work
<https://github.com/filiparag/wikiman>

## neovim

Here are some lazy packages that can be used and setup
- kulala.nvim

## Image previews in terminal file managers

The program used is `ueberzugpp`, to install it on Fedora systems a custom repo is used

<https://github.com/jstkdng/ueberzugpp>

`ueberzugpp` can be configured to display the output on different methods, the current one used is `sixel` and is configured on `~/.config/ueberzugpp/config.json`

```bash
$ cat ~/.config/ueberzugpp/config.json
{
    "layer": {
    "silent": true,
    "output": "sixel"
    }
}
```

Custom repo
```bash
dnf config-manager addrepo --from-repofile=https://download.opensuse.org/repositories/home:justkidding/Fedora_41/home:justkidding.repo
dnf install ueberzugpp
```

The file managers `ranger` & `lf` are configured to display image previews using `ueberzugpp`, on `ranger` is controlled via `rc.conf` and on `lf` via the wrapper script `scope-lf-wrapper.sh` which is set as previewer on `lfrc`

The following links are for references

<https://github.com/ranger/ranger/wiki/Image-Previews>

<https://github.com/gokcehan/lf/wiki/Previews>

The current config (Feb 2025) works on `wezterm` as terminal emulator and kinda works on `wezterm` + `tmux` as this last one doesn't handle correctly `sixel` support for large images, also need to find a better method to clean images

If going to drop tmux, then can change the `ueberzugpp` config to work with iterm2 image protocol as it is faster on `wezterm` than `sixel` on `wezterm`


## Other important links and repos

<https://docs.fedoraproject.org/en-US/quick-docs/installing-plugins-for-playing-movies-and-music/>

<https://github.com/devangshekhawat>

<https://github.com/devangshekhawat/Fedora-41-Post-Install-Guide>

# Install cmd's

For a Fedora 41 system

- Installation of used rpm packages
```bash
dnf install -y git zsh vim neovim tmux alacritty fzf eza zoxide bat git-delta fd-find ripgrep sd tldr ranger ncdu trash-cli python3-pygments thefuck podman nvme-cli sysstat fuse squashfuse cpu-x htop btop nvtop powertop ncurses ark atool libcdio libarchive libzip catdoc pandoc mupdf poppler-utils ffmpegthumbnailer ImageMagick mediainfo perl-Image-ExifTool odt2txt elinks lynx w3m w3m-img transmission parallel discount playerctl wireguard-tools powerline uv picocom yt-dlp nomacs okular libxcrypt-compat openssl-devel cmake make procs
```

- Installation of used programming languages
```bash
dnf install -y rust cargo golang nodejs python3.12 python3-pip dotnet-sdk-8.0 perl-interpreter
```

- Installation of `dnf` groups
```bash
dnf install -y @development-tools 
dnf install -y @c-development
dnf install -y @container-management
dnf install -y @libreoffice
```

- FOSS `rpmfusion` projects
```bash
dnf install -y p7zip unrar vlc cmus steam
```

- Enable and install packages from `copr` repos
```bash
dnf copr enable -y derisis13/ani-cli
dnf install -y ani-cli
dnf copr enable -y wezfurlong/wezterm-nightly
dnf install -y wezterm
dnf copr enable -y atim/lazygit
dnf install -y lazygit
dnf copr enable -y pennbauman/ports
dnf install -y lf
```

- Setup custom repos & install packages
```bash
rpm --import https://rpm.opera.com/rpmrepo.key
tee /etc/yum.repos.d/opera.repo <<RPMREPO
[opera]
name=Opera packages
type=rpm-md
baseurl=https://rpm.opera.com/rpm
gpgcheck=1
gpgkey=https://rpm.opera.com/rpmrepo.key
enabled=1
RPMREPO
dnf install opera-stable -y

tee /etc/yum.repos.d/charm.repo <<RPMREPO
[charm]
name=Charm
baseurl=https://repo.charm.sh/yum/
enabled=1
gpgcheck=1
gpgkey=https://repo.charm.sh/yum/gpg.key
RPMREPO
dnf install -y glow

rpm --import https://packages.microsoft.com/keys/microsoft.asc
curl https://packages.microsoft.com/config/rhel/7/prod.repo | tee /etc/yum.repos.d/microsoft.repo
echo "priority=100" >> /etc/yum.repos.d/microsoft.repo
dnf install -y powershell
```

- Installation of packages that are not shipped by default as rpm's
```bash
cargo install --locked starship
cargo install --locked du-dust
cargo install --locked xh
pip install --user uv
uv tool install --python 3.12 posting
go install -v github.com/rs/curlie@latest
go install -v github.com/charmbracelet/glow@latest
```

- Installation of packages that are outdated rpm's & installation of other not so used packages
```bash
cargo install --locked eza
cargo install --locked zoxide
cargo install --locked fd-find
cargo install --locked mdcat
cargo install --locked md-tui
cargo install --git https://github.com/quantumsheep/sshs
```

- Setup for the home directory
```bash
ln -s /run/media/${USER} ~/media
ln -s ~/dotfiles/scripts ~/scripts
```

- Group installs for `dnf4`
```bash
dnf group install -y "Development Tools"
dnf group install -y "C Development Tools and Libraries"
dnf group install -y "Container Management"
dnf group install -y "Libreoffice"
```

