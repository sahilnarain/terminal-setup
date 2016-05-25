#!/bin/sh
rm -rf ~/.vim*
mkdir -p ~/.vim/autoload ~/.vim/bundle  ~/.vim/colors ~/.vim/plugin ~/.vim/syntax
curl -LSso ~/.vim/autoload/pathogen.vim https://raw.githubusercontent.com/tpope/vim-pathogen/master/autoload/pathogen.vim
echo 'execute pathogen#infect()' >> ~/.vimrc
echo 'set number' >> ~/.vimrc
echo 'syntax on' >> ~/.vimrc
echo 'set autoindent' >> ~/.vimrc
echo 'set smartindent' >> ~/.vimrc
echo 'set expandtab' >> ~/.vimrc
echo 'set tabstop=2' >> ~/.vimrc
echo 'set shiftwidth=2' >> ~/.vimrc
echo 'set t_Co=256' >> ~/.vimrc
git clone https://github.com/beautify-web/js-beautify.git ~/.vim/bundle/js-beautify
cd ~/.vim/bundle/js-beautify/
npm install
cd ~
echo 'set ignorecase' >> ~/.vimrc
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
# git clone https://github.com/crusoexia/vim-monokai.git
# mv vim-monokai/colors/monokai.vim ~/.vim/colors/
# rm -rf ~/vim-monokai/
git clone https://github.com/kristijanhusak/vim-hybrid-material
mv ~/vim-hybrid-material/colors/hybrid_material.vim ~/.vim/colors/
rm -rf ~/vim-hybrid-material/
git clone https://github.com/pangloss/vim-javascript.git ~/.vim/bundle/vim-javascript
git clone https://github.com/crusoexia/vim-javascript-lib.git
mv ~/vim-javascript-lib/after/syntax/javascript.vim ~/.vim/syntax/
rm -rf ~/vim-javascript-lib/
git clone https://github.com/tomtom/tcomment_vim.git ~/.vim/bundle/tcomment
git clone https://github.com/airblade/vim-gitgutter.git ~/.vim/bundle/vim-gitgutter
# echo 'colorscheme monokai' >> ~/.vimrc
echo 'set background=dark' >> ~/.vimrc
echo 'colorscheme hybrid_material' >> ~/.vimrc
git clone https://github.com/ervandew/supertab.git ~/.vim/bundle/supertab
echo 'set mouse=a' >> ~/.vimrc
#Temporary fix
cd ~/.vim/bundle/vim-javascript/
git checkout 842b0ceaa87936c1eb449617e7045ad33b81854e
cd ~
