#!/bin/zsh

# ci_post_clone.sh

defaults write com.apple.dt.Xcode IDESkipPackagePluginFingerprintValidatation -bool YES

cd ..

env_file=".env"
touch $env_file

cat > $env_file <<EOL
clientKey=${CLIENT_KEY}
clientSecretKey=${CLIENT_SECRET_KEY}
EOL

projectPath=$(pwd)

cd PenguinKit

swift package plugin --allow-writing-to-directory Sources generate-env ../${env_file} Sources/Env.swift
