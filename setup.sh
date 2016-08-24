#!/bin/sh
curDir=`pwd`
rm -rf ~/.vim*
mkdir -p ~/.vim/autoload ~/.vim/bundle  ~/.vim/colors ~/.vim/plugin ~/.vim/syntax
curl -LSso ~/.vim/autoload/pathogen.vim https://raw.githubusercontent.com/tpope/vim-pathogen/master/autoload/pathogen.vim
echo 'execute pathogen#infect()' >> ~/.vimrc

#Set options
echo 'syntax on' >> ~/.vimrc
echo 'set autoindent' >> ~/.vimrc
echo 'set background=dark' >> ~/.vimrc
echo 'set cursorline' >> ~/.vimrc
echo 'set expandtab' >> ~/.vimrc
echo 'set ignorecase' >> ~/.vimrc
echo 'set laststatus=2' >> ~/.vimrc
echo 'set mouse=a' >> ~/.vimrc
echo 'set number' >> ~/.vimrc
echo 'set ruler' >> ~/.vimrc
echo 'set shiftwidth=2' >> ~/.vimrc
echo 'set smartcase' >> ~/.vimrc
echo 'set smartindent' >> ~/.vimrc
echo 'set tabstop=2' >> ~/.vimrc
echo 'set t_Co=256' >> ~/.vimrc

git clone https://github.com/beautify-web/js-beautify.git ~/.vim/bundle/js-beautify
cd ~/.vim/bundle/js-beautify/
npm install
cd ~
echo 'let g:SuperTabContextDefaultCompletionType = "<c-x><c-o>"' >> ~/.vimrc
echo 'fun! JSBeautify()' >> ~/.vimrc
echo '  set noconfirm' >> ~/.vimrc
echo '  :silent !'~/.vim/bundle/js-beautify/js/bin/js-beautify.js' -q -r '%'' >> ~/.vimrc
echo '  bufdo e!' >> ~/.vimrc
echo '  set confirm' >> ~/.vimrc
echo 'endfun' >> ~/.vimrc
echo 'autocmd BufWritePost *.js,*.json call JSBeautify()' >> ~/.vimrc
sed -i.bak "s/\"indent_size\":\ 4,/\"indent_size\":\ 2,/g" ~/.vim/bundle/js-beautify/js/config/defaults.json
sed -i.bak "s/\"jslint_happy\":\ false,/\"jslint_happy\":\ true,/g" ~/.vim/bundle/js-beautify/js/config/defaults.json
rm -f ~/.vim/bundle/js-beautify/js/config/defaults.json.bak
git clone https://github.com/jiangmiao/auto-pairs.git
mv auto-pairs/plugin/auto-pairs.vim ~/.vim/plugin/
rm -rf ~/auto-pairs
git clone https://github.com/pangloss/vim-javascript.git ~/.vim/bundle/vim-javascript
git clone https://github.com/crusoexia/vim-javascript-lib.git
mv ~/vim-javascript-lib/after/syntax/javascript.vim ~/.vim/syntax/
rm -rf ~/vim-javascript-lib/
git clone https://github.com/tomtom/tcomment_vim.git ~/.vim/bundle/tcomment
git clone https://github.com/airblade/vim-gitgutter.git ~/.vim/bundle/vim-gitgutter
git clone https://github.com/ervandew/supertab.git ~/.vim/bundle/supertab
cp $curDir/colors/* ~/.vim/colors/
echo 'colorscheme oxeded' >> ~/.vimrc

echo 'let mapleader = ","' >> ~/.vimrc
echo ':nnoremap <leader>/ :TComment<Enter>' >> ~/.vimrc
echo ':vnoremap <leader>/ :TComment<Enter>' >> ~/.vimrc
echo ':nnoremap <leader>sj ^ddp' >> ~/.vimrc #Swap line below
echo ':nnoremap <leader>sk ^ddkP' >> ~/.vimrc #Swap line above
