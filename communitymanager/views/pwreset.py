# =================================================================
# Copyright (C) 2011 Community Information Online Consortium (CIOC)
# http://www.cioc.ca
# Developed By Katherine Lambacher / KCL Custom Software
# If you did not receive a copy of the license agreement with this
# software, please contact CIOC via their website above.
#==================================================================


# 3rd party
from pyramid.httpexceptions import HTTPFound
from pyramid.security import NO_PERMISSION_REQUIRED
from pyramid.view import view_config

from formencode import Schema

#this app
from communitymanager.views.base import ViewBase
from communitymanager.lib import validators, security, email
from communitymanager.lib.request import get_translate_fn

_ = lambda x: x
pwreset_email_template = _(u'''\
Hi %(FirstName)s,

Someone requested a password reset for the CIOC Communities Repository site.
Your new password is:
%(Password)s

Please log in to %(url)s as soon as possible and change your password.
''')
del _

class LoginSchema(Schema):
    allow_extra_fields = True
    filter_extra_fields = True
    
    LoginName = validators.UnicodeString(max=50, not_empty=True)

class PwReset(ViewBase):
    @view_config(route_name="pwreset", request_method="POST", renderer='pwreset.mak', permission=NO_PERMISSION_REQUIRED)
    def post(self):
        request = self.request
        _ = request.translate

        model_state = request.model_state
        model_state.schema = LoginSchema()

        if not model_state.validate():
            return {}

        password = security.MakeRandomPassword()

        salt = security.MakeSalt()
        hash = security.Crypt(salt, password)
        hash_args =  [security.DEFAULT_REPEAT, salt, hash]

        LoginName = model_state.value('LoginName')
        user = None
        with request.connmgr.get_connection() as conn:
            user = conn.execute('EXEC sp_Users_u_PwReset ?, ?, ?, ?', LoginName, *hash_args).fetchone()

        if user:
            gettext = get_translate_fn(request, user.Culture) 

            subject = gettext('CIOC Community Manager Site Password Reset')
            welcome_message = gettext(pwreset_email_template) % {
                                    'FirstName': user.FirstName, 
                                    'Password': password,
                                    'url': request.route_url('login')}

            email.email('admin@cioc.ca', user.Email, subject, welcome_message)


        request.session.flash(_('A new password was sent you your email address.'))
        return HTTPFound(location=request.route_url('home'))

    @view_config(route_name="pwreset", renderer="pwreset.mak", permission=NO_PERMISSION_REQUIRED)
    def get(self):

        return {}

