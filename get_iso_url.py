from jenkinsapi.jenkins import Jenkins
import re
import os

# Define Jenkins url and job name

jenkins_url = os.environ.get('JENKINS_URL')
jenkins_job = os.environ.get('JOB_NAME')

def get_iso_url(url, jobName, username=None, password=None):
    J = Jenkins(url, username, password)
    job = J[jobName]
    lgb = job.get_last_good_build()
    return lgb


print re.findall(r'(http[s]?://\S+)', get_iso_url(jenkins_url,jenkins_job).__dict__['_data']['description'])[0].replace(">ISO","")
