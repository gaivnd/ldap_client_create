1. 新建会话tmux new -s my_session。
2. 在 Tmux 窗口运行所需的程序。
3. 按下快捷键Ctrl+b d将会话分离。
4. 下次使用时，重新连接到会话tmux attach-session -t my_session。

From <http://www.ruanyifeng.com/blog/2019/10/tmux.html> 




创建window
Ctrl+b +c

From <https://www.cnblogs.com/logo-88/p/10682057.html> 

划分上下两个窗格
$ tmux split-window
# 划分左右两个窗格
$ tmux split-window -h

Ctrl +b +x delete pane






○ Ctrl+b d：分离当前会话。
○ Ctrl+b s：列出所有会话。
○ Ctrl+b $：重命名当前会话。

From <http://www.ruanyifeng.com/blog/2019/10/tmux.html> 

○ Ctrl+b %：划分左右两个窗格。
○ Ctrl+b "：划分上下两个窗格。
○ Ctrl+b <arrow key>：光标切换到其他窗格。<arrow key>是指向要切换到的窗格的方向键，比如切换到下方窗格，就按方向键↓。
○ Ctrl+b ;：光标切换到上一个窗格。
○ Ctrl+b o：光标切换到下一个窗格。

○ Ctrl+b }：当前窗格右移。
○ Ctrl+b Ctrl+o：当前窗格上移。
○ Ctrl+b Alt+o：当前窗格下移。
○ Ctrl+b x：关闭当前窗格。
○ Ctrl+b !：将当前窗格拆分为一个独立窗口。
○ Ctrl+b z：当前窗格全屏显示，再使用一次会变回原来大小。
○ Ctrl+b Ctrl+<arrow key>：按箭头方向调整窗格大小。
○ Ctrl+b q：显示窗格编号。

From <http://www.ruanyifeng.com/blog/2019/10/tmux.html> 



○ Ctrl+b c：创建一个新窗口，状态栏会显示多个窗口的信息。
○ Ctrl+b p：切换到上一个窗口（按照状态栏上的顺序）。
○ Ctrl+b n：切换到下一个窗口。
○ Ctrl+b <number>：切换到指定编号的窗口，其中的<number>是状态栏上的窗口编号。
○ Ctrl+b w：从列表中选择窗口。
Ctrl+b ,：窗口重命名。


tmux select-pane -t 2
#tmux send-keys "$SIPP_BIN -t tl -sn uas -i 127.0.0.1 -p 15061" C-m
tmux send-keys "while true; do sleep 1; echo 'test2'; done"
tmux select-pane -t 3
#tmux send-keys "$SIPP_BIN -t tl -sn uas -i 127.0.0.1 -p 15061" C-m
tmux send-keys "while true; do sleep 1; echo 'test3'; done"



#envoy
tmux new-window
tmux rename-window envoy
tmux split-window -h
tmux split-window -v
tmux select-pane -t 1
tmux send-keys "while true; do sleep 1; echo 'sipp test1'; done" C-m



sleep 3
tmux select-window -t sipp
tmux select-pane -t 1
tmux send-keys "ulimit -n 50000" C-m  # Maximum number of open sockets (50000) should be less than the maximum number of open files (1024). Tune this with the `ulimit` command or the -max_socket option
tmux send-keys "while true; do sleep 1; echo 'sipp test1" C-m

tmux attach-session -t sipp
