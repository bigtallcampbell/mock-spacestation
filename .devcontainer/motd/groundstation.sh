#!/bin/bash
login_msg="/workspaces/mock-spacestation/.devcontainer/motd/groundstation.motd"
while IFS= read -r line
do
  echo "$line"
done < "$login_msg"


