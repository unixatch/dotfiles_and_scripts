"
" Maintainer: unixatch
"
" Github Link: https://github.com/unixatch/dotfiles_and_scripts
"
" This configuration was initially a clone of
"   https://github.com/amix/vimrc
" but now it has grown with its own identity.
" Basically a small fork, so to speak.
"

" Sets always a blinking bar
let &t_SI .= "\<Esc>[5 q"
let &t_SR .= "\<Esc>[5 q"
let &t_EI .= "\<Esc>[5 q"

" complete menu style tweaks:
" - simple slim border with padding to the left and right;
" - opacity of 95 just to not distract too much;
" - height >30 would go over the statusline;
" - minwidth of 25 so that it's not too slim;
set pumopt=border:single,margin,opacity:95,width:25,height:30

" Basically the default without l
set shortmess=finxtToOS

" Fixes termguicolors
au! VimEnter * source ~/.vim-colors | set termguicolors
au! BufRead */.vim-colors set syntax=vim

" builtin man pager on K for certain filetypes
au! FileType {sh,bash,zsh,c} {
    runtime ftplugin/man.vim
    legacy let g:ft_man_open_mode = 'tab'
    legacy let g:ft_man_folding_enable = 1
    set keywordprg=:Man
}

" Faster response after being idle
set updatetime=500

" Sets the showing of spaces
"set list
set lcs+=space:·,eol:⤶

" Case insensitivity for filenames/directories
set fileignorecase

" Sets when to start to scroll above/below
set scrolloff=3

" Enables a line that shows the cursor position on y axis
set cursorline

" Enable sync mode
set termsync

" Because performance
augroup fix_Improve_InsertScrolling
    autocmd!
    au InsertEnter * set scrolloff=0 | :ALEToggle
    au InsertLeave * set scrolloff=3 | :ALEToggle
augroup END

func! DeleteAfterwardsCMDLine()
    return getcmdline()->strcharpart(0, getcmdpos()-1)
endfunc

" Opens a new tab dynamically
" with git changes opened with delta
au VimEnter */COMMIT_EDITMSG ++once {
    execute("tab terminal")

    # Disable the history and run showCommitDiff.bash then
    # automatically close the terminal from inside the script
    call feedkeys("
    \    set +o history; clear;
    \    source ~/.vim/showCommitDiff.bash\<cr>"
    \)
    call feedkeys("\<C-x>:tabprevious\<cr>")
    # Needed because feedkeys is async
    au BufEnter */COMMIT_EDITMSG ++once
                \ call feedkeys(
                \     getline(1) == ""
                \         ? "\<C-home>i" : "\<C-home>"
                \ )
}

" Small tweaks only for
" the file called COMMIT_EDITMSG
augroup CommitMessageTweaks
    autocmd!
    au WinEnter */.git/COMMIT_EDITMSG ++once {
        &textwidth = &columns - 20
    }
    au BufWritePost */.git/COMMIT_EDITMSG ++once set spell
    au BufRead      */.git/COMMIT_EDITMSG ++once set noundofile
augroup END

" Only for edit-and-execute-command
au BufRead */usr/tmp/bash-fc.* ++once {
    if getline(1) =~ "^node -e"
        set filetype=javascript
    else
        set filetype=bash
    endif
}

" No wrapping lines
set nowrap

" Change special termwinkey to
" something unused by bash
set termwinkey=<C-x>

" Timeout for waiting before the next key sequence
" Do not au!, it breaks colors
au VimEnter * ++once set timeoutlen=350 | set ttimeoutlen=350

" Auto Ctrl-n
" set autocomplete
" set autocompletedelay=250

" Confirm on unsaved changes
set confirm

" Persistent undo history
set undofile
set undodir=~/.vim/undo_history/

augroup BashFiles
    autocmd!
    au VimEnter,WinEnter,BufRead */.bashrc,*.bash,*/.bash_* {
        set foldmethod=indent
        set syntax=bash
    }
    " Fixes lf syntax when using bash syntax
    au VimEnter lfrc ++once set syntax=bash | set syntax=lf
augroup END

" Enables comment-install plugin
packadd comment

" Sets folding
set foldlevel=99
set foldmethod=syntax

" Set numbers
set numberwidth=1
set relativenumber

" Also save window position in sessions
set sessionoptions+=winpos

" Sets how many lines of history VIM has to remember
set history=500

" Enable filetype plugins
" also shows language keyword on Ctrl-x Ctrl-o
filetype plugin on
filetype indent on

" Set to auto read when a file is changed from the outside
set autoread
au! FocusGained,BufEnter * checktime

" With a map leader it's possible to do extra key combinations
" like <leader>w saves the current file
let mapleader = ","

