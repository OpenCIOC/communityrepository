import os
import sys
import win32serviceutil

this_dir_name = os.path.dirname(__file__)
app_path = os.path.abspath(os.path.join(this_dir_name, '..'))
app_name = os.path.split(app_path)[1]

envname = 'ciocenv31'
if len(sys.argv) == 2:
    envname = sys.argv[1]

virtualenv = os.path.abspath(os.path.join(os.environ.get('CIOC_ENV_ROOT', os.path.join(app_path, '..', '..')), envname))

win32serviceutil.SetServiceCustomOption("PyCioc" + app_name, 'wsgi_virtual_env', virtualenv)
