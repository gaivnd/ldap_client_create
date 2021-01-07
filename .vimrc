"  __  __        __     _____ __  __ ____   ____
" |  \/  |_   _  \ \   / /_ _|  \/  |  _ \ / ___|
" | |\/| | | | |  \ \ / / | || |\/| | |_) | |
" | |  | | |_| |   \ V /  | || |  | |  _ <| |___
" |_|  |_|\__, |    \_/  |___|_|  |_|_| \_\\____|
"         |___/

" ===
" === Auto load for first time uses
" ===
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" ===
" === System
" ===
set nocompatible
filetype on
filetype indent on
filetype plugin on
filetype plugin indent on
set encoding=utf-8

" Disabling the default s key
noremap s <nop>
map S :w!<cr>
map Z :q!<cr>
map R :source $MYVIMRC<cr>

" ===
" === main code display
" ===
set number
set ruler  "标尺，在状态行里显示光标的行号和列号
set showcmd
set wildmenu
set wrap
set hlsearch
set incsearch

" ===
" === editor behavior
" ===
" Better tab
"表示按一个tab之后，显示出来的相当于几个空格，默认的是8个
"set tabstop=2
"表示每一级缩进的长度，一般设置成跟 softtabstop 一样
"set shiftwidth=2
"表示在编辑模式的时候按退格键的时候退回缩进的长度。
"set softtabstop=2
"当设置成 expandtab 时，缩进用空格来表示，noexpandtab 则是用制表符表示一个缩进
"set expandtab
"set expandtab "键入 <Tab> 时使用空格
"set tabstop=2 "<Tab> 在文件里使用的空格数
"set shiftwidth=2 "自动缩进使用的步进单位，以空白数目计
"set softtabstop=2  "编辑时 <Tab> 使用的空格数
"set list  "显示 <Tab> 和 <EOL>
"set listchars=tab:▸\ ,trail:▫
"set scrolloff=5  "光标上下的最少行数

let &keywordprg='man -a' "K 命令所使用的程序
autocmd FileType cpp set keywordprg=manpage
autocmd FileType python set keywordprg=pydoc3
autocmd FileType html setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab
autocmd FileType markdown setlocal tabstop=8 softtabstop=8 shiftwidth=8 expandtab
let mapleader=" "

" Open the vimrc file anytime
map <LEADER>rc :e ~/.vimrc<CR>

" Search
map <LEADER><CR> :nohlsearch<CR>
noremap = nzz
noremap - Nzz

" ===
" === Window management
" ===
" Use <space> + new arrow keys for moving the cursor around windows
map <LEADER>w <C-w>w
map <LEADER>u <C-w>k
map <LEADER>e <C-w>j
map <LEADER>n <C-w>h
map <LEADER>i <C-w>l
"map <LEADER>r <C-w>r


" split the screens to up (horizontal), down (horizontal), left (vertical), right (vertical)
map su :set nosplitbelow<CR>:split<CR>:set splitbelow<CR>
map se :set splitbelow<CR>:split<CR>
map sn :set nosplitright<CR>:vsplit<CR>:set splitright<CR>
map si :set splitright<CR>:vsplit<CR>

" "Zoom" a split window into a tab and/or close it
nmap <Leader>zo :tabnew %<CR>
nmap <Leader>zc :tabclose<CR>


" Resize splits with arrow keys
"map <up> :res +5<CR>
"map <down> :res -5<CR>
"map <left> :vertical resize-5<CR>
"map <right> :vertical resize+5<CR>

" Place the two screens up and down
noremap sh <C-w>t<C-w>K
" Place the two screens side by side
noremap sv <C-w>t<C-w>H

" Rotate screens
noremap srh <C-w>b<C-w>K
noremap srv <C-w>b<C-w>H

" ===
" === Restore Cursor Position
" ===
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
" for nvim, restore the cursor to where it was when you last edited.
autocmd BufReadPost *
  \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
  \ |   exe "normal! g`\""
  \ | endif

" Auto change directory to current dir
autocmd BufEnter * silent! lcd %:p:h

" Specify a directory for plugins
call plug#begin('~/.vim/plugged')

Plug 'scrooloose/nerdtree', {'on':  'NERDTreeToggle'}
Plug 'unkiwii/vim-nerdtree-sync'
"color
Plug 'crusoexia/vim-monokai'

Plug 'vim-scripts/tagbar'
Plug 'bronson/vim-trailing-whitespace'
Plug 'vim-airline/vim-airline'

Plug 'junegunn/fzf', {'dir': '~/.fzf', 'do': './install --all'}
Plug 'junegunn/fzf.vim'

Plug 'octol/vim-cpp-enhanced-highlight'
Plug 'ludovicchabant/vim-gutentags'
"It magically assigns awesome cscope maps to your vim sessions turning your VIM session into a superior IDE
Plug 'chazy/cscope_maps'

Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'ryanoasis/vim-devicons'


" Initialize plugin system
" Reload .vimrc and: PlugInstall to install plugins.
call plug#end()

syntax on
syntax enable
set cursorline "set line
highlight cursorline term=bold cterm=bold
colorscheme monokai
"set termguicolors
set t_Co=256
let g:monokai_term_italic=1
let g:monokai_gui_italic=1
set cc=101

"设置NERDTree的选项
"?: 快速帮助文档
"o: 打开一个目录或者打开文件，创建的是buffer，也可以用来打开书签
"go: 打开一个文件，但是光标仍然留在NERDTree，创建的是buffer
"t: 打开一个文件，创建的是Tab，对书签同样生效
"T: 打开一个文件，但是光标仍然留在NERDTree，创建的是Tab，对书签同样生效
"i: 水平分割创建文件的窗口，创建的是buffer
"gi: 水平分割创建文件的窗口，但是光标仍然留在NERDTree
"s: 垂直分割创建文件的窗口，创建的是buffer
"gs: 和gi，go类似
"x: 收起当前打开的目录
"X: 收起所有打开的目录
"e: 以文件管理的方式打开选中的目录
"D: 删除书签
"P: 大写，跳转到当前根路径
"p: 小写，跳转到光标所在的上一级路径
"K: 跳转到第一个子路径
"J: 跳转到最后一个子路径
"<C-j>和<C-k>: 在同级目录和文件间移动，忽略子目录和子文件
"C: 将根路径设置为光标所在的目录
"u: 设置上级目录为根路径
"U: 设置上级目录为跟路径，但是维持原来目录打开的状态
"r: 刷新光标所在的目录
"R: 刷新当前根路径
"I: 显示或者不显示隐藏文件
"f: 打开和关闭文件过滤器
"q: 关闭NERDTree
"A: 全屏显示NERDTree，或者关闭全屏
let NERDTreeMinimalUI = 1
let NERDChristmasTree = 1
let g:nerdtree_sync_cursorline = 1
let g:NERDTreeHighlightCursorline = 1

" Give a shortcut key to NERD Tree
map <F3> :NERDTreeToggle<CR>
map <leader>v :vert sb<CR>
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType=="primary") | q | endif
"当NERDTree为剩下的唯一窗口时自动关闭
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
let NERDTreeIgnore = ['\.pyc$', '\.swp', '\.swo', '\.vscode', '__pycache__']
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'

" FZF
filetype off                  " required
set rtp+=~/.fzf
filetype plugin indent on    " required
nmap <F8> :Rg <c-r>=expand("<cword>")<cr><CR>
nmap <F9> :FZF <CR>
let g:fzf_layout = { 'down': '~20%' }


"TagBar
nmap tb :TagbarToggle <CR>
let g:tagbar_width=30
let g:tagbar_autopreview = 1


map <F10> :AirlineToggle <CR>
"let g:airline_extensions = ['branch', 'tabline']
"show mutil file in one tab
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
let g:airline_symbols.maxlinenr=''

let g:airline#extensions#ale#enabled = 1
let airline#extensions#ale#show_line_numbers = 1

