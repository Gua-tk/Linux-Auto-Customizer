#!/usr/bin/env bash

ipi()
{
  hostname -I | awk '{print $1}'
}
