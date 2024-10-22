#!/bin/sh

install_requirements() {
  apt-get update
  apt-get install -y git wget go
}

clone_repository() {
  git clone "${repo_url}" /home/ubuntu/jorge-cli
}

# Execute functions
install_requirements
clone_repository