" Cscope + gtags configure. apt-get install cscope global (exuberant-ctags)
set cscopetag "用 cscope 处理标签命令用gtags cscope代替cscope
set cscopeprg=gtags-cscope "执行 cscope 的命令用gtags cscope代替cscope
set nocscopeverbose "增加 cscope 数据库时给bu出消息
"set tags=./.tags;,.tags
set csto=0 "决定 ":cstag" 的搜索顺序
"cs add / home/durd/work/ecms/glob/GTAGS

nmap ,s :cs find s <C-R>=expand("<cword>")<CR><CR>
nmap ,g :cs find g <C-R>=expand("<cword>")<CR><CR>
nmap ,c :cs find c <C-R>=expand("<cword>")<CR><CR>
nmap ,t :cs find t <C-R>=expand("<cword>")<CR><CR>
nmap ,e :cs find e <C-R>=expand("<cword>")<CR><CR>
nmap ,f :cs find f <C-R>=expand("<cfile>")<CR><CR>
nmap ,i :cs find i <C-R>=expand("<cfile>")<CR><CR>
nmap ,d :cs find d <C-R>=expand("<cword>")<CR><CR>


" Gutentags 搜索工程目录的标志，当前文件路径向上递归直到碰到这些文件/目录名
"let g:gutentags_project_root = ['.root', '.svn', '.git', '.hg', '.project']
let g:gutentags_project_root = ['.project']

" 所生成的数据文件的名称
let g:gutentags_ctags_tagfile = '.tags'

" 同时开启 ctags 和 gtags 支持：
let g:gutentags_modules = []
if executable('gtags-cscope') && executable('gtags')
        let g:gutentags_modules += ['gtags_cscope']
endif
"if executable('ctags')
"       let g:gutentags_modules += ['ctags']
"endif

" 将自动生成的 ctags/gtags 文件全部放入 ~/.cache/tags 目录中，避免污染工程目录
let s:vim_tags = expand('~/.cache/tags')
let g:gutentags_cache_dir = s:vim_tags

" 配置 ctags 的参数
let g:gutentags_ctags_extra_args = ['--fields=+niazS', '--extras=+q']
let g:gutentags_ctags_extra_args += ['--c++-kinds=+px']
let g:gutentags_ctags_extra_args += ['--c-kinds=+px']


" 如果使用 universal ctags 需要增加下面一行
let g:gutentags_ctags_extra_args += ['--output-format=e-ctags']

" gutentags 自动加载 gtags 数据库的行为
let g:gutentags_auto_add_gtags_cscope = 1

" 检测 ~/.cache/tags 不存在就新建
if !isdirectory(s:vim_tags)
   silent! call mkdir(s:vim_tags, 'p')
endif

"let $GTAGSLABEL = 'native-pygments'
"let $GTAGSCONF = '/home/felixdu/.gtags.conf'

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

" COC.nvim
" TextEdit might fail if hidden is not set.
set hidden

" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Give more space for displaying messages.
" set cmdheight=2

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if has("patch-8.1.1564")
  " Recently vim can merge signcolumn and number column into one
  set signcolumn=number
else
  set signcolumn=yes
endif

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
  autocmd TermOpen * setl nonu
  set signcolumn=no
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
" position. Coc only does snippet and additional edit on confirm.
" <cr> could be remapped by other vim plugin, try `:verbose imap <CR>`.
if exists('*complete_info')
  inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
  inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
" nnoremap <silent> K :call <SID>show_documentation()<CR>
nnoremap <leader>k :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocActionAsync('doHover')
  endif
endfunction
" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)
" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')
" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
" Show all diagnostics.
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
nnoremap <silent><nowait> <leader>s  :exe 'CocList -I --input='.expand('<cword>').' symbols'<cr>
nnoremap <silent><nowait> <leader>w  :exe 'CocList -I --input='.expand('<cword>').' words'<cr>

" Do default action for next item.
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>

set timeoutlen=1000 ttimeoutlen=0


"autocmd BufRead,BufNewFile /home/felixdu/src/service-mesh/* setlocal tabstop=2 shiftwidth=2 softtabstop=2 expandtab
"autocmd BufRead,BufNewFile /home/felixdu/src/ntas/* setlocal tabstop=8 shiftwidth=8 softtabstop=8 noexpandtab
