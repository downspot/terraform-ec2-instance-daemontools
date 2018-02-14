#!/bin/sh
yum -y remove java-1.7.0-openjdk
yum -y install java-1.8.0-openjdk nrpe nagios-plugins-procs
#
aws s3 cp s3://example_application/nagios/nrpe.cfg /etc/nagios/
aws s3 cp s3://example_application/nagios/check.cfg /etc/nrpe.d/
chkconfig nrpe on
/etc/init.d/nrpe restart
#
aws s3 cp s3://example_application/daemontools-0.76-1.x86_64.rpm /tmp/
rpm -ivh /tmp/daemontools-0.76-1.x86_64.rpm
initctl start daemontools
#
mkdir -p /var/service 
aws s3 sync s3://example_application/joiner /var/service/joiner/
aws s3 sync s3://example_application/clicks_trainer /var/service/clicks_trainer/
aws s3 sync s3://example_application/recs_trainer /var/service/recs_trainer/
#
chmod +x /var/service/*/run
chmod +x /var/service/*/log/run
mkdir /var/service/{clicks_trainer,joiner,recs_trainer}/log/main
#ln -s /var/service/joiner /service
#ln -s /var/service/clicks_trainer /service
#ln -s /var/service/recs_trainer /service
