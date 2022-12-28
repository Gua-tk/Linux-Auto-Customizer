install_opensshServer_post()
{
  for conf_element in "${opensshServer_conf[@]}"; do
    append_text "${conf_element}" "${SSH_GLOBAL_CONF_PATH}"
  done
}
uninstall_opensshServer_post()
{
  for conf_element in "${opensshServer_conf[@]}"; do
    remove_line "${conf_element}" "${SSH_GLOBAL_CONF_PATH}"
  done
}
