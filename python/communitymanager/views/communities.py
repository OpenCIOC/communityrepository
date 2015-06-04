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

        communities = []

        external_system_code = request.params.get('ExternalSystem')
        with request.connmgr.get_connection() as conn:
            sql = 'EXEC sp_Community_l ?, ? ; EXEC sp_External_System_l'
            cursor = conn.execute(sql, (request.user and request.user.User_ID), external_system_code)

            communities = cursor.fetchall()

            cursor.nextset()

            external_systems = map(tuple, cursor.fetchall())

            cursor.close()

        communities = {k: list(g) for k, g in groupby(communities, attrgetter('ParentCommunity'))}

        request.model_state.form.data['ExternalSystem'] = external_system_code

        return {'communities': communities, 'external_systems': external_systems}

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
                communities = conn.execute('EXEC sp_Community_ls ?,?', (request.user and request.user.User_ID), model_state.value('terms'))

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

        _ = request.translate
        if not community:
            return {'fail': True, 'reason': _('Community Not Found.')}

        pcn = xml_to_dict_list(community.ParentCommunityName)
        if pcn:
            pcn = pcn[0]
        community.ParentCommunityName = pcn

        community.OtherNames = xml_to_dict_list(community.OtherNames)
        community.ChildCommunities = xml_to_dict_list(community.ChildCommunities)
        community.SearchCommunities = xml_to_dict_list(community.SearchCommunities)
        community.Managers = xml_to_dict_list(community.Managers)

        community_info = render('community_more_details.mak', {'community': community}, request)
        if community.ParentCommunityName:
            cm_title = _('%s (in %s)') % (community.Name, community.ParentCommunityName['Name'])
        else:
            cm_title = community.Name

        return {'fail': False, 'community_info': community_info, 'community_name': cm_title}
