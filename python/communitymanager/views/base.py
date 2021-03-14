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


# std lib
from xml.etree import cElementTree as ET

# 3rd party

# this app
from communitymanager.lib import modelstate


def xml_to_dict_list(text):
    if not text:
        return []

    root = ET.fromstring(b'<root>' + text.encode('utf8') + b'</root>')

    return [el.attrib for el in root]


class ViewBase(object):
    __skip_register_check__ = False

    def __init__(self, request):
        self.request = request

        request.model_state = modelstate.ModelState(request)
