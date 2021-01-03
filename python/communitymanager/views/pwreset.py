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

# 3rd party
from pyramid.httpexceptions import HTTPFound
from pyramid.security import NO_PERMISSION_REQUIRED
from pyramid.view import view_config

from formencode import Schema

# this app
from communitymanager.views.base import ViewBase
from communitymanager.lib import validators, security, email
from communitymanager.lib.request import get_translate_fn

_ = lambda x: x
pwreset_email_template = _('''\
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
        hash_args = [security.DEFAULT_REPEAT, salt, hash]

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
                'url': request.route_url('login')
            }

            email.email('admin@cioc.ca', user.Email, subject, welcome_message)

        request.session.flash(_('A new password was sent you your email address.'))
        return HTTPFound(location=request.route_url('home'))

    @view_config(route_name="pwreset", renderer="pwreset.mak", permission=NO_PERMISSION_REQUIRED)
    def get(self):

        return {}
