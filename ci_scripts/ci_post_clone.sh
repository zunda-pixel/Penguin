#!/bin/zsh

#  ci_post_clone.sh

env_file_path="../Sources/Env.swift"

cat <<EOT | sed -i -E -f- "${env_file_path}"
s/<#CLIENT_KEY#>/"${CLIENT_KEY}"/g
s/<#CLIENT_SECRET_KEY#>/"${CLIENT_SECRET_KEY}"/g
EOT
