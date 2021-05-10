nsenter --target `docker inspect --format {{.State.Pid}} 8d0101ab05bc ` --net --pid iptables -I OUTPUT -d 192.168.1.225 -j DROP //PRS side

nsenter --target `docker inspect --format {{.State.Pid}} 79b28a962067 ` --net --pid iptables -I INPUT -s 192.168.1.156 -j DROP //CRDB side




curl http://nghttp2.org --http2 -v

 tcpdump -i eth0 port 80 and host nghttp2.org -w d.pcap


docker:

docker run -d --name private_env -v /var/run/docker.sock:/var/run/docker.sock  -v ~/src:/src --privileged --net=host -it ubuntu:latest bash

from flask import Flask
import socket
import os

app = Flask(__name__)

@app.route('/')
def hello():
    html = "<h3>Hello {name}!</h3>" \
           "<b>Hostname:</b> {hostname}<br/>"           
    return html.format(name=os.getenv("NAME", "world"), hostname=socket.gethostname())
    
if __name__ == "__main__":
    app.run(host='0.0.0.0', port=80)

$ cat requirements.txt
Flask





# 使用官方提供的 Python 开发镜像作为基础镜像
FROM python:2.7-slim

# 将工作目录切换为 /app
WORKDIR /app

# 将当前目录下的所有内容复制到 /app 下
ADD . /app

# 使用 pip 命令安装这个应用所需要的依赖
RUN pip install --trusted-host pypi.python.org -r requirements.txt

# 允许外界访问容器的 80 端口
EXPOSE 80

# 设置环境变量
ENV NAME World

# 设置容器进程为：python app.py，即：这个 Python 应用的启动命令
CMD ["python", "app.py"]


Dockerfile 的设计思想，是使用一些标准的原语描述我们所要构建的 Docker 镜像。并且这些原语，都是按顺序处理的。


在使用 Dockerfile 时，你可能还会看到一个叫作 ENTRYPOINT 的原语。实际上，它和CMD 都是 Docker 容器进程启动所必需的参数，完整执行格式是：“ENTRYPOINT CMD”但是，默认情况下，Docker 会为你提供一个隐含的的 ENTRYPOINT，即：/bin/sh -c所以，在不指定 ENTRYPOINT 时
，比如在我们这个例子里，实际上运行在容器里的完整进程是：/bin/sh -c “python app.py”
即 CMD 的内容就是 ENTRYPOINT 的参数

我们后面会统一称 Docker 容器的启动进程为 ENTRYPOINT，而不是 CMD。


$ ls
Dockerfile  app.py   requirements.txt
$ docker build -t helloworld .


docker build 操作完成后，我可以通过 docker images 命令查看结果

$ docker image ls

REPOSITORY            TAG                 IMAGE ID
helloworld         latest              653287cdf998
 
接下来，我使用这个镜像，通过 docker run 命令启动...
$ docker run -p 4000:80 helloworld
容器启动之后，我可以使用 docker ps 命令看到：
$ docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED
4ddf4638572d        helloworld       "python app.py"     10 seconds ago



我使用了 docker exec 命令进入到了容器当中，在了解了 Linux Namespace 的隔离机制后，你应该会很自然地想到一个问题：：docker exec 是怎么做到进入容器里的呢？


Check 当前容器的进程
$ docker inspect --format '{{ .State.Pid }}'  4ddf4638572d
25686

你可以通过查看宿主机的 proc 文件，看到这个 25686进程的所有 Namespace 对应的文件：

$ ls -l  /proc/25686/ns
total 0
lrwxrwxrwx 1 root root 0 Aug 13 14:05 cgroup -> cgroup:[4026531835]
lrwxrwxrwx 1 root root 0 Aug 13 14:05 ipc -> ipc:[4026532278]
lrwxrwxrwx 1 root root 0 Aug 13 14:05 mnt -> mnt:[4026532276]
lrwxrwxrwx 1 root root 0 Aug 13 14:05 net -> net:[4026532281]
lrwxrwxrwx 1 root root 0 Aug 13 14:05 pid -> pid:[4026532279]
lrwxrwxrwx 1 root root 0 Aug 13 14:05 pid_for_children -> pid:[4026532279]
lrwxrwxrwx 1 root root 0 Aug 13 14:05 user -> user:[4026531837]
lrwxrwxrwx 1 root root 0 Aug 13 14:05 uts -> uts:[4026532277]

一个进程，可以选择加入到某个进程已有的 Namespace当中，从而达到“进入”这个进程所在容器的目的，这正是 docker exec 的实现原理。

setns() 的 Linux 系统调用
#define _GNU_SOURCE
#include <fcntl.h>
#include <sched.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

