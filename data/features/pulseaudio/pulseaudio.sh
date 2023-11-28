#!/usr/bin/env bash

export PULSE_SERVER="tcp:$(ip route |awk '/^default/{print $3}')"