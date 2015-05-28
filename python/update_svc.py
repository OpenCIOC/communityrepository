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
import win32serviceutil

this_dir_name = os.path.dirname(__file__)
app_path = os.path.abspath(os.path.join(this_dir_name, '..'))
app_name = os.path.split(app_path)[1]

envname = 'ciocenv31'
if len(sys.argv) == 2:
    envname = sys.argv[1]

virtualenv = os.path.abspath(os.path.join(os.environ.get('CIOC_ENV_ROOT', os.path.join(app_path, '..', '..')), envname))

win32serviceutil.SetServiceCustomOption("PyCioc" + app_name, 'wsgi_virtual_env', virtualenv)