#define errExit(msg) do { perror(msg); exit(EXIT_FAILURE);} while (0)

int main(int argc, char *argv[]) {
    int fd;
    
    fd = open(argv[1], O_RDONLY);
    if (setns(fd, 0) == -1) {
        errExit("setns");
    }
    execvp(argv[2], &argv[2]); 
    errExit("execvp");
}

argv[1]，即当前进程要加入的 Namespace 文件的路径，比如 /proc/25686/ns/net；而第二个参数，则是你要在这个 Namespace 里运行的进程，比如 /bin/bash。
在 setns() 执行后，当前进程就加入了这个文件对应的的 Linux Namespace 当中了。
$ gcc -o set_ns set_ns.c 
$ ./set_ns /proc/25686/ns/net /bin/bash 
$ ifconfig
eth0      Link encap:Ethernet  HWaddr 02:42:ac:11:00:02  
          inet addr:172.17.0.2  Bcast:0.0.0.0  Mask:255.255.0.0
          inet6 addr: fe80::42:acff:fe11:2/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:12 errors:0 dropped:0 overruns:0 frame:0
          TX packets:10 errors:0 dropped:0 overruns:0 carrier:0
	   collisions:0 txqueuelen:0 
          RX bytes:976 (976.0 B)  TX bytes:796 (796.0 B)

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
	  collisions:0 txqueuelen:1000 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)


ps 指令找到这个 set_ns 程序执行的 /bin/bash 进程，其真实的 PID 是 28499：
# 在宿主机上
ps aux | grep /bin/bash
root     28499  0.0  0.0 19944  3612 pts/0    S    14:15   0:00 /bin/bash

$ ls -l /proc/28499/ns/net
lrwxrwxrwx 1 root root 0 Aug 13 14:18 /proc/28499/ns/net -> net:[4026532281]

$ ls -l  /proc/25686/ns/net
lrwxrwxrwx 1 root root 0 Aug 13 14:05 /proc/25686/ns/net -> net:[4026532281]
这个 PID=28499 进程，与我们前面的 Docker容器进程（PID=25686）指向的 Network Namespace 文件完全一样。




Volume 机制，允许你将宿主机上指定的目录或者文件，挂载到容器里面进行读取和修改操作。
容器技术使用了 rootfs 机制和 Mount Namespace，构建出了一个同宿主机完全隔离开的文件系统环境。这时候，我们就需要考虑这样两个问题：
容器里进程新建的文件，怎么才能让宿主机获取到？
宿主机上的文件和目录，怎么才能让容器里的进程访问到？

Docker Volume 要解决的问题：Volume 机制，允许你将宿主机上指定的目录或者文件，挂载到容器里面进行读取和修改操作。
$ docker run -v /test …     ->
/var/lib/docker/volumes/[VOLUM_ID]/_data

$ docker run -v /home:/test ...



容器镜像
：各个层保存在 /var/lib/docker/aufs/diff 目录下，在容器进程启动后，它们会被联合挂载在 /var/lib/docker/aufs/mnt/ 目录中，这样容器所需的 rootfs 就准备好了
在 rootfs 准备好之后，在执行 chroot 之前，把Volume 指定的宿主机目录（比如 /home 目录）
在宿主机上对应的目录（即 /var/lib/docker/aufs/mnt/[可读写层 ID]/test）上，这个 V
olume 的挂载工作就完成了。

而这里要使用到的挂载技术，就是 Linux 的绑定挂载（bind mount）机制。




所以，在一个正确的时机，进行一次绑定挂载，Docker 就可以成功地将一个宿主机上的目录或文件，不动声色地挂载到容器中。

进程在容器里对这个 /test 目录进行的所有操作，都实际发际发生在宿主机的对应目录（比如，/home，或者 /var
/lib/docker/volumes/[VOLUME_ID]/_data）里，而不会影响容器镜像的内容。
这个 /test 目录里的内容，既然挂载在容器 rootfs的可读写层，它会不会被 docker commit 提交掉
启动一个 helloworld 容器，给它声明一个 Voluume，挂载在容器里的 /test 目录上
$ docker run -d -v /test helloworld
cf53b766fa6f
查看一下这个 Volume 的 ID
$ docker volume ls
DRIVER              VOLUME NAME
local               cb1c2f7221fa9b0971cc35f68aa1034824755ac44a034c0c0a1dd318838d3a6d

找到它在 Docker 工作目录下的 volumes 路径
$ ls /var/lib/docker/volumes/cb1c2f7221fa/_data/
接下来，我们在容器的 Volume 里，添加一个文件 text.txt：
$ docker exec -it cf53b766fa6f /bin/sh
cd test/
touch text.txt
再回到宿主机，就会发现 text.txt已经出现在了宿主机上对应的临时目录里：
$ ls /var/lib/docker/volumes/cb1c2f7221fa/_data/（宿主机临时目录）
text.txt
可是，如果你在宿主机上查看该容器的可读写层，虽然可以看到这个/test 目录，但其内容是空的
$ ls /var/lib/docker/aufs/mnt/6780d0778b8a/test（容器可读写层）

