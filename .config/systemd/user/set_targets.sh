#!/bin/bash

bash_script_path=$(readlink -f $(dirname "$0"))
service='dropbox.service'

basic_target="~/.config/systemd/user/basic.target.wants/"
local_target="~/.config/systemd/user/local.target.wants/"
ln -s $basic_target $service
ln -s $local_target $service
