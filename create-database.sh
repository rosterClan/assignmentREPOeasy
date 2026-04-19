#!/bin/bash
exec > /var/log/user-data.log 2>&1
set -euxo pipefail

sudo dnf update -y
sudo dnf install -y python3 python3-pip git postgresql15

PROJECT_DIR=/opt/docsummary
sudo git clone https://github.com/rosterClan/assignmentREPOeasy.git "$PROJECT_DIR"
sudo chown -R ec2-user:ec2-user "$PROJECT_DIR"

sudo pip3 install -r "$PROJECT_DIR/requirements.txt"

command -v psql >/dev/null || { echo "ERROR: psql not found"; exit 1; }

echo "setup complete at $(date)"
