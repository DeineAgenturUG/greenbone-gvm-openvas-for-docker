select r.host                                                         as "ip",
       r.hostname                                                     as "hostname",
       split_part(r.port, '/', 1)                                     as "port",
       split_part(r.port, '/', 2)                                     as "port_protocol",
       r.severity                                                     as "cvss",
       (case
            when r.severity <= 0 then 'Log'
            when r.severity >= 0.1 and r.severity <= 3.9
                then 'Low'
            when severity >= 4.0 and severity <= 6.9
                then 'Medium'
            when severity >= 7.0 and severity <= 10.0
                then 'High' end)                                      as "severity",
       n.solution_type                                                as "solution_type",
       n.name                                                         as "nvt_name",
       r.description                                                  as "summary",
       r.nvt                                                          as "nvt_oid",
       n.cve                                                          as "cves",
       t.uuid                                                         as "task_id",
       t.name                                                         as "task_name",
       to_timestamp(r.date)                                           as "timestamp",
       r.uuid                                                         as "result_uuid",
       r.id                                                           as "result_id",
       n.impact                                                       as "impact",
       n.solution                                                     as "solution",
       n.affected                                                     as "affected",
       n.insight                                                      as "insight",
       n.detection                                                    as "detection_method",
       n.category                                                     as "category",
       n.family                                                       as "family",
       to_timestamp(re.date)                                          as "scan_date",
       string_agg(case when vr.type = 'bid' then vr.ref_id end, ', ') as "bids",
       string_agg(case when vr.type = 'url' then vr.ref_id end, ', ') as "references"
from results r
         left join nvts n on r.nvt = n.oid
         left join vt_refs vr on n.oid = vr.vt_oid
         left join tasks t on r.task = t.id
         left join reports re on r.report = re.id
where r.id > :sql_last_value
group by r.host, r.hostname, r.port, r.severity, n.solution_type, n.name, r.description, r.nvt, n.cve, t.uuid, t.name,
         r.date, r.uuid, r.id, n.impact, n.solution, n.affected, n.insight, n.detection, n.category, n.family, re.date
order by r.id
