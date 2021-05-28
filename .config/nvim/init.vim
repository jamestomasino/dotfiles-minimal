""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""""""""""""""""""""""""""""""""""" BUNDLES """""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

filetype off

call plug#begin('$XDG_DATA_HOME/vim/plugged')

" Global
Plug 'embear/vim-localvimrc'

" lsp
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'kabouzeid/nvim-lspinstall'
Plug 'hrsh7th/nvim-compe'
Plug 'glepnir/lspsaga.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" Styling
Plug 'pgdouyon/vim-yin-yang'              " A minimalist b+w theme
Plug 'sainnhe/sonokai'

" Writing/Authoring Tools
Plug 'reedes/vim-pencil'                  " Super-powered writing things
Plug 'tpope/vim-abolish'                  " Fancy abbreviation replacements
Plug 'junegunn/goyo.vim'                  " Full screen writing mode

" Development Tools
Plug 'tpope/vim-commentary'               " gcc to toggle comments
Plug 'airblade/vim-gitgutter'             " git changes
Plug 'tpope/vim-fugitive'                 " git wrapper
Plug 'zaid/vim-rec'                       " GNU Recutils syntax highlighting
Plug 'storyn26383/vim-vue'                " vue support beyond LSP

call plug#end()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""" FUNCTIONS """"""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! InitDirs()
    let l:parent = $XDG_DATA_HOME
    let l:prefix = 'vim'
    let l:dir_list = {
                \ 'backup': 'backupdir',
                \ 'views': 'viewdir',
                \ 'swap': 'directory' }

    if has('persistent_undo')
        let l:dir_list['undo'] = 'undodir'
    endif

    let l:common_dir = l:parent . '/' . l:prefix

    for [l:dirname, l:settingname] in items(l:dir_list)
        let l:directory = l:common_dir . l:dirname . '/'
        if exists('*mkdir')
            if !isdirectory(l:directory)
                call mkdir(l:directory)
            endif
        endif
        if !isdirectory(l:directory)
            echo 'Warning: Unable to create backup directory: ' . l:directory
            echo 'Try: mkdir -p ' . l:directory
        else
            let l:directory = substitute(l:directory, ' ', '\\\\ ', 'g')
            exec 'set ' . l:settingname . '=' . l:directory
        endif
    endfor
endfunction
call InitDirs()

