
ipi()
{
  hostname -I | awk '{print $1}'
}
