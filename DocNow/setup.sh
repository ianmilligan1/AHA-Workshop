# To do tomorrow:
#- generate new security group 'vagrant'
#- generate brand new SSH keys for docnow server

## setup
export PS1="\[\033[36m\]\u\[\033[m\]@\[\033[32m\]\h:\[\033[33;1m\]\w\[\033[m\]\$ "
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad
alias ls='ls -GFh'

sudo apt-get install git

## bring private key over to the server (use new one), chmod 400

## vagrant
wget https://releases.hashicorp.com/vagrant/1.8.6/vagrant_1.8.6_x86_64.deb
sudo dpkg -i vagrant_1.8.6_x86_64.deb
sudo apt-get install -f .

## install plugin
vagrant plugin install vagrant-aws

## clone docnow
git clone https://github.com/docnow/dnflow-ansible
cd dnflow-ansible

## then change the group_vars/all_template file w/ Twitter Developer Credentials

vagrant up --provider aws

cp provider/example.aws.yml provider/aws.yml

## then edit aws.yml with AWS credentials

vagrant up --provider aws