# Setting up DocNow on AWS

Spin up Ubuntu 14.04. Set security group for SSH and HTTP (port 80). 

## Step One: Installing Dependencies

```bash
sudo apt-get install git
sudo apt-get install bundler
sudo apt-get install libgmp-dev
wget https://releases.hashicorp.com/vagrant/1.8.6/vagrant_1.8.6_x86_64.deb
sudo dpkg -i vagrant_1.8.6_x86_64.deb
sudo apt-get install -f .
vagrant plugin install vagrant-aws
```

## Step Two: Documenting the Now

```bash
git clone https://github.com/docnow/dnflow-ansible
cd dnflow-ansible
```

We now need to configure the file in `group_vars/all_template`. Mine looks like this:

```
---
hostname: "{{ ansible_default_ipv4.address }}"
twitter_consumer_key: INSERTKEYHERE
twitter_consumer_secret: INSERTKEYHERE
http_basicauth_user:
http_basicauth_pass:
```

You can get your Twitter key from setting up an application at <https://apps.twitter.com/>.

I also found that we needed to add a line to the `VagrantFile` found in `dnflow-ansible`. I changed this block by adding the `provider.security_groups` setting.

```
### AWS provider
  config.vm.provider :aws do |provider, override|
    settings = load_settings 'aws'
    provider.access_key_id = settings['access_key_id']
    provider.secret_access_key = settings['secret_access_key']
    provider.keypair_name = settings['keypair_name']
    provider.security_groups = settings['security_group']
    provider.ami = settings['ami']
    provider.region = settings['region']
    provider.monitoring = settings['monitoring']
    override.vm.box = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"
    override.ssh.username = settings["ssh_username"]
    override.ssh.private_key_path = settings['private_key_path']
  end
```

With this done, let's launch it.

```bash
vagrant up --provider aws
```

It will install dependencies (`vagrant-trigger` at this time as we have already installed `vagrant-aws`). Now we need to edit one more file.

```bash
cp provider/example.aws.yml provider/aws.yml
```

Edit aws.yml with some AWS credentials. Mine looks like this. A few quick notes:
- the `access_key_id` and `secret_access_key` come from your Security settings on AWS. 
- the `keypair_name` is the name of the .pem file you use to SSH into the instance.
- the `ami` is found on the EC2 dashboard. I like to keep everything in the same AWS region.
- `security_group` is found on the EC2 dashboard. Note my unoriginal name, so you might be better off giving it a name like 'docnow'
- path to the private_key that is now found on this machine. I `scp`ed it over. 

```
---
# Documentation: https://github.com/mitchellh/vagrant-aws
access_key_id: AMAZONKEYHERE
secret_access_key: AMAZONSECRETKEYHERE
keypair_name: docnow
ami: ami-01f05461
security_group: launch-wizard-15
instance_type: m3.medium
private_key_path: /home/ubuntu/docnow.pem
region: us-west-2
ssh_username: ubuntu
monitoring: true
```

Now let's run it again.

```bash
vagrant up --provider aws
```

This brings up a new AWS machine. Sometimes it fails with errors. I've found that if you run it again, it often works. Hope you have your credit card handy. ;)

## Step Three: Connect to new machine

You can connect via `vagrant ssh` or via the standard EC2 method. I prefer the latter. If you go to your AWS dashboard, you'll see a new machine that is now spun up. Wait for it to finish initalizing (can take a few minutes).

On the new machine, you need to edit two files, `/home/docnow/dnflow/dnflow.cfg` and `/etc/nginx/sites-enabled/docnow`. Both are read only so will need to be edited via `sudo`.

My dnflow.cfg looks like:

```
HOSTNAME = 'IP FROM AMAZON DASHBOARD TO VAGRANT MACHINE'
DEBUG = True
DATABASE = 'db.sqlite3'
SECRET_KEY = 'a super secret key'
STATIC_URL_PATH = '/static'
DATA_DIR = 'data'
MAX_TIMEOUT = 2 * 60 * 60  # two hours should be long enough
REDIS_HOST = 'localhost'
REDIS_PORT = 6379
REDIS_DB = 4
TWITTER_CONSUMER_KEY = 'TWITTERKEY'
TWITTER_CONSUMER_SECRET = 'TWITTERKEY'
```

And my docnow looks like:

```
server {
  listen 80;
  listen [::]:80 default_server ipv6only=on;
  server_name server_name IPFROMDASHBOARDHERE;
  location / {
    include uwsgi_params;
    uwsgi_pass 127.0.0.1:8001;
      }
  location /static {
    alias /home/docnow/dnflow/static;
      }
}

server {
  listen 8080 default_server;
  listen [::]:8080 default_server ipv6only=on;
  location / {
    proxy_pass http://localhost:8082;
      }
}
```

We then stop and start via

```
sudo stop docnow
sudo start docnow
```

After waiting, the URL should be available on the IP address you've added the two files above.

## Step Four: Saving AWS Money

Even on an m3.medium, server will suck down money slowly (the fun of AWS). Luckily, the vagrant instance comes with an EBS storage volume.

So when you don't want to use the server, you can stop it on the EC2 dashboard. When you resume, you will have to make sure to change the IP address in `/home/docnow/dnflow/dnflow.cfg` and `/etc/nginx/sites-enabled/docnow`. Stop and start the service again, and DocNow should be running on the new IP. 
