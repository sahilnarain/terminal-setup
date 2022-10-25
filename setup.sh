#!/bin/sh

# VIM
curDir=`pwd`
backupDir=vim-`date +%Y%m%d_%H%M%S`
cd ~
mkdir $backupDir
mv ~/.vim* $backupDir/
mv $backupDir ".bkp-$backupDir"
mkdir -p ~/.vim/autoload ~/.vim/bundle  ~/.vim/colors ~/.vim/plugin ~/.vim/syntax
curl -LSso ~/.vim/autoload/pathogen.vim https://raw.githubusercontent.com/tpope/vim-pathogen/master/autoload/pathogen.vim
echo 'execute pathogen#infect()' >> ~/.vimrc

#Set options
echo 'filetype on' >> ~/.vimrc
echo 'filetype indent on' >> ~/.vimrc
echo 'syntax on' >> ~/.vimrc
echo 'set autoindent' >> ~/.vimrc
echo 'set background=dark' >> ~/.vimrc
echo 'set cursorline' >> ~/.vimrc
echo 'set expandtab' >> ~/.vimrc
echo 'set hlsearch' >> ~/.vimrc
echo 'set ignorecase' >> ~/.vimrc
echo 'set incsearch' >> ~/.vimrc
echo 'set laststatus=2' >> ~/.vimrc
echo 'set number' >> ~/.vimrc
echo 'set ruler' >> ~/.vimrc
echo 'set shiftwidth=2' >> ~/.vimrc
echo 'set smartcase' >> ~/.vimrc
echo 'set smartindent' >> ~/.vimrc
echo 'set tabstop=2' >> ~/.vimrc
echo 'set t_Co=256' >> ~/.vimrc

git clone https://github.com/prettier/vim-prettier ~/.vim/bundle/vim-prettier
cd ~/.vim/bundle/vim-prettier/
npm install
cd ~

git clone https://github.com/dense-analysis/ale ~/.vim/bundle/ale
cd ~

echo 'let g:prettier#autoformat=0' >> ~/.vimrc
echo 'let g:prettier#config#print_width=240' >> ~/.vimrc
echo 'let g:prettier#config#trailing_comma="none"' >> ~/.vimrc
echo 'let g:prettier#config#tab_width=2' >> ~/.vimrc
echo 'let g:prettier#config#bracket_spacing="false"' >> ~/.vimrc
echo 'let g:prettier#config#use_tabs="false"' >> ~/.vimrc
echo 'let g:prettier#config#semi="true"' >> ~/.vimrc
echo 'let g:prettier#config#single_quote="true"' >> ~/.vimrc
echo 'let g:prettier#config#allow_parens="always"' >> ~/.vimrc
echo 'let g:prettier#config#end_of_line="lf"' >> ~/.vimrc
echo 'autocmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.md,*.vue Prettier' >> ~/.vimrc

echo 'let g:SuperTabContextDefaultCompletionType = "<c-x><c-o>"' >> ~/.vimrc
echo 'autocmd BufRead,BufNewFile *.ts setfiletype typescript' >> ~/.vimrc
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
git clone https://github.com/leafgarland/typescript-vim ~/.vim/bundle/typescript-vim
cp $curDir/colors/* ~/.vim/colors/
echo 'colorscheme candyman' >> ~/.vimrc

echo 'let mapleader = ","' >> ~/.vimrc
echo ':nnoremap <leader>/ :TComment<Enter>' >> ~/.vimrc
echo ':vnoremap <leader>/ :TComment<Enter>' >> ~/.vimrc
echo ':nnoremap <leader>sj ^ddp' >> ~/.vimrc #Swap line below
echo ':nnoremap <leader>sk ^ddkP' >> ~/.vimrc #Swap line above

#Take it to the limit!
echo ':map <up> <nop>' >> ~/.vimrc
echo ':map <down> <nop>' >> ~/.vimrc
echo ':map <left> <nop>' >> ~/.vimrc
echo ':map <right> <nop>' >> ~/.vimrc

echo ':imap <up> <nop>' >> ~/.vimrc
echo ':imap <down> <nop>' >> ~/.vimrc
echo ':imap <left> <nop>' >> ~/.vimrc
echo ':imap <right> <nop>' >> ~/.vimrc

echo ':inoremap jj <Esc>' >> ~/.vimrc
echo ':nnoremap ; :' >> ~/.vimrc
echo ':nnoremap ;q1 :q!' >> ~/.vimrc

echo ':nnoremap <leader>e :e<Space>' >> ~/.vimrc

echo ':nnoremap <leader><leader> :colorscheme random<Enter>:colorscheme<Enter>' >> ~/.vimrc

echo ':nnoremap <leader>f <C-f>' >> ~/.vimrc
echo ':nnoremap <leader>b <C-b>' >> ~/.vimrc

# GIT
rm -rf ~/.gitconfig
rm /usr/local/bin/icdiff
curl -o icdiff https://raw.githubusercontent.com/jeffkaufman/icdiff/release-1.8.1/icdiff
chmod ugo+rx icdiff
mv icdiff /usr/local/bin/
cd $curDir
cp gitconf ~/.gitconfig
