"==============================================================================
" An example for vimrc
"
" Maintainer   : Shoji KUMAGAI <shoji.kumagai@mail.rakuten.co.jp>
" Last updated : Thu Dec 22 20:56:10 JST 2011
"
" To use this, copy to your home directory.
"==============================================================================

"==============================================================================
" Vim scripts
"==============================================================================

"----------------------------------------------------------
" neobundle.vim
"----------------------------------------------------------
" If you don't have neobundle.vim, follow the steps below
" to install.
"
" mkdir ~/.bundle
" cd ~/.bundle
" git git://github.com/Shougo/neobundle.vim.git
if has('vim_starting')
    set runtimepath+=~/.bundle/neobundle.vim
    filetype off
    call neobundle#rc(expand('~/.bundle'))
    filetype plugin on
    filetype indent on
endif

" List up below plugins which you wanna use it.
NeoBundle 'https://github.com/nathanaelkane/vim-indent-guides.git'
NeoBundle 'git://github.com/altercation/vim-colors-solarized.git'
NeoBundle 'chriskempson/vim-tomorrow-theme'

"----------------------------------------------------------
" indent-guide
"----------------------------------------------------------
let g:indent_guides_auto_colors = 1
let g:indent_guides_guide_size = 1
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_color_change_percent = 30


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
set background=dark
colorscheme Tomorrow-Night-Bright
syntax on
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
