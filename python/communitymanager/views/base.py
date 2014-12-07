# =================================================================
# Copyright (C) 2011 Community Information Online Consortium (CIOC)
# http://www.cioc.ca
# Developed By Katherine Lambacher / KCL Custom Software
# If you did not receive a copy of the license agreement with this
# software, please contact CIOC via their website above.
#==================================================================

# std lib
from xml.etree import cElementTree as ET

# 3rd party

# this app
from communitymanager.lib import modelstate

def xml_to_dict_list(text):
    if not text:
        return []

    root = ET.fromstring('<root>' + text.encode('utf8') + '</root>')

    return [el.attrib for el in root]


class ViewBase(object):
    __skip_register_check__ = False

    def __init__(self, request):
        self.request = request

        request.model_state = modelstate.ModelState(request)

