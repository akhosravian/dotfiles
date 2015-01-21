"Andrew Khosravian's .vimrc
let mapleader = ","
"Pathogen
execute pathogen#infect()
filetype plugin indent on
"store temporary files not in a non annoying location
if has("unix")
	set directory=~/.vim/tmp/
else
	set directory=%TMP%
endif

"Change the default font
if has("unix")
	set gfn=Meslo\ LG\ M\ for\ Powerline:h14
else
	set gfn=Consolas:h10:cANSI
endif

"powerline
"python from powerline.vim import setup as powerline_setup
"python powerline_setup()
"python del powerline_setup

" disable tabs in macvim
autocmd BufWinEnter,BufNewFile * silent tabo

set tabstop=4
set shiftwidth=4
set smartcase
set ignorecase
set expandtab
syntax on
set ic
set hlsearch
set incsearch

" Python files always use spaces for tabs
au Filetype python setlocal expandtab tabstop=4 shiftwidth=4 softtabstop=4
au BufRead,BufNewFile *.fx		set filetype=fx

"for golang
filetype off
filetype plugin indent off
set runtimepath+=/usr/local/go/misc/vim
filetype plugin indent on
syntax on
autocmd FileType go compiler go
autocmd FileType go autocmd BufWritePre <buffer> Fmt

set cindent
colors zenburn

"Map space to disable search highlights (without changing other functionality)
nnoremap <space> :noh<return><esc>

" this is busted right now
"set clipboard=unnamed
set hidden

"Macro to load .vimrc and another to reload it after editing
if has("unix")
    map <leader>v :sp ~/.vimrc<CR><C-W>_
    map <silent> ,V :source ~/.vimrc<CR>:filetype detect<CR>:exe ":echo 'vimrc reloaded'"<CR>
else
    map <leader>v :sp ~/_vimrc<CR><C-W>_
    map <silent> ,V :source ~/_vimrc<CR>:filetype detect<CR>:exe ":echo 'vimrc reloaded'"<CR>
endif

"change to directory of the current buffer
map <leader>w :exe ":lcd %:p:h"<CR>:exe ":echo 'changed pwd to current buffers'"<CR>

function! OPEN_FILEBROWSER_CURR_BUFFER()
	if has("unix")
	":h filename-modifiers
	"%:p = full path & file
	"%:p:h = full path
	"%:t = filename only
		exe "!open -R " . expand("%:p:h")
	else
        exe "!start explorer " . expand("%:p:h")
	endif
endfunction
map <leader>t :exe OPEN_FILEBROWSER_CURR_BUFFER()<CR><CR>

"perforce manipulation (edit/revert)
function! P4_EDIT_CURR_FILE() 
	if has("unix")
		exe "!p4 edit %"
	else
		exe "!start p4 edit %"
	endif
endfunction
map <leader>e :exe P4_EDIT_CURR_FILE()<CR>:exe ":echo 'opened file for edit'"<CR>:e %<CR>
map <leader>E :bufdo exe P4_EDIT_CURR_FILE()<CR>:bufdo exe ":e"<CR>

function! P4_REVERT_CURR_FILE() 
	if has("unix")
		exe "!p4 revert %"
	else
		exe "!start p4 revert %"
	endif
endfunction
map <leader>R :exe P4_REVERT_CURR_FILE()<CR>:exe ":echo 'reverted file'"<CR>

" Set a buffer-local variable to the perforce path, if this file is under the
" perforce root.
function! IsUnderPerforce()
    let l:where = system("p4 where " . expand("%"))
    if v:shell_error == 0
        let b:p4path = substitute(l:where, "\\([^ ]*\\).*", "\\1", "")
    endif
endfunction

" Confirm with the user, then checkout a file from perforce.
function! P4Checkout()
    if exists("b:p4path")
        if (confirm("Checkout from Perforce?", "&Yes\n&No", 1) == 1)
            call system("p4 edit " . b:p4path . " > /dev/null")
            if v:shell_error == 0
                set noreadonly
            endif
        endif
    endif
endfunction

if !exists("au_p4_cmd")
   let au_p4_cmd=1
   au BufEnter * call IsUnderPerforce()
   au FileChangedRO * call P4Checkout()
endif

" Based on VIM tip 102: automatic tab completion of keywords
"function! InsertTabWrapper(dir)
"    let col = col('.') - 1
"    if !col || getline('.')[col - 1] !~ '\k'
"        return "\<tab>"
"     elseif "back" == a:dir
"         return "\<c-p>"
"     else
"         return "\<c-n>"
"     endif
"endfunction

map <silent> ,b :TagbarToggle<cr>
  
"inoremap <silent><tab> <c-r>=InsertTabWrapper("fwd")<cr>
"inoremap <silent><s-tab> <c-r>=InsertTabWrapper("back")<cr>

"let g:ycm_server_log_level = 'debug'
let g:ycm_add_preview_to_completeopt = 1
let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_autoclose_preview_window_after_insertion = 1

let g:ctrlp_custom_ignore = '^.*\.meta$'

autocmd FileType cs nnoremap <c-]> :YcmCompleter GoTo<cr>

set splitbelow
