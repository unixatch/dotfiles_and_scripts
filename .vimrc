" Sets always a blinking bar
let &t_SI .= "\<Esc>[5 q"
let &t_SR .= "\<Esc>[5 q"
let &t_EI .= "\<Esc>[5 q"

" Basically the default without l
set shortmess=finxtToOS

" Fixes termguicolors
au! VimEnter * source ~/.vim-colors | set termguicolors
au! BufRead */.vim-colors set syntax=vim

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

" Opens a new tab dynamically
" with git changes opened in less
augroup showChanges_Alongside_GitCommitMessage
    autocmd!
    function AddTerminal()
        let cwd = getcwd()
        let isStaged = "[[ -n \"${ git status --porcelain; }\" ]]"
        let unsetAndExit = "unset HISTFILE && exit;"
        execute(":tab terminal")

        " cd into the cwd and cls || exit with 1
        " THEN show the staged changes
        "   OR show at least the last commit's changes
        " AFTER that exit without saving the history
        call feedkeys("
        \   cd ".cwd." && cls || exit 1 \<cr>
        \   ".isStaged." && {
        \      git dc | delta --paging always;
        \      ".unsetAndExit."
        \   } || {
        \      git show; ".unsetAndExit."
        \   } \<cr>
        \")
        call feedkeys("\<C-x>:tabprevious | 1\<cr>")
        " Needed because feedkeys is async
        au BufEnter */COMMIT_EDITMSG
            \call feedkeys(getline(1) == "" ? "i" : "")
    endfunc
    au VimEnter */COMMIT_EDITMSG call AddTerminal()
augroup END

" Small tweaks only for
" the file called COMMIT_EDITMSG
augroup CommitMessageTweaks
    autocmd!
    func! SetTextWidth()
        let columns = execute(":set columns?")->substitute("^.*=", "", "")
        let maxWidth=columns-20
        let &textwidth=maxWidth
    endfunc
    au BufRead */.git/COMMIT_EDITMSG set noundofile
    au BufWritePost */.git/COMMIT_EDITMSG set spell
    au WinEnter */.git/COMMIT_EDITMSG call SetTextWidth()
augroup END

" Only for edit-and-execute-command
augroup Bash_EditAndExecuteCommand
    autocmd!
    function ChangeFileType()
        if getline("1") =~ "^node -e"
            set filetype=javascript
            return
        endif
        set filetype=bash
    endfunc
    au BufRead */usr/tmp/bash-fc.* call ChangeFileType()
augroup END

" No wrapping lines
set nowrap

" Change special termwinkey to
" something unused by bash
set termwinkey=<C-x>

" Timeout for waiting before the next key sequence
" Do not au!, it breaks colors
au VimEnter * set timeoutlen=350 | set ttimeoutlen=350

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
    au VimEnter,WinEnter,BufRead 
        \*.bash,
        \*/.bash_functions,
        \*/.bash_aliases,
        \*/.bashrc,
        \*/.bash_profile set foldmethod=indent | set syntax=bash
    " Fixes lf syntax when using bash syntax
    au VimEnter */lfrc set syntax=bash | set syntax=lf
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

" Fast saving
"nmap <leader>w :w!<cr>

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

" Enable 256 colors palette in Gnome Terminal
if $COLORTERM == 'gnome-terminal'
    set t_Co=256
endif

"try
"    colorscheme desert
"catch
"endtry

set background=dark

" Set extra options when running in GUI mode
if has("gui_running")
    set guioptions-=T
    set guioptions-=e
    set t_Co=256
    set guitablabel=%M\ %t
endif

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
" set wrap "Wrap lines


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
map <C-space> ?

" Disable highlight when <leader><cr> is pressed
map <silent> <leader><cr> :noh<cr>

" Smart way to move between windows
"map <C-h> <C-W>h
"map <C-l> <C-W>l

" Close the current buffer
map <leader>bd :Bclose<cr>:tabclose<cr>gT

" Close all the buffers
map <leader>ba :bufdo bd<cr>

map <leader>l :bnext<cr>
map <leader>h :bprevious<cr>

" Useful mappings for managing tabs
map <leader>tn :tabnew<cr>
map <leader>to :tabonly<cr>
map <leader>tc :tabclose<cr>
map <leader>tm :tabmove
map <leader>t<leader> :tabnext

" Let 'tl' toggle between this and the last accessed tab
let g:lasttab = 1
nmap <Leader>tl :exe "tabn ".g:lasttab<CR>
au! TabLeave * let g:lasttab = tabpagenr()


" Opens a new tab with the current buffer's path
" Super useful when editing files in the same directory
map <leader>te :tabedit <C-r>=expand("%:p:h")<cr>/

" Switch CWD to the directory of the open buffer
map <leader>cd :cd %:p:h<cr>:pwd<cr>

" Specify the behavior when switching between buffers
try
  set switchbuf=useopen,usetab,newtab
  set stal=2
catch
endtry

" Return to last edit position when opening files (You want this!)
au! BufReadPost * 
    \if line("'\"") > 1 && line("'\"") <= line("$")
        \| exe "normal! g'\""
    \| endif


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

" Delete trailing white space on save, useful for some filetypes ;)
fun! CleanExtraSpaces()
    let save_cursor = getpos(".")
    let old_query = getreg('/')
    silent! %s/\s\+$//e
    call setpos('.', save_cursor)
    call setreg('/', old_query)
endfun

if has("autocmd")
    autocmd! BufWritePre 
        \*/COMMIT_EDITMSG,*.txt,*.ps1,*.mjs,*.js,*.py,*.wiki,*.sh,*.bash,*.coffee 
        \call CleanExtraSpaces()
endif


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Spell checking
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Pressing ,ss will toggle and untoggle spell checking
map <leader>ss :setlocal spell!<cr>

" Shortcuts using <leader>
map <leader>sn ]s
map <leader>sp [s
map <leader>sa zg
map <leader>s? z=


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Misc
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Remove the Windows ^M - when the encodings gets messed up
noremap <Leader>m mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm

" Quickly open a buffer for scribble
map <leader>q :e ~/buffer<cr>

" Quickly open a markdown buffer for scribble
map <leader>x :e ~/buffer.md<cr>

" Toggle paste mode on and off
map <leader>pp :setlocal paste!<cr>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Helper functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Returns true if paste mode is enabled
function! HasPaste()
    if &paste
        return 'PASTE'
    endif
    return ''
endfunc

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

function! CmdLine(str)
    call feedkeys(":" . a:str)
endfunc

function! VisualSelection(direction, extra_filter) range
    let l:saved_reg = @"
    execute "normal! vgvy"

    let l:pattern = escape(@", "\\/.*'$^~[]")
    let l:pattern = substitute(l:pattern, "\n$", "", "")

    if a:direction == 'gv'
        call CmdLine("Ack '" . l:pattern . "' " )
    elseif a:direction == 'replace'
        call CmdLine("%s" . '/'. l:pattern . '/')
    endif

    let @/ = l:pattern
    let @" = l:saved_reg
endfunc

" ALE
let g:ale_set_signs = v:false
let g:ale_virtualtext_cursor = 0
" tsserver is default for js
let g:ale_linters = {
\    "javascript": ["quick-lint-js", "deno"]
\}
let g:javascript_plugin_jsdoc = 1
" Fixes performance
augroup javascript_folding
    autocmd!
    au FileType javascript setlocal foldmethod=indent
augroup END

" GitGutter
let g:gitgutter_highlight_linenrs = 1
let g:gitgutter_close_preview_on_escape = 1
let g:gitgutter_sign_modified = '✍'
let g:gitgutter_sign_removed  = '⌇'

" Airline settings
let g:airline_extensions = []
let g:airline_experimental = 1
let g:airline_highlighting_cache = 1
let g:airline_left_sep = ''
let g:airline_right_sep = ''
let g:airline_powerline_fonts = 1
let g:airline_section_c_only_filename = 1
let g:airline_theme = "custumark"

" Fixes mode's width
au! User AirlineAfterInit 
    \call airline#parts#define_minwidth('mode', 0)

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
    Plug 'vim-airline/vim-airline'
    Plug 'mbbill/undotree'
    Plug 'MarcWeber/vim-addon-mw-utils'
    Plug 'garbas/vim-snipmate'
    Plug 'airblade/vim-gitgutter'
    Plug 'lverweijen/vim-irreplaceable'
    Plug 'pangloss/vim-javascript'
    Plug 'elzr/vim-json'
    Plug 'tbastos/vim-lua'
    Plug 'preservim/vim-markdown'
    Plug 'vim-python/python-syntax'
    Plug 'tpope/vim-sleuth'
    "Plug 'wfxr/minimap.vim'
    "Plug 'eliba2/vim-node-inspect'
call plug#end()

" All my keybindings
autocmd BufRead .vim-inputrc set filetype=vim
source ~/.vim-inputrc
