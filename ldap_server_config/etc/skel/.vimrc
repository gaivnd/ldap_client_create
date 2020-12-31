call plug#begin('~/.vim/plugged')
Plug 'preservim/tagbar'
Plug 'scrooloose/nerdtree', {'on':  'NERDTreeToggle'}
Plug 'bronson/vim-trailing-whitespace'
Plug 'vim-airline/vim-airline'
Plug 'ludovicchabant/vim-gutentags'
Plug 'chazy/cscope_maps'
Plug 'unkiwii/vim-nerdtree-sync'
call plug#end()

set encoding=utf-8
let mapleader="," "要定义一个使用 \"mapleader\" 变量的映射，可以使用特殊字串 \"< Leader >\"
let g:mapleader=","
let maplocalleader="\\" "< LocalLeader > 和 < Leader > 类似，除了它使用 \"maplocalleader\" 而非 \"mapleader\"以外

set nu
set hlsearch
set incsearch
set nocompatible              " be iMproved, required
filetype plugin indent on    " required

map <leader><space> :FixWhitespace<cr>
nmap tb :TagbarToggle <CR>

map <F10> :AirlineToggle <CR>
let g:airline_extensions = ['branch', 'tabline']
let g:airline#extensions#tabline#enabled=1
let g:airline#extensions#tabline#buffer_nr_show=1

let g:airline#existsions#whitespace#enabled=0
let g:airline#existsions#whitespace#symbol="!"
let g:airline#extensions#whitespace#show_message=0
let g:airline_detect_modified=1

if !exists('g:airline_symbols')
  let g:airline_symbols={}
endif
"let g:airline#extensions#tabline#fnamemod = ':p:.'
let g:airline#extensions#tabline#fnamemod=':t:.'
let g:airline_left_sep=''
let g:airline_left_alt_sep=''
let g:airline_right_sep=''
let g:airline_right_alt_sep=''
let g:airline_symbols.branch=''
let g:airline_symbols.readonly=''
let g:airline_symbols.linenr='☰'
let g:airline_symbols.maxlinenr=''
let g:airline_symbols.maxlinenr=''

let g:airline#extensions#ale#enabled = 1
let airline#extensions#ale#show_line_numbers = 1

set cscopetag
set cscopeprg=gtags-cscope
set nocscopeverbose
set csto=0

"nmap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>
"nmap <C-\>g :cs find g <C-R>=expand("<cword>")<CR><CR>
"nmap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>
"nmap <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>
"nmap <C-\>e :cs find e <C-R>=expand("<cword>")<CR><CR>
"nmap <C-\>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
"nmap <C-\>i :cs find i <C-R>=expand("<cfile>")<CR><CR>
"nmap <C-\>d :cs find d <C-R>=expand("<cword>")<CR><CR>

""""""""""""" guntentages """"""""""""""""""""""
" gutentags 搜索工程目录的标志，当前文件路径向上递归直到碰到这些文件/目录名
"let g:gutentags_project_root = ['.root', '.svn', '.git', '.hg', '.project']
let g:gutentags_project_root = ['.project']

" 所生成的数据文件的名称
let g:gutentags_ctags_tagfile = '.tags'

let g:gutentags_modules = []
if executable('gtags-cscope') && executable('gtags')
	let g:gutentags_modules += ['gtags_cscope']
elseif executable('ctags')
	let g:gutentags_modules += ['ctags']
endif

" 将自动生成的 ctags/gtags 文件全部放入 ~/.cache/tags 目录中，避免污染工程目录
let s:vim_tags = expand('~/.cache/tags')
let g:gutentags_cache_dir = s:vim_tags

" 配置 ctags 的参数
let g:gutentags_ctags_extra_args = ['--fields=+niazS', '--extras=+q']
let g:gutentags_ctags_extra_args += ['--c++-kinds=+px']
let g:gutentags_ctags_extra_args += ['--c-kinds=+px']

" 如果使用 universal ctags 需要增加下面一行
let g:gutentags_ctags_extra_args += ['--output-format=e-ctags']

" 禁用 gutentags 自动加载 gtags 数据库的行为
let g:gutentags_auto_add_gtags_cscope = 1

" 检测 ~/.cache/tags 不存在就新建
if !isdirectory(s:vim_tags)
   silent! call mkdir(s:vim_tags, 'p')
endif

let g:gutentags_define_advanced_commands = 1

let g:tagbar_type_go = {
    \ 'ctagstype': 'go',
    \ 'kinds' : [
        \'p:package',
        \'f:function',
        \'v:variables',
        \'t:type',
        \'c:const'
    \]
\}

set wildmode=full
set wildmenu
set splitright

" NERDTree
let NERDTreeMinimalUI = 1
let NERDChristmasTree = 1
let g:nerdtree_sync_cursorline = 1
let g:NERDTreeHighlightCursorline = 1
" Give a shortcut key to NERD Tree
map <F3> :NERDTreeToggle<CR>
