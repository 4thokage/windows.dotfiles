call plug#begin('~/AppData/Local/nvim/plugged')
Plug 'preservim/nerdtree'
Plug 'tpope/vim-surrond'
Plug 'junegunn/fzf.vim'
Plug 'itchyny/lightline.vim'
Plug 'mattn/emmet-vim'
Plug 'shougo/deoplete.vim', {'do':':UpdateRemotePlugins'}
Plug 'arcticicestudio/nord-vim'
call plug#end()

nmap <C-n> :NERDTreeToggle<CR>

colorscheme nord
set shiftwidth=4
set tabstop=4
set expandtab
set clipboard^=unnamed,unnamedplus
filetype plugin on
filetype indent on
syntax on
set nu
set autochdir
nmap <leader>l :set list!<CR>
set mouse=a
set autoread
let NERDTreeQuitOnOpen = 1
set completeopt=menu
set linebreak
autocmd Filetype html,ruby,javascript,yml,yaml,json,haskell,ejs,htmldjango setlocal ts=2 sts=2 sw=2
set noswapfile

if &term =~ '256color'
    set t_ut=
endif

let g:ycm_autoclose_preview_window_after_completion=1
set enc=utf-8
set fileencodings=ucs-bom,utf8,prc
set fileencoding=utf-8
set nofoldenable
filetype plugin indent on

map <F6> :%!xmllint --format %

runtime JavaRun.vim

map <F8> :Run<CR>