cut:

nsenter -n -t `docker inspect $(docker ps | grep test1 | cut -d" " -f1) | grep Pid | cut -d":" -f2 | sed '2,$d'| cut -d" " -f2 | cut -d"," -f1`

kube:

2.1 查看ops这个命名空间下的所有pod，并显示pod的IP地址
kubectl get pods -n ops -o wide
2.2 查看tech命名空间下的pod名称为tech-12ddde-fdfde的日志，并显示最后30行
kubectl logs tech-12ddde-fdfde -n tech|tail -n 30
2.3 怎么查看test的命名空间下pod名称为test-5f7f56bfb7-dw9pw的状态
kubectl describe pods test-5f7f56bfb7-dw9pw -n test
2.4 如何查看test命名空间下的所有endpoints
kubectl get ep -n test
2.5 如何列出所有 namespace 中的所有 pod
kubectl get pods --all-namespaces
2.6、如何查看test命名空间下的所有ingress
kubectl get ingress -n test
2.7、如何删除test命名空间下某个deploymemt，名称为gitlab
kubectl delete deploy gitlab -n test
2.8 如何缩减test命名空间下deployment名称为gitlab的副本数为1
kubectl scale deployment gitlab -n test --replicas=1
2.9 如何在不进入pod内查看命名空间为test,pod名称为test-5f7f56bfb7-dw9pw的hosts
kubectl exec -it test-5f7f56bfb7-dw9pw -n test -- cat /etc/hosts
2.10 如何设置节点test-node-10为不可调度以及如何取消不可调度
kubectl cordon test-node-10     #设置test-node-10为不可调度
kubectl uncordon test-node-10   #取消 




3、考察实际生产经验(最重要)
3.1 某个pod启动的时候需要用到pod的名称，请问怎么获取pod的名称，简要写出对应的yaml配置(考察是否对k8s的Downward API有所了解)
env:
- name: test
  valueFrom:
    fieldRef:
      fieldPath: metadata.name
3.2 某个pod需要配置某个内网服务的hosts，比如数据库的host，刑如：192.168.4.124 db.test.com，请问有什么方法可以解决，简要写出对应的yaml配置或其他解决办法
解决办法：搭建内部的dns，在coredns配置中配置内网dns的IP
要是内部没有dns的话，在yaml文件中配置hostAliases，刑如：
hostAliases:
- ip: "192.168.4.124"
  hostnames:
  - "db.test.com"
3.3 请用系统镜像为centos:latest制作一个jdk版本为1.8.142的基础镜像，请写出dockerfile（考察dockerfile的编写能力）
FROM centos:latest
ARG JDK_HOME=/root/jdk1.8.0_142
WORKDIR /root
ADD jdk-8u142-linux-x64.tar.gz /root
ENV JAVA_HOME=/root/jdk1.8.0_142
ENV PATH=$PATH:$JAVA_HOME/bin
CMD ["bash"]
3.4 假如某个pod有多个副本，如何让两个pod分布在不同的node节点上，请简要写出对应的yaml文件（考察是否对pod的亲和性有所了解）
affinity:
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    - topologyKey: "kubernetes.io/hostname"
      labelSelector:
        matchLabels:
          app: test
3.5 pod的日志如何收集，简要写出方案(考察是否真正有生产经验，日志收集是必须解决的一个难题)
每个公司的都不一样，下面三个链接可当做参考
https://jimmysong.io/kubernetes-handbook/practice/app-log-collection.html
https://www.jianshu.com/p/92a4c11e77ba
https://haojianxun.github.io/2018/12/21/kubernetes%E5%AE%B9%E5%99%A8%E6%97%A5%E5%BF%97%E6%94%B6%E9%9B%86%E6%96%B9%E6%A1%88/
3.6 谈下你对k8s集群监控的心得，口述
3.7 集群如何预防雪崩，简要写出必要的集群优化措施
1、为每个pod设置资源限制
2、设置Kubelet资源预留
3.8 集群怎么升级，证书过期怎么解决，简要说出做法
参考
https://googlebaba.io/post/2019/09/11-renew-ca-by-kubeadm/   #更新证书
https://jicki.me/kubernetes/2019/05/09/kubeadm-1.14.1/       #集群升级
3.9 etcd如何备份，简要写出命令
参考：https://www.bladewan.com/2019/01/31/etcd_backup/
export ETCDCTL_API=3
etcdctl --cert=/etc/kubernetes/pki/etcd/server.crt \
        --key=/etc/kubernetes/pki/etcd/server.key \
        --cacert=/etc/kubernetes/pki/etcd/ca.crt \
        snapshot save /data/test-k8s-snapshot.db

