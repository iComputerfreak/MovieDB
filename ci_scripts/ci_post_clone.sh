#!/bin/zsh

echo "Setting up homebrew dependencies..."
brew install nshipster/formulae/gyb
brew install mono0926/license-plist/license-plist
brew install swiftlint
brew install pyenv

echo "Installing python 2.7.18..."
pyenv install 2.7.18
pyenv global 2.7.18

print "Setting up environment..."
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

echo "Preparing .zshrc..."
# Prepare .zshrc
brew shellenv >> ~/.zshrc
echo "export PYENV_ROOT=\"$HOME/.pyenv\"" >> ~/.zshrc
echo "command -v pyenv >/dev/null || export PATH=\"$PYENV_ROOT/bin:$PATH\"" >> ~/.zshrc
echo "eval \"$(pyenv init -)\"" >> ~/.zshrc
echo "export PATH=$(pyenv root)/shims:$PATH" >> ~/.zshrc
echo "export HOMEBREW_NO_ENV_HINTS=true" >> ~/.zshrc