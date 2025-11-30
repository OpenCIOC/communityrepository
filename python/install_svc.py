# =========================================================================================
#  Copyright 2015 Community Information Online Consortium (CIOC) and KCL Software Solutions
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
# =========================================================================================

import os
import sys

if len(sys.argv) < 2:
    print("Missing port number")
    sys.exit(1)

envname = "CommRepoPy38"
if len(sys.argv) == 3:
    envname = sys.argv[2]

this_dir_name = os.path.dirname(__file__)
os.chdir(this_dir_name)

app_path = os.path.abspath(os.path.join(this_dir_name, ".."))
app_name = os.path.split(app_path)[1]

virtualenv = os.path.abspath(
    os.path.join(
        os.environ.get("CIOC_ENV_ROOT", os.path.join(app_path, "..", "..")), envname
    )
)

args = {
    "virtualenv": virtualenv,
    "app_name": app_name,
    "http_port": sys.argv[1],
    "executable": sys.executable,
}
cmd = (
    r'%(executable)s wsgisvc.py -n PyCioc%(app_name)s -d "CIOC %(app_name)s" -v %(virtualenv)s -c production.ini -p %(http_port)s install'
    % args
)
print(cmd)
result = os.system(cmd)
if not result:
    result = os.system("sc config PyCioc%s start= auto" % app_name)

sys.exit(result)
