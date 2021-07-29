#!/usr/bin/env bash

# disable selinux
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

# change localtime
\cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# install some tools
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
yum install -y vim telnet bind-utils wget psmisc net-tools ntp

# sync system time
ntpdate 0.asia.pool.ntp.org

# close firewalld
systemctl stop firewalld && systemctl disable firewalld

# reset iptables
iptables -F && iptables -X && iptables -F -t nat && iptables -X -t nat && iptables -P FORWARD ACCEPT

# disable swap
swapoff -a
sed -i '/swap/s/^\(.*\)$/#\1/g' /etc/fstab

# open password auth for backup if ssh key doesn't work, bydefault, username=vagrant password=vagrant
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
systemctl restart sshd

# install docker
# step 1: install docker dependence
yum install -y yum-utils device-mapper-persistent-data lvm2
# Step 2: add software metadata
yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
# Step 3
sed -i 's+download.docker.com+mirrors.aliyun.com/docker-ce+' /etc/yum.repos.d/docker-ce.repo
# Step 4: install Docker-CE
yum makecache fast
yum -y install docker-ce-18.06.3.ce-3.el7
# Step 4: start docker service
mkdir -p /etc/docker
mkdir -p /data/docker

cat > /etc/docker/daemon.json <<EOF
{
  "graph": "/data/docker",
  "exec-opts": ["native.cgroupdriver=systemd"],
  "registry-mirrors": ["https://registry.cn-hangzhou.aliyuncs.com"]
}
EOF
 
systemctl start docker && systemctl enable docker

# install kubernetes
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
setenforce 0

# enable br_netfilter module
cat <<EOF | tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

# network params
cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward=1
vm.swappiness=0
vm.overcommit_memory=1
vm.panic_on_oom=0
fs.inotify.max_user_watches=89100
EOF
sysctl --system

# install kubeadm, kubectl, and kubelet.
if [ $KUBE_VERSION ];then
	yum install -y --nogpgcheck kubelet-${KUBE_VERSION} kubeadm-${KUBE_VERSION} kubectl-${KUBE_VERSION}
else
	yum install -y --nogpgcheck kubelet kubeadm kubectl
fi

systemctl start kubelet && systemctl enable kubelet