From <https://www.cnblogs.com/uglyliu/p/11743021.html> 



Kube
https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

	1. Install docker
# (Install Docker CE)
## Set up the repository:
### Install packages to allow apt to use a repository over HTTPS
apt-get update && apt-get install -y \
  apt-transport-https ca-certificates curl software-properties-common gnupg2

# Add Docker's official GPG key:
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

# Add the Docker apt repository:
add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"
# Install Docker CE
apt-get update && apt-get install -y \
  containerd.io=1.2.13-2 \
  docker-ce=5:19.03.11~3-0~ubuntu-$(lsb_release -cs) \
  docker-ce-cli=5:19.03.11~3-0~ubuntu-$(lsb_release -cs)
# Set up the Docker daemon
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
mkdir -p /etc/systemd/system/docker.service.d

# Restart Docker
systemctl daemon-reload
systemctl restart docker

systemctl enable docker




https://github.com/gaivnd/note

	2. Install 

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system

	sudo apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

systemctl daemon-reload
systemctl restart kubelet


In master:
	1) kubeadm init --image-repository registry.aliyuncs.com/google_containers  --pod-network-cidr=192.168.0.0/16

	2) Allow kubectl access k8s cluster(master node)
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

   3) Allow master node create container.

kubectl taint nodes --all node-role.kubernetes.io/master-
It should return the following.
node/<your-hostname> untainted

	4) Create CNI (calico) for k8s cluster
kubectl create -f https://docs.projectcalico.org/manifests/tigera-operator.yaml
kubectl create -f https://docs.projectcalico.org/manifests/custom-resources.yaml

# This section includes base Calico installation configuration.
# For more information, see: https://docs.projectcalico.org/v3.16/reference/installation/api#operator.tigera.io/v1.Installation
apiVersion: operator.tigera.io/v1
kind: Installation
metadata:
  name: default
spec:
  # Configures Calico networking.
  calicoNetwork:
    # Note: The ipPools section cannot be modified post-install.
    ipPools:
    - blockSize: 26
      cidr: 192.168.0.0/16
      encapsulation: VXLANCrossSubnet
      natOutgoing: Enabled
      nodeSelector: all()

Work node

	1) kubeadm join 192.168.0.10:6443 --token xn52uu.ym6pmzu22doqqsxv \
    --discovery-token-ca-cert-hash sha256:5406533d27afce41635a0339f192328fcc46dc53324e39baa5104183b4588b9c

kubeadm join 192.168.0.10:6443 --token id4yfa.oyombvxcz910wj77 \
    --discovery-token-ca-cert-hash sha256:370ba2440f61796142243698cb41dd2d4c41531b45d34047dd97f68ca63790ab


	1) Allow kubectl access k8s cluster(work node)
scp root@<control-plane-host>:/etc/kubernetes/admin.conf .
kubectl --kubeconfig ./admin.conf get nodes





registry 的搭建



docker pull registry:2
docker run -d -v /opt/registry:/var/lib/registry -p 5000:5000 --name myregistry registry:2


docker tag nginx:latest localhost:5000/nginx:latest
通过 docker push 命令将 nginx 镜像 push到私有仓库中：
docker push localhost:5000/nginx:latest



Dashboard.

$ kubectl apply -f 
$ $ kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-rc6/aio/deploy/recommended.yaml



"1. What was the problem from the customer's or tester's viewpoint? 
Currently, expect behavior is NTAS only generate VoWiFi App(child) terminating bill AVP when VoWiFi App answer. But ONS have code logic issue in latest site load, so NTAS generate VoWiFi app terminating AVP with sbc-domain HLT(child) and the parent terminating AVP w/o sbc-domain when VoWiF App answer. The BOSS will treat them as two duplicated billing records and discards the second billing record received. If parent and VoWiFi App (child) are registered in the different TAS, and the parent AVP arrived first, the AVP with HLT label will be discard and customer(CUC) will suffer charging losses.


2. Where and how was the issue actually found? 
The issue found by NPI testing before CUC commercial use one number vowifapp service in China United Telecommunications Corp 


3. What was the product root cause (technical description of the fault)? 
	ONS dev work in R34 and R36  start dev at the same time. The parent remove AVP logic is  added in R36 deleted feature line. Therefore the issue does not exist in R34, but the problem appears after R34/R36 merged in R37.   

4. What was done to correct the problem (technical description)? 
Add the code that deleted by R36 feature line.