function! StripTrailingWhitespace()
    if !&binary && &filetype != 'diff'
        normal mz
        normal Hmy
        %s/\s\+$//e
        normal 'yz<CR>
        normal `z
    endif
endfunction

function! MyHighlights() abort
    highlight clear SignColumn      " SignColumn should match background
    highlight clear LineNr          " Current line number row will have same background color in relative mode
    highlight clear CursorLineNR    " disable color block on curretn line
endfunction

function! Print()
    let &printheader = " "
    hardcopy > %:r.ps
    !ps2pdf %:r.ps
    !rm %:r.ps
endfunction

function! AsciiMode()
  syntax off
  setlocal virtualedit=all
  setlocal cc=80
  hi ColorColumn ctermbg=8 guibg=8
  autocmd BufWritePre * :%s/\s\+$//e
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""""""""""""""""""""""""""""""""""" AUTOCMD """""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if has('autocmd')

    autocmd BufReadPost * if @% !~# '\.git[\/\\]COMMIT_EDITMSG$' && line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif

    augroup mjml
        autocmd!
        autocmd BufNewFile,BufRead *.mjml   set filetype=html
    augroup END

    augroup func_whitespace
        autocmd!
        autocmd filetype c,markdown,cpp,java,go,php,javascript,python,twig,text,xml,yml autocmd BufWritePre <buffer> call StripTrailingWhitespace()
    augroup END

    augroup type_gitcommit
        autocmd!
        autocmd filetype gitcommit call setpos('.', [0, 1, 1, 0])
        autocmd filetype gitcommit au! BufEnter COMMIT_EDITMSG call setpos('.', [0, 1, 1, 0])
    augroup END

    augroup type_html
        autocmd!
        autocmd filetype html setlocal shiftwidth=2
        autocmd filetype html setlocal softtabstop=2
        autocmd filetype html setlocal tabstop=2
        autocmd filetype html setlocal noexpandtab
        autocmd filetype html setlocal foldmethod=syntax
    augroup END

    augroup type_awk
        autocmd!
        autocmd filetype awk setlocal shiftwidth=2
        autocmd filetype awk setlocal softtabstop=2
        autocmd filetype awk setlocal tabstop=2
        autocmd filetype awk setlocal noexpandtab
        autocmd filetype awk setlocal foldmethod=syntax
    augroup END

    augroup type_javascript
        autocmd!
        autocmd filetype javascript setlocal shiftwidth=2
        autocmd filetype javascript setlocal softtabstop=2
        autocmd filetype javascript setlocal tabstop=2
        autocmd filetype javascript setlocal expandtab
        autocmd filetype javascript setlocal foldmethod=syntax
        autocmd BufWritePre *.js lua vim.lsp.buf.formatting_sync(nil, 100)
        autocmd BufWritePre *.jsx lua vim.lsp.buf.formatting_sync(nil, 100)
    augroup END

    augroup type_vue
        autocmd!
        let g:vue_disable_pre_processors=1
        autocmd filetype vue syntax sync fromstart
    augroup END

    augroup type_haskell
        autocmd!
        autocmd filetype haskell compiler ghc
        autocmd filetype haskell setlocal shiftwidth=2
        autocmd filetype haskell setlocal expandtab
        autocmd filetype haskell let g:haskell_enable_quantification = 1   " to enable highlighting of `forall`
        autocmd filetype haskell let g:haskell_enable_recursivedo = 1      " to enable highlighting of `mdo` and `rec`
        autocmd filetype haskell let g:haskell_enable_arrowsyntax = 1      " to enable highlighting of `proc`
        autocmd filetype haskell let g:haskell_enable_pattern_synonyms = 1 " to enable highlighting of `pattern`
        autocmd filetype haskell let g:haskell_enable_typeroles = 1        " to enable highlighting of type roles
        autocmd filetype haskell let g:haskell_enable_static_pointers = 1  " to enable highlighting of `static`
        autocmd filetype haskell let g:haskell_backpack = 1                " to enable highlighting of backpack keywords
    augroup END

    augroup type_css
        autocmd!
        autocmd filetype css,scss setlocal noexpandtab
        autocmd filetype css,scss setlocal softtabstop=2
        autocmd filetype css,scss setlocal shiftwidth=2
        autocmd filetype css,scss setlocal tabstop=2
    augroup END

    augroup type_python
        autocmd!
        autocmd filetype python setlocal expandtab
        autocmd filetype python setlocal softtabstop=4
        autocmd filetype python setlocal shiftwidth=4
        autocmd filetype python setlocal tabstop=4
    augroup END

    augroup type_json
        autocmd!
        autocmd filetype json setlocal equalprg=python3\ -m\ json.tool
    augroup END

    augroup type_make
        autocmd!
        autocmd filetype make setlocal noexpandtab
        autocmd filetype make setlocal softtabstop=4
        autocmd filetype make setlocal shiftwidth=4
        autocmd filetype make setlocal tabstop=4
    augroup END

    augroup bundle_rmarkdown
        autocmd!
        autocmd filetype Rmd setlocal expandtab
        autocmd filetype Rmd setlocal softtabstop=4
        autocmd filetype Rmd setlocal shiftwidth=4
        autocmd filetype Rmd setlocal tabstop=4
    augroup END

    augroup bundle_php
        autocmd!
        autocmd filetype php setlocal expandtab
        autocmd filetype php setlocal softtabstop=2
        autocmd filetype php setlocal shiftwidth=2
        autocmd filetype php setlocal tabstop=2
    augroup END

    augroup gemini
        autocmd!
        autocmd BufNewFile,BufRead *.gmi   set filetype=gemini
        autocmd filetype gemini call pencil#init()
                    \ | setl spell spl=en_us fdl=4 noru nonu nornu
                    \ | setl fdo+=search
    augroup END

    augroup pencil
        autocmd!
        autocmd filetype markdown,mkd call pencil#init()
                    \ | setl spell spl=en_us fdl=4 noru nonu nornu
                    \ | setl fdo+=search
    augroup END

    augroup mycolors
        autocmd!
        autocmd ColorScheme * call MyHighlights()
    augroup END

endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""" SETTINGS """""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" General Lets {{{
let g:mapleader = ','
let b:match_ignorecase = 1
" }}}

" miscelanious settings {{{
filetype plugin indent on       " Automatically detect file types.
syntax on                       " Syntax highlighting
set encoding=utf-8
scriptencoding utf-8
" }}}

" Indent Guides {{{
let g:indent_guides_start_level = 2
let g:indent_guides_guide_size = 1
let g:indent_guides_enable_on_vim_startup = 0
" }}}

" Pencil / Writing Controls {{{
let g:pencil#wrapModeDefault = 'soft'
let g:pencil#textwidth = 74
let g:pencil#joinspaces = 0
let g:pencil#cursorwrap = 1
let g:pencil#conceallevel = 3
let g:pencil#concealcursor = 'c'
let g:pencil#softDetectSample = 20
let g:pencil#softDetectThreshold = 130
let g:pencil_terminal_italics = 1
let g:pencil_gutter_color = 1
let g:pencil_neutral_code_bg = 0
" }}}

" Local vimrc loading {{{
let g:localvimrc_sandbox=0
let g:localvimrc_ask=0
" }}}

" ag support {{{
if executable("ag")
    set grepprg=ag\ --ignore\ --nogroup\ --nocolor\ --ignore-case\ --column
    set grepformat=%f:%l:%c:%m,%f:%l:%m
endif
" }}}

" sets {{{
set autoindent                  " Indent at the same level of the previous line
set backspace=indent,eol,start  " Backspace for dummies
set background=dark             " Use dark theme
set t_Co=256
set backup                      " Backups are nice ...
set clipboard^=unnamed,unnamedplus
set colorcolumn=80
set completeopt=noinsert,menuone,noselect
set cursorline                  " Highlight current line
set expandtab
set fileencoding=utf-8
set foldlevelstart=20
set foldmethod=manual
set hidden                      " Allow buffer switching without saving
set history=1000                " Store a ton of history (default is 20)
set hlsearch                    " Highlight search terms
set ignorecase                  " Case insensitive search
set incsearch                   " Find as you type search
set lazyredraw
set linespace=0                 " No extra spaces between rows
set list
set listchars=tab:›\ ,trail:•,extends:#,nbsp:. " Highlight problematic whitespace
set mouse=                      " Automatically disable mouse usage
set mousehide                   " Hide the mouse cursor while typing
set nojoinspaces                " Prevents inserting two spaces after punctuation on a join (J)
set noshowcmd                   " Don't show the current command
set nowrap                      " Do not wrap long lines
set relativenumber number       " Use relative line numbers
set scrolljump=5                " Lines to scroll when cursor leaves screen
set scrolloff=3                 " Minimum lines to keep above and below cursor
set shiftwidth=2
set shortmess+=caoOtTI           " Abbrev. of messages (avoids 'hit enter')
set showmatch                   " Show matching brackets/parenthesis
set showmode                    " Display the current mode
set softtabstop=2
set splitbelow                  " Puts new split windows to the bottom of the current
set splitright                  " Puts new vsplit windows to the right of the current
set tabpagemax=15               " Only show 15 tabs
set tags=./tags,tags;$HOME
set viewoptions=folds,options,cursor,unix,slash " Better Unix / Windows compatibility
set virtualedit=onemore         " Allow for cursor beyond last character
set whichwrap=b,s,h,l,<,>,[,]   " Backspace and cursor keys wrap too
set wildmenu
set wildmode=list:longest,full  " Command <Tab> completion, list matches, then longest common part, then all.
set winminheight=0              " Windows can be 0 line high

if exists('+termguicolors')
  set termguicolors
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif

colorscheme sonokai

" }}}

" conditional settings {{{
if has('persistent_undo')
    set undofile                " So is persistent undo ...
    set undolevels=1000         " Maximum number of changes that can be undone
    set undoreload=10000        " Maximum number lines to save for undo on a buffer reload
endif
" }}}

" Statusline {{{
hi statusline guifg=black guibg=#8fbfdc ctermfg=black ctermbg=cyan

set laststatus=2
set noshowmode
set statusline=
set statusline+=%0*\ %n\                                    " Buffer number
set statusline+=%1*\ %<%F%m%r%h%w\                          " File path, modified, readonly, helpfile, preview
set statusline+=%3*│                                        " Separator
set statusline+=%=                                          " Right Side
set statusline+=%2*%y                                       " FileType
set statusline+=\ [%{&ff}:                                  " FileFormat (dos/unix..)
set statusline+=%2*%{''.(&fenc!=''?&fenc:&enc).''}]         " Encoding
set statusline+=%3*│                                        " Separator
set statusline+=%1*\ %02v×%02l/%L\                          " Column×Line Number/Total Lines

hi User1 ctermfg=007 ctermbg=239 guibg=#4e4e4e guifg=#adadad
hi User2 ctermfg=007 ctermbg=236 guibg=#303030 guifg=#adadad
hi User3 ctermfg=236 ctermbg=236 guibg=#303030 guifg=#303030
hi User4 ctermfg=239 ctermbg=239 guibg=#4e4e4e guifg=#4e4e4e
hi User5 ctermfg=255 ctermbg=009 guibg=#e10000 guifg=#ffffff
" }}}

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""" MAPPINGS """""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Tweak existing keys for more natural operation {{{
noremap <silent> <expr> j (v:count == 0 ? 'gj' : 'j')
noremap <silent> <expr> k (v:count == 0 ? 'gk' : 'k')
nnoremap Y y$
xnoremap < <gv
xnoremap > >gv
xnoremap . :normal .<CR>
" }}}

" Delete and put with black hole register {{{
xnoremap <Leader>p "_dP
nnoremap <Leader>d "_d
xnoremap <Leader>d "_d
set pastetoggle=<Leader>z
" }}}

" Buffers {{{
nnoremap <Leader>a <cmd>Telescope find_files<cr>
nnoremap <Leader>b <cmd>Telescope buffers<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
nnoremap <Leader>s :b#<CR>
nnoremap <leader>w :bd<CR>
" }}}

" Make {{{
nnoremap <Leader>m :make<CR>
" }}}

" Gophermap mappings {{{
nnoremap <Leader>gl :PencilOff<CR>:set tw=9999<CR>
nnoremap <Leader>gm :PencilHard<CR>:set tw=66<CR>
" }}}

" Plugin mappings {{{
xnoremap <Enter> <Plug>(EasyAlign)
" }}}

" Insert Date for notes {{{
nnoremap <Leader>gs :pu! =strftime('%Y-%m-%d')<CR>A<space>
" }}}

" Move blocks up and down {{{
xnoremap <C-Up> xkP`[V`]
xnoremap <C-Down> xp`[V`]
nnoremap <C-Up> ddkP
nnoremap <C-Down> ddp
" }}}

" Fold selection {{{
nnoremap <Leader><space> za
xnoremap <Leader><Space> zf
" }}}

" Splits {{{
nnoremap <Leader>\| :vsp<CR>
nnoremap <Leader>- :sp<CR>
nnoremap <Leader>j <C-W><C-J>
nnoremap <Leader>k <C-W><C-K>
nnoremap <Leader>l <C-W><C-L>
nnoremap <Leader>h <C-W><C-H>
nnoremap <Leader>J :resize +5<CR>
nnoremap <Leader>K :resize -5<CR>
nnoremap <Leader>H :vertical resize -5<CR>
nnoremap <Leader>L :vertical resize +5<CR>
" }}}

" File actions {{{
cnoremap %% <C-R>=expand('%:h').'/'<CR>
" }}}

" Diff conflict actions {{{
nnoremap <Leader>cn ]cn                 " next conflict
nnoremap <Leader>cN [c                  " prev conflict
nnoremap <Leader>cc :diffupdate<CR>     " update diffs
nnoremap <Leader>ch :diffget //2<CR>    " keep local contents (left)
nnoremap <Leader>cl :diffget //3<CR>    " use merge contents (right)
" }}}

" Spelling actions {{{
nnoremap <Leader>cs ]s                  " next misspelled word
nnoremap <Leader>cS [s                  " prev misspelled word
" }}}

" command mode helpers {{{
cnoremap w!! w !sudo tee % >/dev/null
cnoremap cd. lcd %:p:h
" }}}

" clear search results {{{
nnoremap <silent> <Leader>/ :nohlsearch<CR>
" }}}

" LSP config
lua require('init')

nnoremap <silent>K :Lspsaga hover_doc<CR>
nnoremap <silent> <C-f> <cmd>lua require('lspsaga.action').smart_scroll_with_saga(1)<CR>
nnoremap <silent> <C-b> <cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1)<CR>
nnoremap <silent><leader>gr :Lspsaga rename<CR>
nnoremap <silent><leader>ca :Lspsaga code_action<CR>
vnoremap <silent><leader>ca :<C-U>Lspsaga range_code_action<CR>
nnoremap <silent><leader>gd :Lspsaga preview_definition<CR>
nnoremap <silent>gd <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent>gD <cmd>lua vim.lsp.buf.declaration()<CR>
nnoremap <silent>gi <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent>gr <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent><C-n> :Lspsaga diagnostic_jump_next<CR>
nnoremap <silent><C-p> :Lspsaga diagnostic_jump_prev<CR>
nnoremap <silent><leader>t :Lspsaga open_floaterm<CR>
nnoremap <silent><leader>T <C-\><C-n>:Lspsaga close_floaterm<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""""""""""""""""""""""""""" LOCAL OVERRIDES """""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if filereadable(expand('~/.vimrc.local'))
    source ~/.vimrc.local
endif

" vim: set sw=4 sts=4 et tw=78 nospell:
