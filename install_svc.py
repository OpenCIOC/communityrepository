import os, sys

if len(sys.argv) != 2:
	print "Missing port number"
	sys.exit(0)

app_path = os.path.abspath(os.path.dirname(__file__))
app_name = os.path.split(app_path)[1]

service_start_path = app_path

virtualenv = os.path.abspath(r'..\..\ciocenv')

args = dict(virtualenv=virtualenv, app_name=app_name, http_port=sys.argv[1])
cmd = r'%(virtualenv)s\Scripts\python.exe wsgisvc.py -n PyCioc%(app_name)s -d "CIOC %(app_name)s" -v %(virtualenv)s -c production.ini -p %(http_port)s install' % args
print cmd
os.system(cmd)
