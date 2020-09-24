explain analyse verbose
select r.host                                                                               as "ip",
       r.hostname                                                                           as "hostname",
       rhd_mac.value                                                                        as "macs",
       rhd_os_txt.value                                                                     as "os_txt",
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
       concat(t.name, ' - (', to_char(to_timestamp(re.date), 'YYYY-MM-DD HH12:MI AM'), ')') as "scan_name",
       re.id                                                                                as "scan_id",
       to_timestamp(re.date)                                                                as "scan_date"
from results r
         left join report_hosts rh on r.host = rh.host
         left join report_host_details rhd_os_txt on rh.id = rhd_os_txt.report_host and rhd_os_txt.name = 'best_os_txt'
         left join (select report_host, array_agg(value)[0] as "value"
                    from report_host_details
                    where name = 'best_os_txt'
                    group by report_host, id
                    order by id) rhd_smb_auth on rh.id = rhd_smb_auth.report_host
         left join (select report_host, array_agg(value)[0] as "value"
                    from report_host_details
                    where name = 'Auth-SMB-Failure'
                       or name = 'Auth-SMB-Success'
                    group by report_host, id
                    order by id) rhd_smb_auth on rh.id = rhd_smb_auth.report_host
         left join (select report_host, array_agg(value) as "value"
                    from report_host_details
                    where name = 'MAC'
                    group by report_host) rhd_mac on rh.id = rhd_mac.report_host
         left join nvts n on r.nvt = n.oid
         left join tasks t on r.task = t.id
         left join reports re on r.report = re.id
         left join scanners s on t.scanner = s.id
where r.id > :sql_last_value
order by r.id
