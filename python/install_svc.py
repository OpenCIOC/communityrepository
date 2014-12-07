import os
import sys

if len(sys.argv) < 2:
    print "Missing port number"
    sys.exit(1)

envname = 'ciocenv31'
if len(sys.argv) == 3:
    envname = sys.argv[2]

this_dir_name = os.path.dirname(__file__)
os.chdir(this_dir_name)

app_path = os.path.abspath(os.path.join(this_dir_name, '..'))
app_name = os.path.split(app_path)[1]

virtualenv = os.path.abspath(os.path.join(os.environ.get('CIOC_ENV_ROOT', os.path.join(app_path, '..', '..')), envname))

args = dict(virtualenv=virtualenv, app_name=app_name, http_port=sys.argv[1])
cmd = r'%(virtualenv)s\Scripts\python.exe wsgisvc.py -n PyCioc%(app_name)s -d "CIOC %(app_name)s" -v %(virtualenv)s -c production.ini -p %(http_port)s install' % args
print cmd
result = os.system(cmd)
if not result:
    result = os.system('sc config PyCioc%s start= auto' % app_name)

sys.exit(result)
