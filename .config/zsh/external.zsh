############################### EXTERNAL DELCARATIONS ###############################
### Section for settings & customization for external programs that relies on zsh with some event/falg
### Such as on tmux plugins or nvim plugins

### Settings for ofirgall/tmux-window-name
### Install first `python3 -m pip install --user libtmux`
#function tmux-window-name() {
#	($TMUX_PLUGIN_MANAGER_PATH/tmux-window-name/scripts/rename_session_windows.py &)
#}
#add-zsh-hook chpwd tmux-window-name
