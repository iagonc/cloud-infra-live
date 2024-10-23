#!/bin/sh
install_requirements() {
  apt-get update
  apt-get install -y git wget curl
}

clone_repository() {
  git clone "${repo_url}" /home/ubuntu/teemo-cli
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.1
}

configure_asdf() {
  if ! grep -q 'asdf.sh' ~/.bashrc; then
    echo -e '\n# Inicialização do asdf' >> ~/.bashrc
    echo '. "$HOME/.asdf/asdf.sh"' >> ~/.bashrc
  fi

  if ! grep -q 'asdf.bash' ~/.bashrc; then
    echo '. "$HOME/.asdf/completions/asdf.bash"' >> ~/.bashrc
  fi

  source ~/.bashrc

  asdf plugin-add golang https://github.com/kennyp/asdf-golang.git

  asdf install golang latest
  asdf global golang latest
}

configure_go() {
  source ~/.bashrc

  go build -o teemo-cli /home/ubuntu/teemo-cli/cmd/cli/main.go
}

# Execute functions
install_requirements
clone_repository
configure_asdf
setup_tool_versions
configure_go
