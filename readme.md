# Programs & Configurations

Personal dotfiles and package lists for supported Fedora releases, with a KDE desktop setup and a Wayland window-manager setup for Niri and Hyprland.

This is not a one-command install of a generic desktop. Some files contain machine-specific paths, monitor settings, services, and application state. Copy or link only the parts that are wanted.

## Layout

- `.config/` is the KDE desktop config. It includes terminal, shell, editor, file-manager, media, KDE and user-service configuration.
- `.config_wm/` is the Niri and Hyprland setup. It contains the shared config plus Waybar, Walker, SwayNC, Rofi, Mako, Wlogout and related portal/systemd configuration.
- `.local/bin/` contains local commands and the helper scripts used by the desktop setup.
- `bootstrap/` contains the package bootstrapper and its package manifest.
- `other_configs/flatpaks_id.txt` is the Flatpak application list.
- `other_configs/uv_tools.txt` is the `uv tool` list.
- `scripts/` contains small installers for Nerd Fonts, TPM, Discord, Go, unoserver and Prettyping.

The root shell files are small entry points. The actual Bash and Zsh setup lives in `.config/bash/` and `.config/zsh/`.

## Fedora bootstrap

`bootstrap/packages.yml` is the current package source of truth. It installs the base Fedora packages, RPM Fusion packages, COPR packages, the `ueberzugpp` repository and the required Fedora groups.

The Fedora setup includes Neovim, tmux, Zsh, Alacritty, WezTerm, LF, Ranger, Podman, development tools, preview dependencies, fonts, media tools, Hyprland and Niri. Package lists change here first; do not use the old long `dnf install` commands from previous versions of this README.

The bootstrap script needs its package-manager helper next to it. It is tracked at `.local/bin/scripts/pkg_manager.sh`:

```bash
ln -s ../.local/bin/scripts/pkg_manager.sh bootstrap/pkg_manager.sh
./bootstrap/bootstrap.sh
```

It detects Fedora, RHEL-like systems, Ubuntu and Arch. Fedora is the maintained path. The Ubuntu, Arch and RHEL blocks are smaller and are not equivalent to the Fedora desktop setup.

Review `bootstrap/packages.yml` before running it. It enables repositories, installs packages with sudo, and removes `fedora-workstation-repositories` on Fedora and `nano` on RHEL-like systems. Make sure third-party repository URLs match the Fedora release being installed.

## Flatpaks and uv tools

Install the Flatpaks listed in `other_configs/flatpaks_id.txt` after Flatpak is configured:

```bash
xargs -r -a other_configs/flatpaks_id.txt flatpak install -y flathub
```

Install the isolated Python tools listed in `other_configs/uv_tools.txt`:

```bash
xargs -r -a other_configs/uv_tools.txt -n 1 uv tool install
```

Current Flatpak applications include Zen and Brave, Obsidian, OnlyOffice, KiCad, FreeCAD, LibreCAD, Bottles, LocalSend, Flatseal and the drawing/note applications.

## Cargo tools

`ripdrag` is installed from Cargo:

```bash
cargo install --locked ripdrag
```

`wlr-which-key` is used by the Niri and Hyprland setup:

```bash
cargo install --locked wlr-which-key
```

`wayfreeze` is used by the Niri and Hyprland setup:

```bash
git clone https://github.com/Jappie3/wayfreeze
cd wayfreeze
cargo build --release
cargo install --path .
```

## Desktop configuration

For KDE, use `.config/`. For Niri or Hyprland, use `.config_wm/`; choose the compositor and services that are actually going to run.

Do not replace the whole `~/.config` without checking it first. In particular, these files are expected to be local to a machine:

- monitor and input settings in `.config_wm/hypr/` and `.config_wm/niri/`
- desktop portals in `.config_wm/xdg-desktop-portal/`
- user services in `.config*/systemd/user/`
- browser, GTK, Qt, dconf and KDE state

The terminal setup is shared: Alacritty/WezTerm, tmux, Starship, Neovim, Vim, LF, Ranger, Fastfetch, Cava, cmus and the Bash/Zsh configuration are available in both trees.

## File previews

LF and Ranger use the configured preview scripts. The Fedora package manifest already contains most of the needed programs: `atool`, `libcdio`, `poppler-utils`, `mupdf`, `ffmpegthumbnailer`, `ImageMagick`, `mediainfo`, `perl-Image-ExifTool`, `odt2txt`, `w3m`, `w3m-img`, `catdoc`, `pandoc` and `transmission-common`.

`ueberzugpp` is installed from the `home:justkidding` repository and is configured for sixel output in `.config*/ueberzugpp/config.json`. It is used by LF and Ranger for image previews. It works best in WezTerm; large sixel previews through tmux can still be rough.

## Extra installers

Run these only when needed:

```bash
scripts/install_nerd_fonts.sh
scripts/install_tmux_tpm.sh
scripts/install_discord.sh
scripts/install_go.sh
scripts/install_unoserver.sh
scripts/install_prettyping.sh
```

`scripts/reset_usb.sh` is a recovery/helper script, not part of the normal setup.

## Other references

- Fedora multimedia setup: <https://docs.fedoraproject.org/en-US/quick-docs/installing-plugins-for-playing-movies-and-music/>
- Ranger image previews: <https://github.com/ranger/ranger/wiki/Image-Previews>
- LF previews: <https://github.com/gokcehan/lf/wiki/Previews>
