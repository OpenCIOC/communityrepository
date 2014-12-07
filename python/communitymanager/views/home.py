# =================================================================
# Copyright (C) 2011 Community Information Online Consortium (CIOC)
# http://www.cioc.ca
# Developed By Katherine Lambacher / KCL Custom Software
# If you did not receive a copy of the license agreement with this
# software, please contact CIOC via their website above.
#==================================================================
from pyramid.security import NO_PERMISSION_REQUIRED
from pyramid.view import view_config

from communitymanager.views.base import ViewBase


@view_config(route_name="home", renderer='home.mak', permission=NO_PERMISSION_REQUIRED)
class Home(ViewBase):
    def __call__(self):

        return {}

