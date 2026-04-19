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

AWS_REGION="ap-southeast-2"

_param() {
    local name="$1"
    local decrypt="${2:-false}"
    if [ "$decrypt" = "true" ]; then
        aws ssm get-parameter --region "$AWS_REGION" --name "$name" --with-decryption --query "Parameter.Value" --output text
    else
        aws ssm get-parameter --region "$AWS_REGION" --name "$name" --query "Parameter.Value" --output text
    fi
}

PGHOST="$(_param /docsummary/db/host)"
PGDATABASE="$(_param /docsummary/db/name)"
PGUSER="$(_param /docsummary/db/DB_USER)"
PGPASSWORD="$(_param /docsummary/db/DB_PASSWORD true)"
PGPORT="$(_param /docsummary/db/DB_PORT)"

export PGPASSWORD

psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE" <<EOF
CREATE TABLE IF NOT EXISTS documents (
    id SERIAL PRIMARY KEY,
    filename VARCHAR(255) NOT NULL,
    s3_key TEXT NOT NULL,
    summary TEXT,
    status VARCHAR(50) NOT NULL DEFAULT 'completed',
    uploaded_at TIMESTAMP NOT NULL
);
EOF

echo "Table 'documents' created successfully."
echo "setup complete at $(date)"
