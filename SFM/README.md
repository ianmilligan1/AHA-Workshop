# Setting up SFM
Spin up AWS machine, Ubuntu 14.04. Ensure HTTP port open 80.

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

## Step Two: Get SFM Up and Running

```bash
git clone https://github.com/gwu-libraries/sfm-docker.git
cd sfm-docker
cp example.prod.docker-compose.yml docker-compose.yml
cp example.env .env
```

## Step Three: Configure .env file 

See the file in this directory.

## Step Four: Profit?

```bash
docker-compose up -d
docker-compose scale twitterrestharvester=2
```

Wait. Should be available on public DNS available via EC2 dashboard.
