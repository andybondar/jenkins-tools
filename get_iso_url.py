from jenkinsapi.jenkins import Jenkins
import re

# Define Jenkins url and job name
jenkins_url = 'http://jenkins-product.srt.mirantis.net:8080'
jenkins_job = 'mox_6.0_iso'


def get_iso_url(url, jobName, username=None, password=None):
    J = Jenkins(url, username, password)
    job = J[jobName]
    lgb = job.get_last_good_build()
    return lgb

#print get_iso_url('http://jenkins-product.srt.mirantis.net:8080','mox_6.0_iso').__dict__['_data']['description']
#print re.findall(r'(http[s]?://\S+)', get_iso_url('http://jenkins-product.srt.mirantis.net:8080','mox_6.0_iso').__dict__['_data']['description'])[0].replace(">ISO","")
print re.findall(r'(http[s]?://\S+)', get_iso_url(jenkins_url,jenkins_job).__dict__['_data']['description'])[0].replace(">ISO","")
