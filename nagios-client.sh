useradd nagios
apt-get install gcc -y
sudo apt-get install build-essential -y
wget https://nagios-plugins.org/download/nagios-plugins-2.1.2.tar.gz
tar -xvzf nagios-plugins-2.1.2.tar.gz
cd nagios-plugins-2.1.2
./configure --with-nagios-user=nagios
make all
make install
chown nagios.nagios /usr/local/nagios
chown -R nagios.nagios /usr/local/nagios/libexec
cd ~
wget http://sourceforge.net/projects/nagios/files/nrpe-2.x/nrpe-2.15/nrpe-2.15.tar.gz
tar -xzvf nrpe-2.15.tar.gz
cd nrpe-2.15
apt-get install libssl-dev -y
dpkg -L libssl-dev
ln -s /usr/lib/x86_64-linux-gnu/libssl.so /usr/lib/libssl.so
./configure --enable-command-args
make all
make install-plugin
make install-daemon
make install-daemon-config
apt-get install xinetd -y
make install-xinetd
sed -ie 's/127.0.0.1/127.0.0.1\ 52.66.166.6/g' /etc/xinetd.d/nrpe
sed -ie 's/dont_blame_nrpe=0/dont_blame_nrpe=1/g' /usr/local/nagios/etc/nrpe.cfg
echo "nrpe 5666/tcp # NRPE" >> /etc/services
service xinetd restart

