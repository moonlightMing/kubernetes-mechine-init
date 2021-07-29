# Kubernetes machine init

Kubernetes测试环境初始化脚本，使用[Vagrant](https://www.vagrantup.com/)进行机器初始化，默认安装配置版本的k8s组件及kubeadm，并且将yum源和镜像源都替换为国内阿里源。

## Usage
Vagrant使用了[vagrant-hostmanager](https://github.com/devopsgroup-io/vagrant-hostmanager)插件，初始化后hostname会自动写入宿主机和各个虚拟机的hosts文件中，可以直接用主机名进行通信或访问harbor的后台。

```shell
$ git clone https://github.com/moonlightMing/kubernetes-mechine-init

$ vagrant plugin install vagrant-hostmanager
$ vagrant up
```

默认是1镜像仓库、1控制平面、2工作节点的配置，也可以按需求自定义虚拟机数量，比如需要拓展为3控制平面作高可用、3工作节点时则如下
```ruby
boxes = [
  # image registry
  {
      :hostname => "harbor.local",
      :ip => "192.168.33.50",
      :mem => "4096",
      :cpu => "2"
  },
  # m => master
  {
      :hostname => "m1",
      :ip => "192.168.33.51",
      :mem => "2048",
      :cpu => "2"
  },
  {
      :hostname => "m2",
      :ip => "192.168.33.52",
      :mem => "2048",
      :cpu => "2"
  },
  {
      :hostname => "m3",
      :ip => "192.168.33.53",
      :mem => "2048",
      :cpu => "2"
  },
  # w => worker
  {
      :hostname => "w1",
      :ip => "192.168.33.56",
      :mem => "2048",
      :cpu => "2"
  },
  {
      :hostname => "w2",
      :ip => "192.168.33.57",
      :mem => "2048",
      :cpu => "2"
  }，
  {
      :hostname => "w3",
      :ip => "192.168.33.58",
      :mem => "2048",
      :cpu => "2"
  }
]
```

模板还提供了一个默认的kubeadm配置文件，在不修改m1主机IP的情况下可以直接用。
Vagrant默认情况下会将启动目录下的文件都挂载在/vagrant，所以可以直接在m1上执行初始化语句
```shell
$ kubeadm init --config /vagrant/kubeadm.yaml
```