
# =================================================================
# Copyright (C) 2011 Community Information Online Consortium (CIOC)
# http://www.cioc.ca
# Developed By Katherine Lambacher / KCL Custom Software
# If you did not receive a copy of the license agreement with this
# software, please contact CIOC via their website above.
#==================================================================

# std lib

# 3rd party
from pyramid.httpexceptions import HTTPFound
from pyramid.view import view_config

# this app
from communitymanager.lib import validators
from communitymanager.views.base import ViewBase, xml_to_dict_list


import logging
log = logging.getLogger('communitymanager.views.community')



class Users(ViewBase):
    @view_config(route_name="users", renderer='users.mak', permission='view')
    def index(self):
        request = self.request


        with request.connmgr.get_connection() as conn:
            # XXX also list of account requests
            users = conn.execute('EXEC sp_Users_l').fetchall()

            user_requests = conn.execute('EXEC sp_Users_AccountRequest_l ?', not not request.params.get('show_rejected')).fetchall()


        for user in users:
            user.ManageCommunities = [x['Name'] for x in xml_to_dict_list(user.ManageCommunities)]


        return {'users': users, 'user_requests': user_requests}



    @view_config(route_name="user_new", renderer='user.mak', permission='view')
    def new(self):
        request = self.request
        _ = request.translate

        validator = validators.IntID(not_empty=True)
        try:
            reqid = validator.to_python(request.params.get('reqid'))
        except validators.Invalid, e:
            request.session.flash(_('Invalid Account Request ID: ') + e.message, 'errorqueue')
            return HTTPFound(location=request.route_path('users'))

        with request.connmgr.get_connection() as conn:
            account_request = conn.execute('EXEC sp_Users_AccountRequest_s ?', reqid).fetchone()

        if not account_request:
            request.session.flash(_('Account Request Not Found'), 'errorqueue')
            return HTTPFound(location=request.route_path('users'))

        data = request.model_state.data
        data['user'] = account_request
        if account_request.CanUseRequestedName:
            data['user.UserName'] = account_request.PreferredUserName
        elif account_request.CanUseLastPlusInital:
            data['user.UserName'] = account_request.LastName.lower() + account_request.FirstName[0].lower()
        elif account_request.CanUseDottedJoin:
            data['user.UserName'] = '.'.join((account_request.FirstName, account_request.LastName))

        return {'title_text': _('Add New User'), 'account_request': account_request, 'cm_name_map': {} }
