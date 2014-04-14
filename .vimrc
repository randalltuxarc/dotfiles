" Pro version Vimrc
" I kept all other settings in plugins/settings directory
"
" Eddie Kao
" http://blog.eddie.com.tw
" eddie@digik.com.tw

runtime bundle/vim-pathogen/autoload/pathogen.vim
filetype off
"call pathogen#runtime_append_all_bundles()
call pathogen#infect('bundle/{}')
filetype plugin indent on
call pathogen#infect()
call pathogen#helptags()

" force myself to not to use the error keys
map <UP> <NOP>
map <DOWN> <NOP>
map <LEFT> <NOP>
map <RIGHT> <NOP>
inoremap <UP> <NOP>
inoremap <DOWN> <NOP>
inoremap <LEFT> <NOP>
inoremap <RIGHT> <NOP>

" cancel searched highlight
noremap <CR> :nohlsearch<CR>
