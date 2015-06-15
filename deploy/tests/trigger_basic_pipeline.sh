#USERNAME=''
#PASS=''
#JENKINS_JOB_URL=''
#TOKEN=''
#ISO_HTTP_LINK=''
#BUILD_NUMBER=''


attempts=3
while [[ $attempts -ne 0 ]]; do
    echo "Trying to authorize on remote Jenkins. $attempts left."
    output=`curl -is "http://${USERNAME}:${PASS}@${JENKINS_JOB_URL}/buildWithParameters?token=${TOKEN}&ISO_URL=${ISO_HTTP_LINK}&BUILD_NUMBER_ISO=${BUILD_NUMBER}" | head -n1 |awk '{print $2}'`
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
