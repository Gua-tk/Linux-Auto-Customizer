install_caffeine_pre()
{
  apt-get purge -y caffeine
}

install_caffeine_post()
{
  wget -O - https://gist.githubusercontent.com/syneart/aa8f2f27a103a7f1e1812329fa192e65/raw/caffeine-indicator.patch | patch /usr/bin/caffeine-indicator
}

uninstall_caffeine_pre()
{
 :
}

uninstall_caffeine_post()
{
 :
}