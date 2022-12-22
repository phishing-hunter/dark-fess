#!/bin/bash
JOB_ID=$(curl -H "Authorization: ${TOKEN}" -XPUT "http://fess:8080/api/admin/webconfig/setting" -d \
'{
   "name":"'${1}'",
   "description":"add url script",
   "urls":"'${1}'",
   "included_urls":"*",
   "user_agent":"Mozilla/5.0 (Windows NT 10.0; rv:91.0) Gecko/20100101 Firefox/91.0",
   "num_of_thread":1,
   "interval_time":10000,
   "boost":1.0,
   "available":true,
   "sort_order":0,
   "permissions": "{role}guest",
   "config_parameter": "client.proxyHost=proxy
client.proxyPort=8118"
}'|jq -r ".response.id")

TASK_ID=$(curl -H "Authorization: ${TOKEN}" -XPUT "http://fess:8080/api/admin/scheduler/setting" -d \
'{
  "running": false,
  "id": "'${1}'",
  "version_no": -1,
  "name": "Web Crawler - '${1}'",
  "target": "all",
  "script_type": "groovy",
  "script_data":"return container.getComponent(\"crawlJob\").logLevel(\"info\").sessionId(\"'${JOB_ID}'\").webConfigIds([\"'${JOB_ID}'\"] as String[]).fileConfigIds([] as String[]).dataConfigIds([] as String[]).jobExecutor(executor).execute();",
  "crawler": "true",
  "job_logging": "true",
  "available": "true",
  "sort_order": 0
}'|jq -r ".response.id")
echo $TASK_ID
sleep 15
curl -H "Authorization: ${TOKEN}" -XPOST "http://fess:8080/api/admin/scheduler/${TASK_ID}/start"
