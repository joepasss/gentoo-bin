#!/bin/bash

gpg --batch --gen-key <<EOF
Key-Type: RSA
Key-Length: 2048
Name-Real: joepasss/gentoo-bin
Name-Email: farwes1180@gmail.com
Expire-Date: 0
%no-protection
%commit
EOF

FPR=$(gpg --list-keys --with-colons | awk -F: '/^fpr:/ {print $10; exit}')

echo "${FPR}:6:" | gpg --import-ownertrust

gpgconf --kill all || true
