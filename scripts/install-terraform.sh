#!/usr/bin/env bash
# Installs Terraform into /usr/local/bin. Writes nothing into your repo. Safe to run twice.
set -euo pipefail

V=1.17.2
Z="terraform_${V}_linux_amd64.zip"

rm -f /tmp/terraform "/tmp/${Z}"
curl -fsSL -o "/tmp/${Z}" "https://releases.hashicorp.com/terraform/${V}/${Z}"
unzip -o -d /tmp "/tmp/${Z}" terraform
sudo mv /tmp/terraform /usr/local/bin/
terraform version
