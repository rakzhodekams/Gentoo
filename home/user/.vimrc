" Global configs
filetype plugin indent on
syntax on

set nocompatible
set t_Co=256
set number
set linebreak
set nobackup
set wildmode=longest:list
set wildignore+=*.DS_STORE,*.db,node_modules/**,*.jpg,*.png,*.gif,*.mp3,*.mp4
set ignorecase
set gdefault
set smartindent
set expandtab
set tabstop=2
set shiftwidth=2
set autochdir
set cursorline
set hlsearch
set pumheight=15
set completeopt=menu,preview
set exrc
set secure 
set directory=~/tmp,/tmp,/var/tmp
set is
set hls
set novb
set showcmd
set showmode
set showmatch
set nohidden
set ttyfast
set noerrorbells
set report=0
set nowb
set noswapfile


" set list

" Statusbar 
set laststatus=2
set statusline=%t
set statusline+=%m
set statusline+=%r
set statusline+=%y
set statusline+=%=
set statusline+=%c
set statusline+=%V
set statusline+=%P
set statusline+=,%l:%L
set statusline+=%F
set statusline+=%h
set statusline+=%w

hi User1 ctermfg=231  ctermbg=25
hi User2 ctermfg=231  ctermbg=237
hi User3 ctermfg=231  ctermbg=235

" color scheme
set background=dark
hi CursorLine   ctermbg=237
hi MatchParen   ctermfg=255   ctermbg=242
hi Pmenu        ctermfg=15    ctermbg=238
hi PmenuSel     ctermfg=0     ctermbg=107
hi Normal       ctermfg=253   ctermbg=233
hi LineNr       ctermfg=244   ctermbg=232
hi Visual                     ctermbg=238


