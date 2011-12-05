# =================================================================
# Copyright (C) 2011 Community Information Online Consortium (CIOC)
# http://www.cioc.ca
# Developed By Katherine Lambacher / KCL Custom Software
# If you did not receive a copy of the license agreement with this
# software, please contact CIOC via their website above.
#==================================================================


# 3rd party
from pyramid.httpexceptions import HTTPFound
from pyramid.security import remember, forget, NO_PERMISSION_REQUIRED
from pyramid.view import view_config

from formencode import Schema
from beaker.crypto.pbkdf2 import PBKDF2


#this app
from communitymanager.views.base import ViewBase
from communitymanager.lib import validators
from communitymanager.lib.syslanguage import _culture_list, default_culture


class LoginSchema(Schema):
    allow_extra_fields = True
    filter_extra_fields = True
    
    LoginName = validators.UnicodeString(max=50, not_empty=True)
    LoginPwd = validators.String(not_empty=True)

    came_from = validators.UnicodeString()

class Login(ViewBase):
    @view_config(route_name="login", request_method="POST", renderer='login.mak', permission=NO_PERMISSION_REQUIRED)
    def post(self):
        request = self.request
        _ = request.translate

        model_state = request.model_state
        model_state.schema = LoginSchema()

        if not model_state.validate():
            return {}

        LoginName = model_state.value('LoginName')
        user = None
        with request.connmgr.get_connection() as conn:
            user = conn.execute('EXEC sp_User_LoginCheck ?', LoginName).fetchone()

        if not user:
            model_state.add_error_for('*', _('Invalid User Name or Password'))
            return {}


        hash = Crypt(user.PasswordHashSalt, model_state.value('LoginPwd'), user.PasswordHashRepeat)
        if hash != user.PasswordHash:
            model_state.add_error_for('*', _('Invalid User Name or Password'))
            return {}

        headers = remember(request, user.UserName)
        start_ln = [x.Culture for x in _culture_list if x.LangID==user.StartLanguage and x.Active]
        if not start_ln:
            start_ln = [default_culture()]

        return HTTPFound(location=model_state.value('came_from', request.route_url('browse', ln=start_ln[0])), 
                         headers=headers)

    @view_config(route_name="login", renderer="login.mak", permission=NO_PERMISSION_REQUIRED)
    @view_config(context='pyramid.httpexceptions.HTTPForbidden', renderer="login.mak", permission=NO_PERMISSION_REQUIRED)
    def get(self):
        request = self.request
        login_url = request.route_url('login')
        referrer = request.url
        if referrer == login_url:
            referrer = request.route_url('browse') # never use the login form itself as came_from
        came_from = request.params.get('came_from', referrer)

        request.model_state.data['came_from'] = came_from

        return {}



#@view_config(route_name="logout", permission=NO_PERMISSION_REQUIRED)
def logout(request):
    headers = forget(request)
    return HTTPFound(location = request.route_url('login'),
                     headers = headers)

def Crypt(salt, password, repeat):
	pbkdf2 = PBKDF2(password, salt, int(repeat))
	return pbkdf2.read(33).encode('base64').strip()
