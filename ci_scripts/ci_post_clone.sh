#!/bin/sh
brew install nshipster/formulae/gyb
brew install pyenv
pyenv install 2.7.18
export PATH=$(pyenv root)/shims:$PATH