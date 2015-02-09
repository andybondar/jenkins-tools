#!/usr/bin/python

# Something like this: 'http://jenkins.domain.name:8080/job/job_name/'
proj_path = 'NONE'

# Something like this: '/artifact/fuel/fuel-5.1/pdf/'
artifacts_path = 'NONE'

# List of artifacts you need to download, for example 'Mirantis-OpenStack-5.1.1-UserGuide.pdf', etc
files = [
	'NONE',
	'NONE'
	];


# And also you'll be asked to enter job build number
while True:
     try:
         i = int(raw_input("Please enter build number: "))
         break
     except ValueError:
         print "Oops!  That was no valid number.  Try again..."


from subprocess import call

for x in files:
    url = proj_path+`i`+artifacts_path+x
    call(["wget", url]),

