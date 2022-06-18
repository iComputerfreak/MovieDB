#!/bin/sh

set -e

brew install nshipster/formulae/gyb
which gyb
pwd
ls
brew install pyenv
pyenv install 2.7.18
pyenv global 2.7.18

export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
pyenv shell 2.7.18
pyenv shell

# Prepare .zshrc
brew shellenv >> ~/.zshrc
echo "export PYENV_ROOT=\"$HOME/.pyenv\"" >> ~/.zshrc
echo "command -v pyenv >/dev/null || export PATH=\"$PYENV_ROOT/bin:$PATH\"" >> ~/.zshrc
echo "eval \"$(pyenv init -)\"" >> ~/.zshrc
echo "export PATH=$(pyenv root)/shims:$PATH" >> ~/.zshrc
echo "export HOMEBREW_NO_ENV_HINTS=true" >> ~/.zshrc