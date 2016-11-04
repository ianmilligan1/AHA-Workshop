# Setting up DocNow on AWS from Local Machine

Tested on OS X 10.

## Step One: Installing Dependencies

- Install Vagrant (https://www.vagrantup.com/downloads.html)
- Install git
- Install Virtualbox (https://www.virtualbox.org/)

And two dependencies:

```bash
vagrant plugin install vagrant-aws
vagrant plugin install vagrant-triggers
``` 

## Step Two: Documenting the Now

```bash
git clone https://github.com/docnow/dnflow-ansible
cd dnflow-ansible
```

We now need to configure the file in `group_vars/all_template`. Mine looks like this. You can get your Twitter key from setting up an application at <https://apps.twitter.com/>.


```
---
hostname: "{{ ansible_default_ipv4.address }}"
twitter_consumer_key: INSERTKEYHERE
twitter_consumer_secret: INSERTKEYHERE
http_basicauth_user:
http_basicauth_pass:
google_analytics:
```

Now we need to edit one more file.

```bash
cp provider/example.aws.yml provider/aws.yml
```

Edit aws.yml with some AWS credentials. Mine looks like this. A few quick notes:
- the `access_key_id` and `secret_access_key` come from your Security settings on AWS. 
- the `keypair_name` is the name of the .pem file you use to SSH into the instance.
- the `ami` is found on the EC2 dashboard. I like to keep everything in the same AWS region.
- path to the private_key that is now found on this machine. I `scp`ed it over. 

Mine looks like:

```
---
# Documentation: https://github.com/mitchellh/vagrant-aws
access_key_id: AMAZONKEYHERE
secret_access_key: AMAZONSECRETKEYHERE
keypair_name: docnow
ami: ami-01f05461
instance_type: m3.medium
private_key_path: /home/ubuntu/docnow.pem
region: us-west-2
ssh_username: ubuntu
monitoring: true
```

Now let's run it.

```bash
vagrant up --provider aws
```

This brings up a new AWS machine. Sometimes it fails with errors. 

On the EC2 dashboard, I now change the security group to something with ports 22 and 80 open.

## Step Three: Connect to new machine

You can connect via the standard EC2 method. If you go to your AWS dashboard, you'll see a new machine that is now spun up. Wait for it to finish initalizing (can take a few minutes).

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