" :W sudo saves the file
" (useful for handling the permission-denied error)
command! W execute 'w !sudo tee % > /dev/null' <bar> edit!

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => VIM user interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Avoid garbled characters in Chinese language windows OS
let $LANG='en'
set langmenu=en
source $VIMRUNTIME/delmenu.vim
source $VIMRUNTIME/menu.vim

" Turn on the Wild menu
set wildmenu

" Ignore compiled files
set wildignore=*.o,*~,*.pyc
if has("win16") || has("win32")
    set wildignore+=.git\*,.hg\*,.svn\*
else
    set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store
endif

" Always show current position
set ruler

" Height of the command bar
set cmdheight=1

" A buffer becomes hidden when it is abandoned
set hid

" Configure backspace so it acts as it should act
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

" Ignore case when searching
set ignorecase

" When searching try to be smart about cases
set smartcase

" Highlight search results
set hlsearch

" Makes search act like search in modern browsers
set incsearch

" Don't redraw while executing macros (good performance config)
set lazyredraw

" For regular expressions turn magic on
set magic

" Show matching brackets when text indicator is over them
set showmatch

" How many tenths of a second to blink when matching brackets
set mat=2

" No annoying sound on errors
set noerrorbells
set novisualbell
set t_vb=
set tm=500

" Properly disable sound on errors on MacVim
if has("gui_macvim")
    autocmd! GUIEnter * set vb t_vb=
endif

" Add a bit extra margin to the left
set foldcolumn=1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Colors and Fonts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Enable syntax highlighting
syntax enable

"try
"    colorscheme desert
"catch
"endtry

set background=dark

" Set utf8 as standard encoding and en_US as the standard language
set encoding=utf8

" Use Unix as the standard file type
set ffs=unix,dos,mac

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Files, backups and undo
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Turn backup off, since most stuff is in SVN, git etc. anyway...
set nobackup
set nowb
set noswapfile

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text, tab and indent related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Use spaces instead of tabs
set expandtab

" Be smart when using tabs ;)
set smarttab

" 1 tab == 4 spaces
set shiftwidth=4
set tabstop=4

" Linebreak on 500 characters
set lbr
set tw=500

set ai "Auto indent
set si "Smart indent

""""""""""""""""""""""""""""""
" => Visual mode related
""""""""""""""""""""""""""""""
" Visual mode pressing * or # searches for the current selection
" Super useful! From an idea by Michael Naumann
vnoremap <silent> * :<C-u>call VisualSelection('', '')<CR>/<C-R>=@/<CR><CR>
vnoremap <silent> # :<C-u>call VisualSelection('', '')<CR>?<C-R>=@/<CR><CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Moving around, tabs, windows and buffers
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Map <Space> to / (search) and Ctrl-<Space> to ? (backwards search)
map <space> /

" Smart way to move between windows
"map <C-h> <C-W>h
"map <C-l> <C-W>l

" Close the current buffer
noremap <leader>bd :Bclose<cr>:tabclose<cr>gT

" Close all the buffers
noremap <leader>ba :bufdo bd<cr>
noremap <leader>l :bnext<cr>
noremap <leader>h :bprevious<cr>

" Useful mappings for managing tabs
noremap <leader>to :tabonly<cr>
noremap <leader>tm :tabmove<space>

" Let 'tl' toggle between this and the last accessed tab
" let g:lasttab = 1
" nmap <Leader>tl :exe "tabn ".g:lasttab<CR>
" au! TabLeave * let g:lasttab = tabpagenr()

" Opens a new tab with the current buffer's path
" Super useful when editing files in the same directory
noremap <leader>te :tabedit <C-r>=expand("%:p:h")<cr>/

" Switch CWD to the directory of the open buffer
noremap <leader>cd :cd %:p:h<cr>:pwd<cr>

" Specify the behavior when switching between buffers
try
  set switchbuf=useopen,usetab,newtab showtabline=2
catch
endtry

" Return to last edit position when opening files (You want this!)
au! BufReadPost * {
    if line("'\"") > 1 && line("'\"") <= line("$")
        execute "normal! g'\""
    endif
}

""""""""""""""""""""""""""""""
" => Status line
""""""""""""""""""""""""""""""
" Always show the status line
set laststatus=2

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Editing mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Remap VIM 0 to first non-blank character
map 0 ^

if has("autocmd")
    " Delete trailing white space on save, useful for some filetypes ;)
    fun! CleanExtraSpaces()
        let save_cursor = getpos(".")
        let old_query = getreg('/')
        silent! %s/\s\+$//e
        call setpos('.', save_cursor)
        call setreg('/', old_query)
    endfun

    autocmd! BufWritePre */COMMIT_EDITMSG,*.{
        \txt,
        \js,mjs,mts,ts,d.ts,
        \sh,bash,ps1,
        \py,wiki,coffee
    \}
        \ call CleanExtraSpaces()
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Misc
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Remove the Windows ^M - when the encodings gets messed up
noremap <Leader>m mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Helper functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Don't close window, when deleting a buffer
command! Bclose call <SID>BufcloseCloseIt()
function! <SID>BufcloseCloseIt()
    let l:currentBufNum = bufnr("%")
    let l:alternateBufNum = bufnr("#")

    if buflisted(l:alternateBufNum)
        buffer #
    else
        bnext
    endif

    if bufnr("%") == l:currentBufNum
        new
    endif

    if buflisted(l:currentBufNum)
        execute("bdelete! ".l:currentBufNum)
    endif
