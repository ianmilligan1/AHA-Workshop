# Setting up SFM on AWS

Spin up AWS/Compute Canada/etc. machine, Ubuntu 14.04. Ensure HTTP port open 80 in security group (ingress) in addition to regular SSH. I have tested on m3.medium, and m4.large. I recommend the latter (as does the SFM team when doing tests). For real production an even beefier machine is needed. Due to size of web data, they also recommend provisioning at least 150GB in EBS for testing purposes.

## Step One: Install Docker

```bash
sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt-get update
sudo apt-get install linux-image-extra-$(uname -r) linux-image-extra-virtual
sudo apt-get install docker-engine
sudo service docker start
sudo docker run hello-world
```

We now need to install docker-compose as well.

```bash
sudo -i
curl -L "https://github.com/docker/compose/releases/download/1.8.1/docker-compose-$(uname -s)-$(uname -m)" > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
exit
```

And then doublecheck with:

```bash
docker-compose --version
```

## Step Two: Get SFM Up and Running

```bash
git clone https://github.com/gwu-libraries/sfm-docker.git
cd sfm-docker
cp example.prod.docker-compose.yml docker-compose.yml
cp example.env .env
```

## Step Three: Configure .env file 

See the file in this directory. But for the lazy, paste in the following. You'll have to make a few changes, however:
- under SFM UI CONFIGURATION, you'll need to put the hostname of your instance. You can find that on the EC2 dashboard, or by running `curl http://169.254.169.254/latest/meta-data/public-hostname` on your command line. It will be something like `ec2-35-160-5-220.us-west-2.compute.amazonaws.com`.
- make sure SFM_PORT is 80, and that it is open in your Security Group
- for production, you will want to have an external volume to store data. Under `VOLUME CONFIGURATION`, you'll see `/src/sfm-data:/sfm-data`. Change the first volume to where you want it to be stored, for example `/mnt/vol1/sfm-data:/sfm-data` will store the data in your external mount.
- finally, make sure to change the passwords and e-mails below to what you want to use.

