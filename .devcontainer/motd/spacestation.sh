#!/bin/bash
login_msg="/etc/motd"
while IFS= read -r line
do
  echo "$line"
done < "$login_msg"