endfunc

function! VisualSelection(direction, extra_filter) range
    let l:saved_reg = @"
    execute "normal! vgvy"

    let l:pattern = escape(@", "\\/.*'$^~[]")
    let l:pattern = substitute(l:pattern, "\n$", "", "")

    let @/ = l:pattern
    let @" = l:saved_reg
endfunc

" ALE
let g:ale_set_signs = v:false
let g:ale_virtualtext_cursor = 0
let g:ale_update_tagstack = 1

" tsserver is default for js
let g:ale_linters = {
\   "javascript": ["quick-lint-js", "deno"],
\   "typescript": ["tsc"],
\   "markdown": ["pandoc"],
\   "vim": ["vint"]
\}
" vim-javascript
let g:javascript_plugin_jsdoc = 1

" Fixes performance
augroup javascript_folding
    autocmd!
    au FileType javascript setlocal foldmethod=indent
augroup END

" GitGutter
let g:gitgutter_map_keys = 0
let g:gitgutter_highlight_linenrs = 1
let g:gitgutter_close_preview_on_escape = 1
let g:gitgutter_sign_modified = '✍'
let g:gitgutter_sign_removed  = '⌇'

hi DiffAdd ctermfg=10

" Airline settings
let g:airline_extensions = []
" let g:airline_experimental = 1
let g:airline_exclude_preview = 0
let g:airline_detect_spelllang = 0
let g:airline_highlighting_cache = 1

let g:airline_left_sep = ''
let g:airline_right_sep = ''
let g:airline_powerline_fonts = 1
let g:airline_section_c_only_filename = 1
let g:airline_section_y = ""
let g:airline_theme = "custumark"

" Fixes mode's width and removes useless stuff
au! User AirlineAfterInit ++once {
    const crypt = "\%\{airline#util#append\(airline#parts#crypt\(\),0\)\}"
    const iminsert = "\%\{airline#util#append\(airline#parts#iminsert\(\),0\)\}"
    g:airline_section_a = (
        g:airline_section_a
            ->substitute(crypt, "", "")
            ->substitute(iminsert, "", "")
    )
    call airline#parts#define_minwidth('mode', 0)
}

" python-syntax
let g:python_highlight_all = 1

" Undotree
let g:undotree_TreeNodeShape   = "↑"
let g:undotree_TreeReturnShape = "╲"
let g:undotree_TreeVertShape   = "│"
let g:undotree_TreeSplitShape  = "╱"
let g:undotree_SetFocusWhenToggle = 1
let g:undotree_ShortIndicators = 1

call plug#begin()
    " Format normal text
    Plug 'godlygeek/tabular', { 'on': 'Tabularize' }
    " Git plugin
    Plug 'tpope/vim-fugitive', { 'on': 'Git' }
    " status line plugin
    Plug 'vim-airline/vim-airline'
    " An interface for all undo commands
    Plug 'mbbill/undotree', { 'on': 'UndotreeToggle' }
    " snippets plugin
    Plug 'garbas/vim-snipmate'
        " snipmate dependency
        Plug 'MarcWeber/vim-addon-mw-utils'
    " Second git plugin that is a bit more useful/practical
    Plug 'airblade/vim-gitgutter'
    " Javascript syntax highlighting
    Plug 'pangloss/vim-javascript', { 'for': 'javascript' }
    " Same for JSON
    Plug 'elzr/vim-json', { 'for': 'json' }
    " Same for lua
    Plug 'tbastos/vim-lua', { 'for': 'lua' }
    " Same for markdown + other niceties
    Plug 'preservim/vim-markdown', { 'for': 'markdown' }
    Plug 'vim-python/python-syntax', { 'for': 'python' }
    " Indentation detection plugin
    Plug 'tpope/vim-sleuth'
    "Plug 'lverweijen/vim-irreplaceable'
    "Plug 'wfxr/minimap.vim'
    "Plug 'eliba2/vim-node-inspect'
call plug#end()

" Fixes vim-javascript's mess up with shebangs (#!)
func! <SNR>21_SelectJavascript()
    if bufname() !~# '\v\.(ts|tsx|mts)$'
       \ && getline(1) =~# '^#!.*/bin/\%(env\s\+\)\?node\>'
        set filetype=javascript
    endif
endfunc

" All my keybindings
autocmd BufRead .vim-inputrc set filetype=vim
source ~/.vim-inputrc

