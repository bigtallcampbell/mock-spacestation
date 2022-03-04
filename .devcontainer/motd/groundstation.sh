#!/bin/bash
login_msg="/mock-groundstation/.devcontainer/motd/groundstation.motd"
while IFS= read -r line
do
  echo "$line"
done < "$login_msg"


