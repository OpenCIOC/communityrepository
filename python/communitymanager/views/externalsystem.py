# =================================================================
# Copyright (C) 2011 Community Information Online Consortium (CIOC)
# http://www.cioc.ca
# Developed By Katherine Lambacher / KCL Custom Software
# If you did not receive a copy of the license agreement with this
# software, please contact CIOC via their website above.
# =================================================================
# std lib
# from xml.etree import ElementTree as ET

# 3rd party
# from formencode.variabledecode import variable_decode
from pyramid.httpexceptions import HTTPNotFound  # , HTTPFound
from pyramid.view import view_config
from pyramid.security import Allow, DENY_ALL  # , NO_PERMISSION_REQUIRED, ALL_PERMISSIONS

# this app
from communitymanager.lib import validators  # , security
from communitymanager.views.base import ViewBase  # , xml_to_dict_list
# from communitymanager.lib.request import get_translate_fn


import logging
log = logging.getLogger(__name__)


class ExternalSystemRoot(object):
    def __init__(self, request):
        validator = validators.String(max=30, not_empty=True)
        try:
            system_code = validator.to_python(request.matchdict.get('SystemCode'))
        except validators.Invalid:
            raise HTTPNotFound

        with request.connmgr.get_connection() as conn:
            cursor = conn.execute('EXEC sp_External_System_s ?', system_code)

            self.external_system = cursor.fetchone()

            cursor.close()

        if self.external_system is None:
            raise HTTPNotFound

        self.__acl__ = [
            (Allow, 'area:admin', ('edit', 'view')),
            (Allow, 'area-external:' + self.external_system.SystemCode, ('edit', 'view')),
            DENY_ALL
        ]


class ExternalSystems(ViewBase):

    @view_config(route_name="external_community_list", renderer='externalcommunities.mak', permission='view')
    def list(self):
        request = self.request
        external_system = request.context.external_system

        with request.connmgr.get_connection() as conn:
            external_communities = conn.execute('EXEC sp_External_Community_l ?', external_system.SystemCode).fetchall()

        can_edit = False

        user = request.user
        ManageExternalSystemList = user.ManageExternalSystemList or []

        if user.Admin or external_system.SystemCode in ManageExternalSystemList:
            can_edit = True

        return {'external_communities': external_communities, 'external_system': external_system, 'can_edit': can_edit}
