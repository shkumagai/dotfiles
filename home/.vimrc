"==============================================================================
" An example for vimrc
"
" Maintainer   : Shoji KUMAGAI <take.this.2.your.grave@gmail.com>
" Last updated : Thu Aug 21 15:15:10 JST 2026
"
" To use this, copy to your home directory.
"==============================================================================

"==============================================================================
" Vim scripts
"==============================================================================

"----------------------------------------------------------
" jetpack.vim
"----------------------------------------------------------
" If you don't have jetpack.vim, follow the steps below
" to install.
"
" curl -fLo ~/.vim/pack/jetpack/opt/vim-jetpack/plugin/jetpack.vim --create-dirs https://raw.githubusercontent.com/tani/vim-jetpack/master/plugin/jetpack.vim

packadd vim-jetpack
call jetpack#begin()
Jetpack 'tani/vim-jetpack', {'opt': 1} "bootstrap
Jetpack 'nathanaelkane/vim-indent-guides'
Jetpack 'altercation/vim-colors-solarized'
Jetpack 'chriskempson/vim-tomorrow-theme'
Jetpack 'junegunn/fzf.vim'
call jetpack#end()

filetype plugin indent on


"----------------------------------------------------------
" indent-guide
"----------------------------------------------------------
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_guide_size = 1
let g:indent_guides_start_level = 2
let g:indent_guides_auto_colors = 0
autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  guibg=darkgray ctermbg=234
autocmd VimEnter,Colorscheme * :hi IndentGuidesEven guibg=gray     ctermbg=238


"==============================================================================
" Global
"==============================================================================

set nocompatible
set fileformats=unix,mac,dos
set vb t_vb=
set backspace=indent,eol,start


"==============================================================================
" Backup
"==============================================================================

set nobackup
set writebackup
"set backup
"set backupdir=~/backup
"set directory=~/swap


"==============================================================================
" Search
"==============================================================================

set history=100
set ignorecase
set smartcase
set wrapscan
set noincsearch


"==============================================================================
" Visual
"==============================================================================

set title
set number
set ruler
set list
set listchars=tab:>-,trail:-,eol:↩,extends:>,precedes:<,nbsp:%
set showcmd
set laststatus=2
set showmatch
set matchtime=2
syntax on
set re=0
set background=dark
colorscheme Tomorrow-Night-Bright
set hlsearch
highlight Comment ctermfg=DarkCyan
set wildmenu
set textwidth=0
set wrap
highlight ZenkakuSpace cterm=underline ctermfg=lightblue guibg=darkgray
match ZenkakuSpace /　/
set statusline=%n\:%y%F\ \|%{(&fenc!=''?&fenc:&enc).'\|'.&ff.'\|'}%m%r%=<%l/%L:%p%%>
highlight StatusLine term=NONE cterm=NONE ctermfg=black ctermbg=white


"==============================================================================
" Indent
"==============================================================================

set noautoindent
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab


"==============================================================================
" Internationalization
"==============================================================================

set encoding=utf-8
set termencoding=utf-8
set fileencoding=utf-8
set fileencodings=ucs-bom,utf-8,euc-jp,cp932,iso-2022-jp
set fileencodings+=,ucs-2le,ucs-2


"==============================================================================
" Auto Command execution
"==============================================================================

if has("autocmd")
    filetype plugin indent on
    autocmd BufReadPost *
        \ if line("'\"") > 0 && line("'\"") <= line("$") |
        \ exe "normal g'\"" |
        \ endif
endif


"==============================================================================
" Others
"==============================================================================

set hidden
set shortmess+=I


"__END__
