
sssh() {
  if [ $# -eq 0 ]; then
    echo "Enter username:"
    read username
    echo "Enter ip/domain:"
    read ip
  elif [ $# -eq 2 ]; then
    username=$1
    ip=$2
  else
    echo "We need a user and domain/name to stablish ssh connection"
  fi
  ssh "${username}"@"${ip}"
  # SFTP and FTP via nemo with password login only on the 1st connection, use nemo to connect to servers.
  # nemo sftp://username@192.168.169.170:123 ?
  }
