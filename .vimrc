"Andrew Khosravian's .vimrc
let mapleader = ","
"Powerline
python from powerline.vim import setup as powerline_setup
python powerline_setup()
python del powerline_setup

"Pathogen
execute pathogen#infect()
syntax enable
filetype plugin indent on

" ***********************************
" *     settings!                   *
" ***********************************
set tabstop=4
set shiftwidth=4
set smartcase
set ignorecase
set expandtab
set hlsearch
set incsearch

" Hide buffers instead of closing them (allows buffer swapping without saving)
set hidden

"Move the preview window to the bottom of the screen
set splitbelow

colors zenburn

"Map space to disable search highlights (without changing other functionality)
nnoremap <space> :noh<return><esc>

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

" ***********************************
" *     vimrc manipulation          *
" ***********************************
if has("unix")
    map <leader>v :sp ~/.vimrc<CR><C-W>_
    map <silent> <leader>V :source ~/.vimrc<CR>:filetype detect<CR>:exe ":echo 'vimrc reloaded'"<CR>
else
    map <leader>v :sp ~/_vimrc<CR><C-W>_
    map <silent> <leader>V :source ~/_vimrc<CR>:filetype detect<CR>:exe ":echo 'vimrc reloaded'"<CR>
endif

" ***********************************
" * Filesystem browsing             *
" ***********************************
map <leader>W :exe ":lcd %:p:h"<CR>:exe ":echo 'changed pwd to current buffers'"<CR>

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

map [q :cprev<CR>
map ]q :cnext<CR>
map ,q :cclose<CR>
map ,Q :copen<CR>

" ***********************************
" * brew install the_silver_searcher*
" ***********************************
if executable('ag')
    " Use ag over grep
    set grepprg=ag\ --vimgrep\ $*
    set grepformat=%f:%l:%c:%m

    " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
    let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'

    " ag is fast enough that CtrlP doesn't need to cache
    let g:ctrlp_use_caching = 0

    nnoremap <leader>g :grep! "\b<C-R><C-W>\b"<CR>:cw<CR>

    command -nargs=+ -complete=file -bar Ag silent! grep! <args>|cwindow|redraw!
    nnoremap \ :Ag<SPACE>
endif

" ***********************************
" *         Perforce                *
" ***********************************
function! P4EditCurrentFile() 
	if has("unix")
		exe "!p4 edit \"%\""
	else
		exe "!start p4 edit \"%\""
	endif
endfunction
map <leader>e :exe P4EditCurrentFile()<CR>:exe ":echo 'opened file for edit'"<CR>:e %<CR>
map <leader>E :bufdo exe P4EditCurrentFile()<CR>:bufdo exe ":e"<CR>

function! P4RevertCurrentFile() 
	if has("unix")
		exe "!p4 revert %"
	else
		exe "!start p4 revert %"
	endif
endfunction
map <leader>R :exe P4RevertCurrentFile()<CR>:exe ":echo 'reverted file'"<CR>

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
            call system("p4 edit \"" . b:p4path . "\" > /dev/null")
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

" ***********************************
" *         Language Specific       *
" ***********************************
au Filetype python setlocal expandtab tabstop=8 shiftwidth=4 softtabstop=4

"for golang
filetype off
filetype plugin indent off
set runtimepath+=/usr/local/go/misc/vim
filetype plugin indent on
syntax on
autocmd FileType go compiler go
autocmd FileType go autocmd BufWritePre <buffer> Fmt

" ***********************************
" *         Plugin settings         *
" ***********************************

" YouCompleteMe
let g:ycm_add_preview_to_completeopt = 1
let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_autoclose_preview_window_after_insertion = 1
let g:ycm_csharp_server_port = 2000
let g:ycm_global_ycm_extra_conf = '~/.ycm_extra_conf.py'

augroup ycm_commands
    autocmd!

    autocmd FileType c,cpp,objc,objcpp,python,cs nnoremap <c-]> :YcmCompleter GoTo<cr>
    autocmd FileType c,cpp,objc,objcpp,python,cs nnoremap <leader>b :silent YcmForceCompileAndDiagnostics<cr>
augroup END

" Omnisharp
" Let YCM start/stop the omnisharp server
let g:Omnisharp_start_server = 0
let g:Omnisharp_stop_server = 0

augroup omnisharp_commands
    autocmd!

    " Bindings for fixing things
    autocmd FileType cs nnoremap <leader>x  :OmniSharpFixIssue<cr> 
    autocmd FileType cs nnoremap <leader>fx :OmniSharpFixUsings<cr>
    function! OmniSharpJoinFormat()
        try                
            exe "undojoin"
            exe "OmniSharpCodeFormat"
        catch              
        endtry
    endfunction
    autocmd FileType cs autocmd BufWritePre <buffer> call OmniSharpJoinFormat()

    autocmd FileType cs nnoremap <leader>fu :OmniSharpFindUsages<cr>
    "show type information automatically when the cursor stops moving
    autocmd CursorHold *.cs call OmniSharp#TypeLookupWithoutDocumentation()

    " Contextual code actions (requires CtrlP)
    nnoremap <leader><space> :OmniSharpGetCodeActions<cr>
    " Run code actions with text selected in visual mode to extract method
    vnoremap <leader><space> :call OmniSharp#GetCodeActions('visual')<cr>

    " Add syntax highlighting for types and interfaces
    nnoremap <leader>th :OmniSharpHighlightTypes<cr>

    " Tests
    nnoremap <leader>rt :OmniSharpRunTests<cr>
    nnoremap <leader>rf :OmniSharpRunTestFixture<cr>
    nnoremap <leader>ra :OmniSharpRunAllTests<cr>
    nnoremap <leader>rl :OmniSharpRunLastTests<cr>
augroup END

" ctrlp.vim
" ignore unity .meta files
let g:ctrlp_custom_ignore = '^.*\.meta$'

" vim-windowswap
let g:windowswap_map_keys = 0 "prevent default bindings
nnoremap <silent> <leader>yw :call WindowSwap#MarkWindowSwap()<CR>
nnoremap <silent> <leader>pw :call WindowSwap#DoWindowSwap()<CR>
nnoremap <silent> <leader>ww :call WindowSwap#EasyWindowSwap()<CR>

