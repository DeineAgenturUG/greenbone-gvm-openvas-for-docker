select r.host                                                                               as "ip",
       r.hostname                                                                           as "hostname",
       rhd_mac.value                                                                        as "mac",
       rhd_os_txt.value                                                                     as "os_txt",
       rhd_os_cpe.value                                                                     as "os_cpe",
       app.cpes                                                                             as "app_cpes",
       rhd_smb_auth.name                                                                    as "smb_auth_status",
       rhd_smb_auth.value                                                                   as "smb_auth_info",
       split_part(r.port, '/', 1)                                                           as "port",
       split_part(r.port, '/', 2)                                                           as "port_protocol",
       r.severity                                                                           as "cvss",
       (case
            when r.severity <= 0 then 'Log'
            when r.severity >= 0.1 and r.severity <= 3.9
                then 'Low'
            when severity >= 4.0 and severity <= 6.9
                then 'Medium'
            when severity >= 7.0 and severity <= 10.0
                then 'High' end)                                                            as "severity",
       (case
            when r.severity <= 0
                then 1
            else 0 end)                                                                     as "log",
       (case
            when r.severity >= 0.1 and r.severity <= 3.9
                then 1
            else 0 end)                                                                     as "low",
       (case
            when severity >= 4.0 and severity <= 6.9
                then 1
            else 0 end)                                                                     as "medium",
       (case
            when severity >= 7.0 and severity <= 10.0
                then 1
            else 0 end)                                                                     as "high",
       r.qod                                                                                as "qod",
       n.solution_type                                                                      as "solution_type",
       n.name                                                                               as "nvt_name",
       r.description                                                                        as "summary",
       r.nvt                                                                                as "nvt_oid",
       n.cve                                                                                as "cves",
       t.uuid                                                                               as "task_id",
       t.name                                                                               as "task_name",
       s.name                                                                               as "scanner_name",
       to_timestamp(r.date)                                                                 as "timestamp",
       r.uuid                                                                               as "result_uuid",
       r.id                                                                                 as "result_id",
       n.impact                                                                             as "impact",
       n.solution                                                                           as "solution",
       n.affected                                                                           as "affected",
       n.insight                                                                            as "insight",
       n.detection                                                                          as "detection_method",
       n.category                                                                           as "category",
       n.family                                                                             as "family",
       cve.ids                                                                              as "cves",
       url.ids                                                                              as "urls",
       concat(t.name, ' - (', to_char(to_timestamp(re.date), 'YYYY-MM-DD HH12:MI AM'), ')') as "scan_name",
       re.id                                                                                as "scan_id",
       to_timestamp(re.date)                                                                as "scan_date",
       tar.name                                                                             as "target_name",
       tar.hosts                                                                            as "target_hosts",
       tar.exclude_hosts                                                                    as "target_exclude_hosts",
       pl.name                                                                              as "port_list",
       (case
            when n.name like 'Beatport Player %'
                then 'Beatport Player'
            when n.name like 'PeaZIP %'
                then 'PeaZIP'
            when n.name like 'GZip'
                then 'GZip'
            when n.name like 'Aria2 %'
                then 'Aria2'
            when n.name like 'Avast %'
                then 'Avast'
            when n.name like 'Symantec Endpoint Protection %'
                then 'Symantec Endpoint Protection'
            when n.name like 'BitDefender %'
                then 'BitDefender'
            when n.name like 'Kaspersky Internet Security %' or n.affected like 'Kaspersky Anti-Virus%'
                then 'Kaspersky AntiVirus'
            when n.name like 'Windows Defender %' or n.name like '% Windows Defender %' or
                 n.affected like 'Microsoft Windows Defender %'
                then 'Windows Defender'
            when n.name like 'Malwarebytes %'
                then 'Malwarebytes'
            when n.name like 'VMware ESXi/ESX %' or n.name like '%VMware ESXi%'
                then 'VMware ESXi/ESX'
            when n.name like '% vCenter %'
                then 'vCenter'
            when n.name like 'VMware Fusion %'
                then 'VMware Fusion'
            when n.name like 'VMware Workstation %'
                then 'VMware Workstation'
            when n.name like 'VMware Player %'
                then 'VMware Player'
            when n.name like 'Huawei EulerOS %'
                then 'Huawei EulerOS'
            when n.name like 'Cisco ASA %' or n.name like 'Cisco Adaptive Security Appliance %'
                then 'Cisco ASA'
            when n.name like 'Cisco IOS %'
                then 'Cisco IOS'
            when n.name like 'Samba %'
                then 'Samba'
            when n.name like 'ImageMagick %'
                then 'ImageMagick'
            when n.name like 'Squid Proxy %'
                then 'Squid Proxy'
            when n.affected like 'Tor Browser %'
                then 'Tor Browser'
            when n.name like 'Google Chrome %' or n.name like 'Adobe Flash Player Within Google Chrome %'
                then 'Google Chrome'
            when n.name like 'Opera %'
                then 'Opera'
            when n.name like 'VLC Media Player %'
                then 'VLC Media Player'
            when n.name like 'Wireshark %'
                then 'Wireshark'
            when n.name like 'Foxit Reader %'
                then 'Foxit Reader'
            when n.name like 'ManageEngine %' or n.name like 'Manage Engine %'
                then 'ManageEngine'
            when n.name like 'IrfanView %'
                then 'IrfanView'
            when n.name like 'PostgreSQL %'
                then 'PostgreSQL'
            when n.name like 'Adobe Reader DC %'
                then 'Adobe Reader DC'
            when n.name like 'Adobe Reader%' or n.name like '% Adobe Reader %'
                then 'Adobe Reader'
            when n.name like 'Adobe Acrobat DC %'
                then 'Adobe Acrobat DC'
            when n.name like 'Adobe Acrobat %'
                then 'Adobe Acrobat'
            when n.name like 'Adobe Photoshop %'
                then 'Adobe Photoshop'
            when n.name like 'Adobe Shockwave Player %'
                then 'Adobe Shockwave Player'
            when n.name like 'Adobe Flash Player %'
                then 'Adobe Flash Player'
            when n.name like 'Adobe Air %' or n.name like 'Adobe AIR %' or n.affected like 'Adobe AIR %'
                then 'Adobe Air'
            when n.name like 'Adobe Creative Cloud %'
                then 'Adobe Creative Cloud'
            when n.name like 'Oracle MySQL %' or n.name like 'Oracle Mysql %' or n.name like 'MySQL %'
                then 'MySQL'
            when n.name like 'Oracle VirtualBox %' or n.name like 'Oracle Virtualbox %' or
                 n.name like 'Oracle VM VirtualBox %'
                then 'Oracle VirtualBox'
            when n.name like 'Oracle JRocKit %'
                then 'Oracle JRocKit'
            when n.name like 'Oracle WebLogic %'
                then 'Oracle WebLogic'
            when n.name like 'Oracle GlassFish %'
                then 'Oracle GlassFish'
            when n.affected like 'Oracle Database server %'
                then 'Oracle Database server'
            when n.name like 'Mozilla Firefox %' or n.name like 'Firefox %'
                then 'Mozilla Firefox'
            when n.name like 'Mozilla Thunderbird %' or n.affected like 'Thunderbird %'
                then 'Mozilla Thunderbird'
            when n.name like 'Mozilla Seamonkey %' or n.affected like 'Seamonkey %'
                then 'Mozilla Seamonkey'
            when n.name like 'H2O %'
                then 'H2O'
            when n.name like 'WinFTP %'
                then 'WinFTP'
            when n.name like 'Python %'
                then 'Python'
            when n.name like 'Node.js %'
                then 'Node.js'
            when n.name like '% PAN-OS %'
                then 'PAN-OS'
            when n.name like 'Junos %'
                then 'Junos'
            when n.name like 'HP-UX %'
                then 'HP-UX'
            when n.name like 'AlienVault OSSIM %'
                then 'AlienVault OSSIM'
            when n.name like 'FortiAnalyzer %' or n.name like '% FortiAnalyzer %'
                then 'FortiAnalyzer'
            when n.name like 'FortiMail %' or n.name like '% FortiMail %'
                then 'FortiMail'
            when n.name like 'FortiWeb %' or n.name like '% FortiWeb %'
                then 'FortiWeb'
            when n.name like 'FortiManager %'
                then 'FortiManager'
            when n.name like 'Fortinet FortiOS %' or n.name like 'FortiOS %'
                then 'Fortinet FortiOS'
            when n.name like 'MantisBT %'
                then 'MantisBT'
            when n.name like '% RealPlayer %'
                then 'RealPlayer'
            when n.name like 'Apple QuickTime %'
                then 'Apple QuickTime'
            when n.name like 'Apple Safari %'
                then 'Apple Safari'
            when n.name like 'Apple iTunes %'
                then 'Apple iTunes'
            when n.name like 'Apple iCloud %'
                then 'Apple iCloud'
            when n.name like 'Apple Mac OS X %' or n.name like 'Apple MacOSX %'
                then 'Apple Mac OS X'
            when n.name like 'nginx %' or n.name like 'Nginx %'
                then 'nginx'
            when n.name like 'Jetty %'
                then 'Jetty'
            when n.name like 'Docker %'
                then 'Docker'
            when n.name like 'Jenkins %'
                then 'Jenkins'
            when n.name like 'RealVNC %'
                then 'RealVNC'
            when n.name like 'Atlassian Confluence %'
                then 'Atlassian Confluence'
            when n.name like 'Emby Media Server %'
                then 'Emby Media Server'
            when n.name like 'Zabbix %'
                then 'Zabbix'
            when n.name like 'ClamAV %' or n.affected like 'ClamAV %'
                then 'ClamAV'
            when n.name like 'OpenVPN %'
                then 'OpenVPN'
            when n.name like 'OpenSSH %'
                then 'OpenSSH'
            when n.name like 'Perl %'
                then 'Perl'
            when n.name like 'Ruby on Rails %'
                then 'Ruby on Rails'
            when n.name like 'Ruby %'
                then 'Ruby'
            when n.name like 'Discourse %'
                then 'Discourse'
            when n.name like 'SOGo %'
                then 'SOGo'
            when n.affected like 'Foreman %'
                then 'Foreman'
            when n.name like 'PHP %'
                then 'PHP'
            when n.name like 'LimeSurvey %'
                then 'LimeSurvey'
            when n.name like 'CubeCart %'
                then 'CubeCart'
            when n.name like 'ownCloud %'
                then 'ownCloud'
            when n.name like 'Nextcloud %'
                then 'Nextcloud'
            when n.name like 'Joomla%'
                then 'Joomla'
            when n.name like 'CMS Made Simple %'
                then 'CMS Made Simple'
            when n.name like 'phpMyAdmin %'
                then 'phpMyAdmin'
            when n.name like 'phpPgAdmin %'
                then 'phpPgAdmin'
            when n.name like 'MyBB %'
                then 'MyBB'
            when n.name like 'phpBB %' or n.name like '%phpBB%'
                then 'phpBB'
            when n.name like 'vBulletin %'
                then 'vBulletin'
            when n.name like 'WordPress %'
                then 'WordPress'
            when n.name like 'Drupal %'
                then 'Drupal'
            when n.name like 'MediaWiki %'
                then 'MediaWiki'
            when n.name like 'Moodle %'
                then 'Moodle'
            when n.name like 'Bugzilla %'
                then 'Bugzilla'
            when n.name like 'Roundcube %'
                then 'Roundcube Webmail'
            when n.name like 'ISC BIND %'
                then 'ISC BIND'
            when n.name like 'Asterisk %' or n.affected like 'Asterisk %'
                then 'Asterisk'
            when n.name like 'Java %' or n.name like 'Oracle Java %'
                then 'Java'
            when n.name like 'OpenSSL%'
                then 'OpenSSL'
            when n.name like 'Webmin %'
                then 'Webmin'
            when n.affected like 'Grafana %'
                then 'Grafana'
            when n.name like 'Magento %'
                then 'Magento'
            when n.name like 'F5 BIG-IP %'
                then 'F5 BIG-IP'
            when n.name like 'Splunk %'
                then 'Splunk'
            when n.name like 'Serv-U %'
                then 'Serv-U'
            when n.name like 'LibreOffice %'
                then 'LibreOffice'
            when n.name like 'memcached %' or n.name like 'Memcached %'
                then 'memcached'
            when n.name like 'IBM Websphere Application Server %'
                then 'IBM Websphere Application Server'
            when n.name like 'IBM Db2 %'
                then 'IBM Db2'
            when n.name like 'Microsoft Internet Explorer %' or n.name like 'Microsoft IE %' or n.name like 'IE %' or
                 n.name like 'Microsoft Explorer %'
                then 'Microsoft Internet Explorer'
            when n.name like 'Microsoft .NET Framework %'
                then 'Microsoft .NET Framework'
            when n.name like '.NET Core %'
                then '.NET Core'
            when n.name like 'Microsoft SQL Server %'
                then 'Microsoft SQL Server'
            when n.name like 'Microsoft SharePoint %' or n.name like 'MS SharePoint Server %'
                then 'Microsoft SharePoint Server'
            when n.name like 'Microsoft Exchange %'
                then 'Microsoft Exchange Server'
            when n.name like 'Microsoft Lync %'
                then 'Microsoft Lync'
            when n.name like 'Microsoft Visio %'
                then 'Microsoft Visio'
            when n.name like 'Microsoft Project %'
                then 'Microsoft Project'
            when n.name like 'Microsoft Excel %'
                then 'Microsoft Excel'
            when n.name like 'Microsoft Outlook %'
                then 'Microsoft Outlook'
            when n.name like 'Microsoft PowerPoint %'
                then 'Microsoft PowerPoint'
            when n.name like 'Microsoft Word %'
                then 'Microsoft Word'
            when n.name like 'Microsoft Excel %'
                then 'Microsoft Excel'
            when n.name like 'Microsoft OneNote %'
                then 'Microsoft OneNote'
            when n.name like 'Microsoft Office %'
                then 'Microsoft Office'
            when n.name like 'Microsoft Silverlight %'
                then 'Microsoft Silverlight'
            when n.name like 'Elasticsearch Kibana %' or n.name like 'Elastic Kibana %'
                then 'Kibana'
            when affected like 'Elasticsearch Logstash %'
                then 'Logstash'
            when n.name like 'Elasticsearch %'
                then 'Elasticsearch'
            when n.name like 'Apache Tomcat %'
                then 'Apache Tomcat'
            when n.name like 'Apache CouchDB %'
                then 'Apache CouchDB'
            when n.name like 'Apache OpenOffice %' or n.name like 'OpenOffice %'
                then 'Apache OpenOffice'
            when n.name like 'Apache Hadoop %'
                then 'Apache Hadoop'
            when n.name like 'Apache HTTP%'
                then 'Apache HTTP Server'
            when n.name like 'Apache Struts %'
                then 'Apache Struts'
            when affected like 'Apache Subversion %' or affected like 'Subversion %' or n.name like 'Subversion %'
                then 'Apache Subversion'
            when n.name like 'ProFTPD %'
                then 'ProFTPD'
            when n.name like 'vsftpd %'
                then 'vsftpd'
            when n.name like 'Foxit Reader %' or n.name like '% Foxit Reader %' or n.affected like 'Foxit Reader%'
                then 'Foxit Reader'
            when n.name like 'MongoDB %'
                then 'MongoDB'
            when n.name like 'Microsoft Windows%' or n.name like 'MS Windows %' or n.affected like '%Microsoft Windows%'
                then 'Microsoft Windows'
           end)                                                                             as "app"
