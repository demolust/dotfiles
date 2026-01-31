if sudo test -f /etc/sudoers.d/99-installer-reboot; then
  sudo rm -f /etc/sudoers.d/99-installer-reboot
fi