5. Any additional relevant facts to note?"
Before the official fix, the WA already apply in CUC site.



"1. What was the problem from the customer's or tester's viewpoint? 
TAFE container have auto-restart happen. 

2. Where and how was the issue actually found? 
The issue found by R&D MG in China United Telecommunications Corp 

3. What was the product root cause (technical description of the fault)? 
In one call process rainy day case which still didn't figure out how it happen, the basic call dialog ptr(dlgbasiccallsvcdata) will set to null due to wrong status in basic call service. Before FC000223, the basic call service will directly stop handling and let this call failed with 456 response. But FC000223 logic has return code setting issue for this rainy day case in basic call service and will let basic call service continue handle it even basic call dialog ptr set to null. Then basic call service running the code which already exists for a long time and using this ptr without checking it, so the SegV occur and tafe restart. 

4. What was done to correct the problem (technical description)? 
a. Fix the FC000223 logic return code setting issue in basic call service. 
b. Checking basic call dialog ptr before use it in basic call service 

5. Any additional relevant facts to note?" 

From <https://jiradc2.ext.net.nokia.com/browse/MNRCA-26735> 




vim:

	1) Install Vim-plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

	2) Copy .vimrc in /root/.vimrc
	3) :PlugInstall
	4) YouCompleteMe--->set ssh proxy since need clone source from github
	Download /root/.vim/plugged/YouCompleteMe
	Cd ~/.vim/plugged/YouCompleteMe
	git submodule update --init --recursive
	 apt-get install cmake
	./install.py
	
	5) apt-get install cscope
	apt-get install exuberant-ctags global
	
	
	
	Coc-->curl -sL install-node.now.sh/lts | bash
	coc.nvim
	
	
	Vim
	
	Visual mode + ':' + " normal" + "Imy-start"
	Visual+block mode + "shift i(insert mode)" + change +esc
	
	
	

.vim--> 
	
" automatic install vim-plug https: // github.com/junegunn/vim-plug
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Specify a directory for plugins
call plug#begin('~/.vim/plugged')
Plug 'Valloric/YouCompleteMe'
Plug 'scrooloose/nerdtree', {'on':  'NERDTreeToggle'}
Plug 'vim-scripts/tagbar'
Plug 'bronson/vim-trailing-whitespace'     -->treat whitespace as red
Plug 'vim-airline/vim-airline'
Plug 'Yggdroot/indentLine'-->
indentLine,代码缩进提示

Plug 'rakr/vim-one'
Plug 'crusoexia/vim-monokai'-->
Refined monokai color scheme for vim.



Plug 'octol/vim-cpp-enhanced-highlight'  -->
Vim自带的语法高亮不能高亮C++的部分关键字和标准库


Plug 'dhruvasagar/vim-table-mode'
Plug 'junegunn/fzf', {'dir': '~/.fzf', 'do': './install --all'}
Plug 'junegunn/fzf.vim'



Plug 'tpope/vim-fugitive'
Plug 'ludovicchabant/vim-gutentags'
Plug 'skywind3000/vim-preview'
Plug 'skywind3000/asyncrun.vim'
Plug 'seeamkhan/robotframework-vim'
"Plug 'chrisbra/csv.vim'
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'
Plug 'durd07/vim-markdown-gabrielelana'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'vim-scripts/BufOnly.vim'
Plug 'chazy/cscope_maps'
Plug 'Glench/Vim-Jinja2-Syntax'
Plug 'vim-scripts/summerfruit256.vim'
"Plug 'grailbio/bazel-compilation-database'
"Plug 'SkyLeach/pudb.vim'
"Plug 'Xuyuanp/nerdtree-git-plugin'

" these below 2 plugins is used for python pep8 syntax check <F7>
Plug 'w0rp/ale'
"Plug 'nvie/vim-flake8'
Plug 'vim-scripts/DoxygenToolkit.vim'

" Initialize plugin system
" Reload .vimrc and: PlugInstall to install plugins.
call plug#end()

" vim-table-mode
let g:table_mode_corner = '|' " Markdown-compatible tables
"let g:table_mode_corner_corner='+' " ReST-compatible tables
"let g:table_mode_header_fillchar='=' " ReST-compatible tables

set encoding=utf-8
let mapleader="," "要定义一个使用 \"mapleader\" 变量的映射，可以使用特殊字串 \"< Leader >\"
let g:mapleader=","
let maplocalleader="\\" "< LocalLeader > 和 < Leader > 类似，除了它使用 \"maplocalleader\" 而非 \"mapleader\"以外

set nu
set hlsearch
set incsearch

