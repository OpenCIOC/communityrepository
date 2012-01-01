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
from pyramid.renderers import render

# this app
from communitymanager.views.base import ViewBase, xml_to_dict_list
from communitymanager.lib import validators


class Communities(ViewBase):
    @view_config(route_name="communities", renderer='communities.mak', permission='view')
    def index(self):
        request = self.request
#        manage_list = request.user.ManageAreaList
#        if manage_list:
#            manage_list = ','.join(manage_list)

        communities = []
        with request.connmgr.get_connection() as conn:
            communities = conn.execute('EXEC sp_Community_l ?', (request.user and request.user.User_ID)).fetchall()

        communities = {k:list(g) for k,g in groupby(communities, attrgetter('ParentCommunity'))}
        #raise Exception


        return {'communities': communities}

    @view_config(route_name="search", renderer='results.mak', permission='view')
    def search(self):
        request = self.request

        model_state = request.model_state
        model_state.validators = {
            'terms': validators.UnicodeString(not_empty=True) 
        }
        model_state.method = None

        communities = []
        if model_state.validate():
            with request.connmgr.get_connection() as conn:
                communities = conn.execute('EXEC sp_Community_ls ?,?', request.user.User_ID, model_state.value('terms'))

        return {'communities': communities}

    @view_config(route_name="json_community", renderer='json', permission='view')
    def json_community(self):
        request = self.request

        validator = validators.IntID(not_empty=True)
        try:
            cm_id = validator.to_python(request.matchdict.get('cmid'))
        except validators.Invalid, e:
            return {'fail': True, 'reason': e.message}

        community = None
        with request.connmgr.get_connection() as conn:
            community = conn.execute('EXEC sp_Community_s_MoreInfo ?', cm_id).fetchone()

        if not community:
            _ = request.translate
            return {'fail': True, 'reason': _('Community Not Found.')}

        pcn = xml_to_dict_list(community.ParentCommunityName)  
        if pcn:
            pcn = pcn[0]
        community.ParentCommunityName = pcn

        community.OtherNames = xml_to_dict_list(community.OtherNames)
        community.ChildCommunities = xml_to_dict_list(community.ChildCommunities)
        community.SearchCommunities = xml_to_dict_list(community.SearchCommunities)
        community.Managers = xml_to_dict_list(community.Managers)

        #community = dict(zip((x[0] for x in community.cursor_description), community))
        
        community_info = render('community_more_details.mak', {'community': community}, request)

        return {'fail': False, 'community_info': community_info, 'community_name': community.Name}