from results r
         left join report_hosts rh on r.host = rh.host and r.report = rh.report
         left join (select *
                    from report_host_details
                    where id in (select max(id) from report_host_details group by report_host, name)) rhd_os_txt
                   on rhd_os_txt.name = 'best_os_txt' and rh.id = rhd_os_txt.report_host
         left join (select *
                    from report_host_details
                    where id in (select max(id) from report_host_details group by report_host, name)) rhd_os_cpe
                   on rhd_os_cpe.name = 'best_os_cpe' and rh.id = rhd_os_cpe.report_host
         left join (select *
                    from report_host_details
                    where id in (select max(id) from report_host_details group by report_host, name)) rhd_smb_auth
                   on (rhd_smb_auth.name = 'Auth-SMB-Failure' or rhd_smb_auth.name = 'Auth-SMB-Success') and
                      rh.id = rhd_smb_auth.report_host
         left join (select *
                    from report_host_details
                    where id in (select max(id) from report_host_details group by report_host, name)) rhd_mac
                   on rhd_mac.name = 'MAC' and rh.id = rhd_mac.report_host
         left join (select array_agg(value) as cpes, report_host
                    from report_host_details
                    where name = 'App'
                    group by report_host) app
                   on rh.id = app.report_host
         left join hosts h on r.host = h.name
         left join nvts n on r.nvt = n.oid
         left join tasks t on r.task = t.id
         left join targets tar on t.target = tar.id
         left join port_lists pl on tar.port_list = pl.id
         left join reports re on r.report = re.id
         left join scanners s on t.scanner = s.id
         left join (select array_agg(ref_id) as ids, vt_oid from vt_refs where type = 'cve' group by vt_oid) cve
                   on n.oid = cve.vt_oid
         left join (select array_agg(ref_id) as ids, vt_oid from vt_refs where type = 'url' group by vt_oid) url
                   on n.oid = url.vt_oid
where r.id > :sql_last_value
order by r.id
limit 10000
