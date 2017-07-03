###############################################################################################
# Purpose:  Provide a Flask+nginx+uwsgi container on Ubuntu 16.04 via ports 80 and 443
#
# Build and Run:
# sudo docker build -t flaskwebpage .
# sudo docker run -d -p 80:80 -p 443:443 --restart=always -t --name flaskwebpage flaskwebpage
#
# Letsencrypt certbot-auto installs automatically.  You can uncomment running it, below, if you want to do it on build
#
# Forked from Thatcher Peskens <thatcher@dotcloud.com>
#    github - https://github.com/atupal/dockerfile.flask-uwsgi-nginx
###############################################################################################

from ubuntu:16.04

# Add all local code to the docker container
add . /home/flask/

#Add latest nginx repo and install base programs
run apt-get update
run apt-get install -y software-properties-common
run add-apt-repository -y ppa:nginx/stable
run apt-get install -y build-essential nano nginx python python-dev python-setuptools python-software-properties supervisor wget

# Install uwsgi and flask via the requirements.txt file
run easy_install pip
run pip install -r /home/flask/conf/requirements.txt

#Update all the things
run apt-get update && apt-get -y upgrade

# Config all the things
run rm /etc/nginx/sites-enabled/default
run ln -s /home/flask/conf/nginx.conf /etc/nginx/sites-enabled/
run ln -s /home/flask/conf/supervisor.conf /etc/supervisor/conf.d/

#Get Letsencrypt certbot
run wget -O /home/flask/certbot-auto https://dl.eff.org/certbot-auto
run chmod a+x /home/flask/certbot-auto

#If you want to run certbot right away, you can uncomment the below, using your domain
#YOU WILL HAVE TO UPDATE THE NGINX CONF LATER!
#Use Option 2: Place files in a webroot directory (webroot)
#/home/flask/certbot-auto certonly -d [domain] -w /home/flask/app


# Expose both ports in case you want to start using 443
expose 80 443
cmd ["supervisord", "-n"]
