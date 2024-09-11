#!/bin/sh

install_requirements() {
  apt-get update
  apt-get install -y git wget python python3-pip
  pip3 install --upgrade pip boto ansible
}

clone_repository() {
  git clone https://github.com/iagonc/ansible-ops.git /home/ubuntu/ansible
}

run_ansible_playbook() {
  ansible-playbook /home/ubuntu/ansible/playbook.yaml
}

# Execute functions
install_requirements
clone_repository
run_ansible_playbook