```bash
# For information on installation and configuration, see http://sfm.readthedocs.io/en/latest/install.html.

# Note that changes made to this file AFTER SFM is brought up will require one or
# containers to be restarted for the changes to go into effect.
# For more information, see http://sfm.readthedocs.io/en/latest/install.html#configuration

# COMMON CONFIGURATION
TZ=America/New_York
COMPOSE_PROJECT_NAME=sfm

# VOLUME CONFIGURATION
# Volumes come in 2 types: normal Docker volumes (e.g., /sfm-data)
# or host volumes (which link to an external location; e.g., /src/sfm-data:/sfm-data).
# An internal volume should be adequate for development; for production,
# you probably want to use a link to an external location.
# Note that the external location should be created before SFM is brought up.
# The data volume is where:
# * all of harvested social media content is stored.
# * the db files are located.
# * web harvests are stored.
DATA_VOLUME=/sfm-data
#DATA_VOLUME=/src/sfm-data:/sfm-data
# The processing volume is where processed data is stored when using a processing
# container. Use porcessing.docker-compose.yml to start a processing container.
PROCESSING_VOLUME=/sfm-processing
#PROCESSING_VOLUME=/src/sfm-processing:/sfm-processing
# sfm-data free space threshold to send notification emails,only ends with MB,GB,TB. eg. 500MB,10GB,1TB
DATA_VOLUME_THRESHOLD=10GB
# sfm-processing free space threshold to send notification emails,only ends with MB,GB,TB. eg. 500MB,10GB,1TB
PROCESSING_VOLUME_THRESHOLD=10GB

# DOCKER LOG CONFIGURATION
# This limits the size of the logs kept by Docker for each container.
# For more information, see https://docs.docker.com/engine/admin/logging/overview/#json-file-options
DOCKER_LOG_MAX_SIZE=50m
DOCKER_LOG_MAX_FILE=4

# SFM UI CONFIGURATION
# This is the public hostname and port. It is used for Django's ALLOWED_HOSTS
# and for links in emails.
# For production, this must be set correctly or you will get a bad request (400).
SFM_HOSTNAME=ec2-35-160-5-220.us-west-2.compute.amazonaws.com
SFM_PORT=80

# To send email, set these correctly.
# For GW users, ask for the password for sfm_no_reply@email.gwu.edu.
SFM_SMTP_HOST=smtp.gmail.com
SFM_EMAIL_USER=sfm_no_reply@email.gwu.edu
SFM_EMAIL_PASSWORD=password

# To enable connecting to social media accounts, provide the following.
# They are not necessary.
#TWITTER_CONSUMER_KEY=blah
#TWITTER_CONSUMER_SECRET=blah
#WEIBO_API_KEY=13132044538
#WEIBO_API_SECRET=68aea49fg26ea5072ggec14f7c0e05a52
#TUMBLR_CONSUMER_KEY=Fki09cW957y56h6fhRtCnig14QhpM0pjuHbDWMrZ9aPXcsthVQq
#TUMBLR_CONSUMER_SECRET=aPTpFRE2O7sVl46xB3difn8kBYb7EpnWfUBWxuHcB4gfvP

# For automatically created admin account
SFM_SITE_ADMIN_NAME=admin
SFM_SITE_ADMIN_EMAIL=i2millig@uwaterloo.ca
SFM_SITE_ADMIN_PASSWORD=ADDPASSWORD

# RABBIT MQ CONFIGURATION
RABBITMQ_USER=sfm_user
RABBITMQ_PASSWORD=password
RABBITMQ_MANAGEMENT_PORT=15672

# DB CONFIGURATION
POSTGRES_PASSWORD=ADDPASSWORD

# HARVESTER CONFIGURATION
# *_TRIES is the number of time to try harvests.
# Setting to more than 1 causes retries on errors. Setting to 0 causes
# infinite retries.
TWITTER_REST_HARVEST_TRIES=3
TWITTER_STREAM_HARVEST_TRIES=3
TUMBLR_HARVEST_TRIES=3
WEIBO_HARVEST_TRIES=3
FLICKR_HARVEST_TRIES=3

# WEB HARVESTER CONFIGURATION
HERITRIX_USER=sfm_user
HERITRIX_PASSWORD=ADDPASSWORD
HERITRIX_ADMIN_PORT=8443
# Contact used when web harvesting
HERITRIX_CONTACT_URL=http://ianmilligan.ca

## DEVELOPMENT-ONLY CONFIGURATION.
# When using prod.docker-compose.yml, these are ignored.
DEBUG=True
DEBUG_WARCPROX=False

# Set to "release" to use released version of sfm-utils and warcprox.
# Set to "master" to use master version of sfm-utils.
# Set to "dev" to link in a local sfm-utils running in development mode. A host volume must also be added
# for the container in docker-compose.yml. (See the commented out volumes section in docker-compose.yml.)
UI_REQS=master
TWITTER_REQS=master
FLICKR_REQS=master
TUMBLR_REQS=master
WEIBO_REQS=master
WEB_REQS=master

# SFM UI DEVELOPMENT CONFIGURATION
# "master-runserver" to run with SFM UI runserver. "master" to run SFM UI with Apache.
UI_TAG=master-runserver
# To have some test accounts created.
LOAD_FIXTURES=True
# This adds a 5 minute schedule option to speed testing.
FIVE_MINUTE_SCHEDULE=True
```

## Step Four: Deploy

Add user credentials:

```bash
sudo groupadd docker
sudo gpasswd -a ${USER} docker
sudo service docker restart
```

Alternatively, can run `docker-compose` commands below as `sudo`.

```bash
docker-compose up -d
docker-compose scale twitterrestharvester=2
```

This will take some time. Go have a coffee. :)

Wait. Should be available on public DNS available via EC2 dashboard.

## Step Five: Save Money

We don't want to have the large AWS instance sittingly idly by when not doing anything. So since it is all stored on an EBS volume, we can safely stop it (this way, we only pay for the EBS value - $10/month for 100GB, rather than the roughly $700/month it would cost for a beefy AWS instance to run.

When resuming, will have to manually update the `.env` file to reflect the newly-assigned Amazon Public DNS. Change that in `.env` and run `docker-compose up -d`.
