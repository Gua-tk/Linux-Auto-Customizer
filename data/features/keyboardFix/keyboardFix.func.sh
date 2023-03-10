#!/usr/bin/env bash
install_keyboardFix_post()
{
  update-initramfs -u -k all
}
uninstall_keyboardFix_pre()
{
  :
}
