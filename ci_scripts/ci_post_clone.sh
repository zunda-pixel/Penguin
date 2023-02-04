#!/bin/zsh

# ci_post_clone.sh

env_file_path="../PenguinKit/Sources/Env.swift"

cat <<EOT | sed -i -E -f- "${env_file_path}"
s/<#CLIENT_KEY#>/"${CLIENT_KEY}"/g
s/<#CLIENT_SECRET_KEY#>/"${CLIENT_SECRET_KEY}"/g
s/<#TEAM_ID#>/"${TEAM_ID}"/g
EOT

defaults write com.apple.dt.Xcode IDESkipPackagePluginFingerprintValidatation -bool YES
