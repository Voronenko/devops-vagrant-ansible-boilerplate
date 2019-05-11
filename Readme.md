Vagrant ansible boilerplate
===========================

Boilerplate for project level Vagrant file


Usage - fork/copy, adjust  deployment/vagrant/vagrant_config.yml

```
vagrant box list
bento/centos-7.3     (virtualbox, 201708.22.0)
centos/6             (virtualbox, 1811.02)
centos/6             (virtualbox, 1902.01)
centos/7             (virtualbox, 1811.02)
centos/7             (virtualbox, 1902.01)
debian/jessie64      (virtualbox, 8.11.0)
debian/stretch64     (virtualbox, 9.6.0)
debian/wheezy64      (virtualbox, 7.11.2)
generic/fedora28     (virtualbox, 1.8.52)
generic/fedora28     (virtualbox, 1.8.54)
generic/rhel7        (virtualbox, 1.8.52)
littlebigmake        (virtualbox, 0)
mwrock/Windows2012R2 (virtualbox, 0.6.1)
mwrock/Windows2016   (virtualbox, 0.3.0)
ubuntu/bionic64      (virtualbox, 20181222.0.0)
ubuntu/bionic64      (virtualbox, 20190503.0.0)
ubuntu/trusty64      (virtualbox, 20181207.0.2)
ubuntu/trusty64      (virtualbox, 20190429.0.0)
ubuntu/xenial64      (virtualbox, 20181223.0.0)
ubuntu/xenial64      (virtualbox, 20190501.0.0)
```


Put your custom provisioning logic into `Vagrantfile.provision`, for example

```

# ================================== CUSTOM PROVISIONING
#    https://www.vagrantup.com/docs/provisioning/ansible_common.html
      config.vm.provision "ansible" do |ansible|
          ansible.playbook = "deployment/provisioners/lamp-box/box_lamp.yml"
          ansible.verbose = true
          ansible.groups = {
              "lamp_box" => [vconfig['vagrant_machine_name']]
          }
      end

# /================================== CUSTOM PROVISIONING

```

You can also have untracked `Vagrantfile.local` which allows you to locally modify some aspects for the shared project Vagrantfile.


Basing on https://galaxy.ansible.com/softasap roles  there are multiple compatible "box provisioners",
which share common approach with both Vagrant and Terraform provisioners, that allow you to reuse the same 
code organization for production deployment also.

For terraform part check out https://github.com/Voronenko/devops-terraform-ansible-boilerplate


For managing boxes, you can use repo manager like gilt

```
# https://gilt.readthedocs.io/en/latest/
  - git: https://github.com/oops-to-devops/node-box.git
    version: master
    dst: deployment/provisioners/node-box/
    post_commands:
      - make
```