"表示按一个tab之后，显示出来的相当于几个空格，默认的是8个
"set tabstop=8
"表示每一级缩进的长度，一般设置成跟 softtabstop 一样
"set shiftwidth=8
"表示在编辑模式的时候按退格键的时候退回缩进的长度。
"set softtabstop=4
"当设置成 expandtab 时，缩进用空格来表示，noexpandtab 则是用制表符表示一个缩进
"set expandtab

let &keywordprg='man -a'
autocmd FileType cpp set keywordprg=manpage
autocmd FileType python set keywordprg=pydoc3

autocmd FileType html setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab
autocmd FileType markdown setlocal tabstop=8 softtabstop=8 shiftwidth=8 expandtab

"set nowrap

set foldmethod=indent
set foldlevel=99
nnoremap <space> za

set nocompatible              " be iMproved, required
filetype off                  " required

set rtp+=~/.fzf
filetype plugin indent on    " required

map <leader><space> :FixWhitespace<cr>

"let g:ycm_path_to_python_interpreter = '/usr/bin/python'
let g:ycm_server_python_interpreter = '/usr/bin/python3'
let g:ycm_confirm_extra_conf=0
let g:ycm_global_ycm_extra_conf='$HOME/.ycm_extra_conf.py'
let g:ycm_seed_identifiers_with_syntax=1
let g:ycm_complete_in_comments=1
let g:ycm_complete_in_strings=1
let g:ycm_min_num_of_chars_for_completion=1

nnoremap <leader>gl :YcmCompleter GoToDeclaration <CR>
nnoremap <leader>gf :YcmCompleter GoToDefinition <CR>
"nnoremap <leader>gg :YcmCompleter GoToDefinitionElseDeclaration <CR>
nnoremap <leader>gg :YcmCompleter GoTo<CR>
let g:ycm_error_symbol='>>'
let g:ycm_warning_symbol='>*'
let g:ycm_enable_diagnostic_signs = 1
nmap <F4> :YcmDiags <CR>

"设置NERDTree的选项
"
"ctr+w+h"光标focus左侧树形目录，"ctrl+w+l"光标focus右侧文件显示窗口。多次按"ctrl+w"，光标自动在左右侧窗口切换。光标focus左侧树形窗口，按"？"弹出NERDTree的帮助，再次按"？"关闭帮助显示。输入":q"回车，关闭光标所在窗口


let NERDTreeMinimalUI = 1
let NERDChristmasTree = 1
" Give a shortcut key to NERD Tree
"设置F3 打开文件tree
map <F3> :NERDTreeToggle<CR>
nmap <F9> :FZF <CR>
"设置调用Rg搜索
nmap <F8> :Rg <c-r>=expand("<cword>")<cr><CR>
map <leader>v :vert sb
"只有一个tree时自动关闭
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType=="primary") | q | endif

"TagBar
"按两次tb退出
nmap tb :TagbarToggle <CR>
let g:tagbar_width=30


"vim-airline 是vim的底部状态增强/美化插件--> NORMAL  .vimrc                                                                                                         vim  utf-8[unix]  27% ☰ 118/433:1  
map <F10> :AirlineToggle <CR>
"let g:airline_extensions = ['branch', 'tabline']
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
"let g:airline_left_sep=''
"let g:airline_left_alt_sep=''
"let g:airline_right_sep=''
"let g:airline_right_alt_sep=''
"let g:airline_symbols.branch=''
"let g:airline_symbols.readonly=''
"let g:airline_symbols.linenr='☰'
"let g:airline_symbols.maxlinenr=''
let g:airline_symbols.maxlinenr=''

let g:airline#extensions#ale#enabled = 1
let airline#extensions#ale#show_line_numbers = 1

set cscopetag
set cscopeprg=gtags-cscope
set nocscopeverbose
"set tags=./.tags;,.tags
set csto=0

"cs add / home/durd/work/ecms/glob/GTAGS

"nmap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>
"nmap <C-\>g :cs find g <C-R>=expand("<cword>")<CR><CR>
"nmap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>
"nmap <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>
"nmap <C-\>e :cs find e <C-R>=expand("<cword>")<CR><CR>
"nmap <C-\>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
"nmap <C-\>i :cs find i <C-R>=expand("<cfile>")<CR><CR>
"nmap <C-\>d :cs find d <C-R>=expand("<cword>")<CR><CR>

