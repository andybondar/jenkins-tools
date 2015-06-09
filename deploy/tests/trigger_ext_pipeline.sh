#!/bin/bash -x

# Assume that local time is EDT (New York)

start_job_time='19:00'

date
current_timestamp=`date +%s`
start_job_timestamp=`date --date "$start_job_time" +%s`
start_job_timestamp_next_day=`date --date "$start_job_time next day" +%s`

if [  "$current_timestamp" -lt "$start_job_timestamp" ]; then
    delay=$((start_job_timestamp-current_timestamp))
else
    delay=$((start_job_timestamp_next_day-current_timestamp))
fi

echo $delay


#Job, which trigers extended pipeline., also should pass next parameters:
# jenkins user name and password with permitions to run job
# token of job wich should be triggered
# job url in this format - '{jenkins_fqdn}:{port}/job/{job_name}/'

attempts=3
while [[ $attempts -ne 0 ]]; do
    echo "Trying to authorize on remote Jenkins. $attempts left."
	output=`curl -is "http://${jenkins_username}:${jenkins_password}@${extended_pipeline_url}buildWithParameters?token=${extended_pipeline_token}&delay=60sec" | head -n1 |awk '{print $2}'`
    if [ "$output" = "201" ]; then
        echo "Success. Job is triggered."
        break
    fi
    attempts=$((attempts - 1))
    sleep 5
done

if [ "$output" != "201" ]; then
    echo "Failed triggering remote job"
fi
