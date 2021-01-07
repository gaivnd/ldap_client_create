# ldap_client_create
1.sudo apt-get install ldap-utils ldap-auth-client libnss-ldap libpam-ldap


2.config /etc/ldap.conf
base ou=People,o=NSN
uri ldap://ed-p-es.emea.nsn-net.net


3.all users have sudoer permission
	/etc/sudoers--> %docker ALL=(ALL:ALL) ALL  -->make sure docker group have sudo permission
	
   all users have been added into docker group
	/etc/group  ---> change docker group to 55555
  ldap remote user will belong to group 55555


4./etc/nsswitch.conf -->
ldap身份验证
passwd:         files systemd ldap
group:          files systemd ldap


5./etc/pam.d/common-password    删除的use_authtok
password      [success=1 user_unknown=ignore default=die]     pam_ldap.so try_first_pass


6./etc/pam.d/common-session-->登入时copy /etc/skel目录下的内容为/home/username/
session optional pam_mkhomedir.so skel=/etc/skel umask=022


7.git clone https://github.com/gaivnd/ldap_client_create.git




Note that：
ldap_client_create/ldap_server_config/etc/skel/.vim/plugged
Need install related plug
