# =================================================================
# Copyright (C) 2011 Community Information Online Consortium (CIOC)
# http://www.cioc.ca
# Developed By Katherine Lambacher / KCL Custom Software
# If you did not receive a copy of the license agreement with this
# software, please contact CIOC via their website above.
#==================================================================

# std lib
from itertools import groupby
from operator import attrgetter

# 3rd party
from pyramid.view import view_config

# this app
from communitymanager.views.base import ViewBase


class Login(ViewBase):
    @view_config(route_name="communities", renderer='communities.mak', permission='view')
    def index(self):
        request = self.request
        manage_list = request.user.ManageAreaList
        if manage_list:
            manage_list = ','.join(manage_list)

        start_communities = []
        with request.connmgr.get_connection() as conn:
            start_communities = conn.execute('EXEC sp_Community_l_Browse ?', manage_list).fetchall()

        start_communities = {k:list(g) for k,g in groupby(start_communities, attrgetter('ParentCommunity'))}
        #raise Exception


        return {'start_communities': start_communities}

    @view_config(route_name="json_communities", renderer='json', permission='view')
    def json_communities(self):
        return {}

    @view_config(route_name="json_community", renderer='json', permission='view')
    def json_community(self):
        return {}
