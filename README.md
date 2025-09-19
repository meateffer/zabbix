
# zabbix

things I ran into with zabbix

#samba_share_test 

(template + script, script goes into the external scripts folder, usually /usr/lib/zabbix/externalscripts/ )
- needed to check if a share is available or not on the network, returns 1 if the share is accessible and can be written to, 0 if not.
 #macros (can be set either in the template or on the host, or both, obviously the host macros take precedence)

 {$SMB_PASS}

 {$SMB_SUBDIR} - by default zbxprobe, it's the subdir the script is trying to write to

 {$SMB_USER}