""""" gtag
"au VimEnter * call VimEnterCallback()
"au BufAdd * call FindGtags(expand('<afile>'))
"au BufWritePost * call UpdateGtags(expand('<afile>'))
"
"function! VimEnterCallback()
"    for f in argv()
"         if fnamemodify(f, ':e') != 'c' && fnamemodify(f, ':e') != 'hpp' && fnamemodify(f, ':e') != 'h' && fnamemodify(f, ':e') != 'cpp' && fnamemodify(f, ':e') != 'py'
"             continue
"         endif
"
"         call FindGtags(f)
"     endfor
"endfunc
"
"function! FindGtags(f)
"     let dir = fnamemodify(a:f, ':p:h')
"     while 1
"         let tmp = dir . '/GTAGS'
"         if filereadable(tmp)
"             "exe 'cs add ' . tmp . ' ' . dir
"             exe 'cs add ' . tmp
"             break
"         elseif dir == '/'
"             break
"         endif
"
"         let dir = fnamemodify(dir, ":h")
"     endwhile
"endfunc
"
"function! UpdateGtags(f)
"     let dir = fnamemodify(a:f, ':p:h')
"     exe 'silent !cd ' . dir . ' && global -u &> /dev/null &'
"endfunction
"
"function! BufPos_ActivateBuffer(num)
"    exe "buffer " . a:num
"endfunction
"
function! BufPos_Initialize()
    exe "map <leader>0 :buffer 0<CR>"
    let l:count=1
    for i in range(1, 9)
        exe "map <leader>" . i . " :buffer " . i . "<CR>"
    endfor
endfunction

au VimEnter * call BufPos_Initialize()




syntax on
colorscheme monokai
"set termguicolors
set t_Co=256
let g:monokai_term_italic=1
let g:monokai_gui_italic=1

set cursorline
"highlight Cursorline term=bold ctermbg=8 cterm=bold guibg=Grey40
highlight Cursorline term=bold cterm=bold
"highlight Cursorline cterm=bold ctermbg=None ctermfg=white guibg=darkred guifg=white
set cc=101
"au BufRead,BufNewFile * syntax match Search /\%>80v.\+/
"set autochdir

let g:ale_sign_error = '●'
let g:ale_sign_warning = '.'
let g:ale_linters = {
\   'javascript': ['eslint'],
\   'python': ['flake8'],
\   'go': ['golint', 'gofmt', 'goimports']
\}

"let b:ale_fixers = [
"\   'remove_trailing_lines',
"\   'autopep8',
"\   'isort',
"\   'yapf',
"\]

"let g:ale_fix_on_save = 1

nnoremap <Leader>f :ALEFix<CR>
nmap <F7> :ALEToggle <CR>

let g:ale_linters_explicit = 1
let g:ale_completion_delay = 500
let g:ale_echo_delay = 20
let g:ale_lint_delay = 500
let g:ale_echo_msg_format = '[%linter%] %code: %%s'
let g:ale_lint_on_text_changed = 'normal'
let g:ale_lint_on_insert_leave = 1

let g:ale_c_gcc_options = '-Wall -O2 -std=c99'
let g:ale_cpp_gcc_options = '-Wall -O2 -std=c++17'
let g:ale_c_cppcheck_options = ''
let g:ale_cpp_cppcheck_options = ''
"
""let g:ale_sign_error = "\ue009\ue009"
hi! clear SpellBad
hi! clear SpellCap
hi! clear SpellRare
hi! SpellBad gui=undercurl guisp=red
hi! SpellCap gui=undercurl guisp=blue
hi! SpellRare gui=undercurl guisp=magenta

"" Check Python files with flake9 and pylint.
"let b:ale_linters = {'python' : ['flake8', 'pylint'],'cpp': ['clang', 'cpplint']}
"" Fix Python files with autopep8 and yapf.
let g:ale_fixers = {'python': ['autopep8', 'yapf']}
"" Disable warnings about trailing whitespace for Python files.
let b:ale_warn_about_trailing_whitespace = 0

packadd termdebug

let g:flake8_show_in_file=1  " show
let g:flake8_show_in_gutter=1

" "Zoom" a split window into a tab and/or close it
nmap <Leader>,zo :tabnew %<CR>
nmap <Leader>,zc :tabclose<CR>

nmap gp :PreviewTag <C-R>=expand("<cword>")<CR><CR>


""""""""""""" guntentages """"""""""""""""""""""
" gutentags 搜索工程目录的标志，当前文件路径向上递归直到碰到这些文件/目录名
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
"	let g:gutentags_modules += ['ctags']
"endif

" 将自动生成的 ctags/gtags 文件全部放入 ~/.cache/tags 目录中，避免污染工程目录
let s:vim_tags = expand('/root/.cache/tags')
let g:gutentags_cache_dir = s:vim_tags

" 配置 ctags 的参数
let g:gutentags_ctags_extra_args = ['--fields=+niazS', '--extras=+q']
let g:gutentags_ctags_extra_args += ['--c++-kinds=+px']
let g:gutentags_ctags_extra_args += ['--c-kinds=+px']

" 如果使用 universal ctags 需要增加下面一行
"let g:gutentags_ctags_extra_args += ['--output-format=e-ctags']

