#!/bin/sh

# VIM
curDir=`pwd`
backupDir=vim-`date +%Y%m%d_%H%M%S`
cd ~
mkdir $backupDir
mv ~/.vim* $backupDir/
mv $backupDir ".bkp-$backupDir"

mkdir -p ~/.vim/autoload ~/.vim/bundle  ~/.vim/colors ~/.vim/plugin ~/.vim/syntax

# Pathogen
curl -LSso ~/.vim/autoload/pathogen.vim https://raw.githubusercontent.com/tpope/vim-pathogen/master/autoload/pathogen.vim

#Prettier
git clone https://github.com/prettier/vim-prettier ~/.vim/bundle/vim-prettier
cd ~/.vim/bundle/vim-prettier/
npm install --legacy-peer-deps
rm -rf node_modules/prettier
npm install prettier@^1.0.0
cd ~

# ALE
git clone https://github.com/dense-analysis/ale ~/.vim/bundle/ale
cd ~

# Auto Pairs
git clone https://github.com/jiangmiao/auto-pairs.git
mv auto-pairs/plugin/auto-pairs.vim ~/.vim/plugin/
rm -rf ~/auto-pairs

# VIM JS
git clone https://github.com/pangloss/vim-javascript.git ~/.vim/bundle/vim-javascript
git clone https://github.com/crusoexia/vim-javascript-lib.git
mv ~/vim-javascript-lib/after/syntax/javascript.vim ~/.vim/syntax/
rm -rf ~/vim-javascript-lib/

# TComment
git clone https://github.com/tomtom/tcomment_vim.git ~/.vim/bundle/tcomment

# Git Gutter
git clone https://github.com/airblade/vim-gitgutter.git ~/.vim/bundle/vim-gitgutter

# Supertab
git clone https://github.com/ervandew/supertab.git ~/.vim/bundle/supertab
cd ~/.vim/bundle/supertab
git reset --hard ea67023f1994c11a89c7c0a81012772071389054
cd ~

# Vum TS
git clone https://github.com/leafgarland/typescript-vim ~/.vim/bundle/typescript-vim

#  NERDTree
git clone https://github.com/preservim/nerdtree

# Colorschemes
cp $curDir/colors/* ~/.vim/colors/

# Git
rm -rf ~/.gitconfig
rm /usr/local/bin/icdiff
curl -o icdiff https://raw.githubusercontent.com/jeffkaufman/icdiff/release-1.8.1/icdiff
chmod ugo+rx icdiff
mv icdiff /usr/local/bin/
cd $curDir
cp gitconf ~/.gitconfig

# vimrc
cp $curDir/dotfiles/vimrc ~/.vimrc

# bashrc
cp $curDir/dotfiles/bashrc-remote ~/.bashrc
# cp $curDir/dotfiles/bashrc-local ~/.bashrc

# tmux.conf
cp $curDir/dotfiles/tmux.conf ~/.tmux.conf

# mutt
cp -r $curDir/dotfiles/mutt ~/.mutt
cp $curDir/dotfiles/muttrc ~/.muttrc
