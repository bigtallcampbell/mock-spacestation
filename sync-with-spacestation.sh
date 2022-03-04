#!/bin/bash
echo "Starting Mock-SpaceStation Sync..."
echo "----------------------------------"
echo "Uploading from Ground to Space...."
rsync --ignore-existing --update -r /mock-groundstation/sync root@mock-spacestation:/root/
echo "Upload complete"
echo ""
echo "Downloading from Space to Ground...."
rsync --ignore-existing --update -r root@mock-spacestation:/root/sync /mock-groundstation
echo "Download complete"
echo "----------------------------------"
echo "Mock-SpaceStation Sync complete"