" 禁用 gutentags 自动加载 gtags 数据库的行为
let g:gutentags_auto_add_gtags_cscope = 1

" 检测 ~/.cache/tags 不存在就新建
if !isdirectory(s:vim_tags)
   silent! call mkdir(s:vim_tags, 'p')
endif

let $GTAGSLABEL = 'native-pygments'
"let $GTAGSCONF = '/home/felixdu/.gtags.conf'

"let g:gutentags_define_advanced_commands = 1

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

"let g:gutentags_trace = 1
"let netrw_browsex_viewer="/home/felixdu/bin/vimlinks"


"""""""""""""" RUN """"""""""""""""""""
let g:asyncrun_open=10
map <F5> :call Run()<CR>
func! Run()
    exec "w"
    if &filetype == 'c'
        exec "AsyncRun gcc % -o %< && ./%<"
    elseif &filetype == 'python'
	exec "AsyncRun -raw=1 python3 %"
    elseif &filetype == 'cpp'
        exec "AsyncRun g++ % -o %< && ./%<"
    elseif &filetype == 'go'
        exec "AsyncRun -raw=1 go run %"
    elseif &filetype == 'java'
        exec "AsyncRun javac %"
    elseif &filetype == 'sh'
        exec "AsyncRun -raw=1 chmod +x ./% && ./%"
    endif
endfunc

" vim-markdown's concealcursor is conflict with indentLine, use this to solve
let g:indentLine_concealcursor = ''

let g:markdown_fenced_languages = ['java', 'bash=sh', 'python', 'c', 'c++', 'go', 'html', 'coffee', 'css', 'erb=eruby', 'javascript', 'js=javascript', 'json=javascript', 'ruby', 'sass', 'xml']

" Zoom / Restore window.
function! s:ZoomToggle() abort
    if exists('t:zoomed') && t:zoomed
        execute t:zoom_winrestcmd
        let t:zoomed = 0
    else
        let t:zoom_winrestcmd = winrestcmd()
        resize
        vertical resize
        let t:zoomed = 1
    endif
endfunction
command! ZoomToggle call s:ZoomToggle()
nnoremap <silent> <Leader>t :ZoomToggle<CR>

map <F6> :call RunBlock()<CR>
function! RunBlock()
    let startline = search('```', 'b')
    let endline = search('```')
    let content = getline(startline+1, endline-1)

    let ft = matchstr(getline(startline), '```\s*\zs[0-9A-Za-z_+-]*')
    if !empty(ft) && ft !~ '^\d*$'
        if ft == 'c'
            call writefile(content, '/tmp/vim-cb'.'.c')
            exec "AsyncRun -raw gcc /tmp/vim-cb.c -o /tmp/vim-cb.bin && /tmp/vim-cb.bin"
        elseif ft == 'python'
            call writefile(content, '/tmp/vim-cb'.'.py')
            exec "AsyncRun -mode=term -pos=bottom -raw python3 /tmp/vim-cb.py"
        elseif ft == 'c++'
            call writefile(content, '/tmp/vim-cb'.'.cpp')
            exec "AsyncRun -raw g++ /tmp/vim-cb.cpp -o /tmp/vim-cb.bin && /tmp/vim-cb.bin"
        elseif ft == 'go'
            call writefile(content, '/tmp/vim-cb'.'.go')
            exec "AsyncRun -raw go run /tmp/vim-cb.go"
        elseif ft == 'java'
            call writefile(content, '/tmp/vim-cb'.'.java')
            exec "AsyncRun -raw javac /tmp/vim-cb.java"
        elseif ft == 'sh'
            call writefile(content, '/tmp/vim-cb'.'.sh')
            "exec "AsyncRun -raw=1 chmod +x /tmp/vim-cb.sh && /tmp/vim-cb.sh"
            exec "AsyncRun -mode=term -pos=bottom -raw=1 chmod +x /tmp/vim-cb.sh && /tmp/vim-cb.sh"
	else
            echo ft
        endif
    endif
endfunction

let g:ycm_show_diagnostics_ui = 1
let g:fzf_layout = { 'down': '~60%' }
cs add cscope.out











gtags提供了基于命令列的程式，让你指定原始码所在的目录执行建立索引的动作。它同时也提供程式让你得如同操作grep按一般，针对索引结构进行搜寻及检索。它提供了许多有用的检索方式，例如找出专案中定义某个资料结构的档案及定义所在的行号，或者是找出专案中所有引用某资料结构的档案，以及引用处的行号。 

这么一来，你就可以轻易地针对阅读程式码时的需求予以检索。相较于grep按所能提供的支援， gtags这样的工具，简直是强大许多。 
