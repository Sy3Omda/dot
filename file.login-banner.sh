#!/bin/bash

echo
echo "    🖥️   OS: $(. /etc/os-release && echo "$PRETTY_NAME")"
echo "    🏠   Hostname: $(hostname)"
echo "    💡   IP Address: $(hostname -I | awk '{print $1}')"
echo
