#!/usr/bin/env bash

ipe()
{
  dig TXT +short o-o.myaddr.l.google.com @ns1.google.com | awk -F'"' '{ print $2 }';
}
