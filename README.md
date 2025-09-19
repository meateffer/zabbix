
# zabbix

things I ran into with zabbix

## samba_share_test 

(template + script, script goes into the external scripts folder, usually /usr/lib/zabbix/externalscripts/ )
- check if a share is available or not on the network
- returns 1 if the share is accessible and can be written to, 0 if not.
- script is using smbclient to connect, make sure you install it
- share is defined in the key (/tmp by default)
 ### macros (can be set either in the template or on the host, or both, obviously the host macros take precedence)

 {$SMB_PASS}

 {$SMB_SUBDIR} - by default zbxprobe, it's the subdir the script is trying to write to

 {$SMB_USER}

## samba_share_performance_test


(template + script, script goes into the external scripts folder, usually /usr/lib/zabbix/externalscripts/ )
- check the performance of writing to a network share
- returns sizeof, write ms, read ms, total ms 
(example: 2025-09-19 12:35:29 PM	{"ok":1,"size_mb":25,"write_ms":347,"read_ms":349,"total_ms":696,"mb_s":35.920})
- script is using smbclient to connect, make sure you install it
- share is defined in the key (/tmp by default)
### macros (can be set either in the template or on the host, or both, obviously the host macros take precedence)
{$SMB_PASS}

{$SMB_SIZE_MB} - size of the file you need to test with

{$SMB_SUBDIR} - by default zbxprobe, it's the subdir the script is trying to write to

{$SMB_USER}
