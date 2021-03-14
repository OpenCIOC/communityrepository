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
from xml.etree import ElementTree as ET

# 3rd party
from formencode.variabledecode import variable_decode
from pyramid.httpexceptions import HTTPFound, HTTPNotFound
from pyramid.view import view_config
from pyramid.security import NO_PERMISSION_REQUIRED, ALL_PERMISSIONS, Allow, Deny, DENY_ALL

# this app
from communitymanager.lib import validators, security, email
from communitymanager.views.base import ViewBase, xml_to_dict_list
from communitymanager.lib.request import get_translate_fn


import logging
log = logging.getLogger('communitymanager.views.users')

# create passthrough _ function to grab the string value
_ = lambda x: x
welcome_email_template = _('''\
Hi %(FirstName)s,

Your account on the CIOC Communities Repository site has been created:
User Name: %(UserName)s
Password: %(Password)s

Please log in to %(url)s as soon as possible and change your password.
''')

request_email_template = _('''\
Hi,

An account has been requested on the CIOC Communities Repository site:
User Name: %(UserName)s
First Name: %(FirstName)s
Last Name: %(LastName)s
Organization: %(Organization)s
Email: %(Email)s
Manage Area Request: %(ManageAreaRequest)s
Manage Area Detail: %(ManageAreaDetail)s

Go to %(url)s to accept or reject the account request.
''')

del _


class BaseUserValidator(validators.Schema):
    allow_extra_fields = True
    filter_extra_fields = True

    UserName = validators.String(max=50, not_empty=True)
    Culture = validators.ActiveCulture(not_empty=True)
    FirstName = validators.String(max=50, not_empty=True)
    LastName = validators.String(max=50, not_empty=True)
    Initials = validators.String(max=6, not_empty=True)
    Organization = validators.String(max=200, not_empty=True)
    Email = validators.Email(not_empty=True)


class NewUserValidator(BaseUserValidator):
    Admin = validators.Bool()


class ManageUsersValidator(NewUserValidator):
    Inactive = validators.Bool()


class PasswordValidator(validators.Schema):
    if_key_missing = None

    CurrentPassword = validators.UnicodeString()

    Password = validators.Pipe(validators.UnicodeString(), validators.SecurePassword())
    ConfirmPassword = validators.UnicodeString()

    chained_validators = [validators.CheckPassword()]


def is_manage_area_detail_required(value_dict, state):
    return value_dict.get('ManageAreaRequest')


class RequestAccessValidator(BaseUserValidator):

    ManageAreaRequest = validators.Bool()
    ManageAreaDetail = validators.UnicodeString()

    chained_validators = [validators.RequireIfPredicate(is_manage_area_detail_required, 'ManageAreaDetail')]

# captcha validator
TomorrowsDateValidator = validators.Pipe(
    validators.DateConverter(month_style='dd/mm/yyyy', not_empty=True),
    validators.TomorrowsDate(not_empty=True))


class ManageUserAddUserWrapper(validators.Schema):
    allow_extra_fields = True
    filter_extra_fields = True

    # need to add user validator when constructing

    manage_areas = validators.ForEach(validators.IntID())
    manage_external = validators.ForEach(validators.String(max=30))


class UpdateProfileRequestAccessBase(validators.Schema):
    allow_extra_fields = True
    filter_extra_fields = True

    # need to add user validator when constructing


class UserRoot(object):
    def __init__(self, request):
        validator = validators.IntID(not_empty=True)
        try:
            uid = validator.to_python(request.matchdict.get('uid'))
        except validators.Invalid:
            raise HTTPNotFound

        with request.connmgr.get_connection() as conn:
            cursor = conn.execute('EXEC sp_Users_s ?', uid)

            self.user = cursor.fetchone()

            cursor.nextset()

            self.manage_areas = cursor.fetchall()

            cursor.nextset()

            self.manage_external = cursor.fetchall()

            cursor.close()

        if self.user is None:
            raise HTTPNotFound

        self.__acl__ = [(Deny, 'uid:%d' % self.user.User_ID, ALL_PERMISSIONS), (Allow, 'area:admin', ('edit', 'view')), DENY_ALL]


class Users(ViewBase):
    @view_config(route_name="users", renderer='users.mak', permission='view')
    def index(self):
        request = self.request

        rejected_requests = None
        with request.connmgr.get_connection() as conn:
            users = conn.execute('EXEC sp_Users_l').fetchall()

            show_rejected = not not request.params.get('show_rejected')

            cursor = conn.execute('EXEC sp_Users_AccountRequest_l ?', show_rejected)

            user_requests = cursor.fetchall()

            if not show_rejected:
                cursor.nextset()
                rejected_requests = cursor.fetchone()

            cursor.close()

        for user in users:
            user.ManageCommunities = [x['Name'] for x in xml_to_dict_list(user.ManageCommunities)]
            user.ManageExternalSystems = [x['Name'] for x in xml_to_dict_list(user.ManageExternalSystems)]

        return {'users': users, 'user_requests': user_requests, 'rejected_requests': rejected_requests}

    @view_config(route_name="user_new", renderer='user.mak', request_method='POST', permission='edit')
    @view_config(route_name="user", renderer='user.mak', request_method='POST', permission='edit')
    @view_config(route_name="request_account", renderer="user.mak", request_method="POST", permission=NO_PERMISSION_REQUIRED)
    @view_config(route_name="account", renderer="user.mak", request_method="POST", permission='view')
    def post(self):
        request = self.request
        _ = request.translate

        is_new = not not request.matched_route.name == 'user_new'
        is_request = not not request.matched_route.name == 'request_account'
        is_account = not not request.matched_route.name == 'account'

        reqid = None

        if is_new:
            reqid = self._get_request_id()
        elif is_account:
            uid = request.user.User_ID
        elif not is_request:
            validator = validators.IntID(not_empty=True)
            try:
                uid = validator.to_python(request.matchdict.get('uid'))
            except validators.Invalid:
                raise HTTPNotFound()

        if is_new and request.params.get('Reject'):
            return HTTPFound(location=request.route_url('request_reject', _query=[('reqid', reqid)]))

        extra_validators = {}
        if is_new:
            extra_validators['user'] = NewUserValidator()
        elif is_account:
            extra_validators['user'] = BaseUserValidator()
            extra_validators['password'] = PasswordValidator(if_missing=None)
        elif not is_request:
            extra_validators['user'] = ManageUsersValidator()
            extra_validators['password'] = PasswordValidator(if_missing=None)
        else:
            extra_validators['user'] = RequestAccessValidator()
            extra_validators['TomorrowsDate'] = TomorrowsDateValidator

        if is_request or is_account:
            schema = UpdateProfileRequestAccessBase(**extra_validators)
        else:
            schema = ManageUserAddUserWrapper(**extra_validators)

        model_state = request.model_state
        model_state.form.variable_decode = True
        model_state.schema = schema

        if model_state.validate():
            form_data = model_state.data
            user = form_data['user']

            fields = list(schema.fields['user'].fields.keys())
            args = [user.get(x) for x in fields]

            if not is_request and not is_account:
                root = ET.Element('ManageAreas')
                if not user.get('Admin'):
                    for cmid in form_data.get('manage_areas') or []:
                        if cmid:
                            ET.SubElement(root, 'CM_ID').text = str(cmid)

                fields.append('ManageAreas')
                args.append(ET.tostring(root))

                root = ET.Element('ManageExternal')
                if not user.get('Admin'):
                    for code in form_data.get('manage_external') or []:
                        if code:
                            ET.SubElement(root, 'SystemCode').text = str(code)

                fields.append('ManageExternalSystems')
                args.append(ET.tostring(root))

                log.debug('args: %s', args)

            if is_new:
                fields.append('Request_ID')
                args.append(reqid)

            if not is_request:
                fields.append('MODIFIED_BY')
                args.append(request.user.UserName)

            password = None
            if not is_request:
                if is_new:
                    password = security.MakeRandomPassword()
                else:
                    password = model_state.value('password.Password')

                if password:
                    salt = security.MakeSalt()
                    hash = security.Crypt(salt, password)
                    hash_args = [security.DEFAULT_REPEAT, salt, hash]
                else:
                    hash_args = [None, None, None]

                fields.extend(['PasswordHashRepeat', 'PasswordHashSalt', 'PasswordHash'])
                args.extend(hash_args)

            user_id_sql = ''
            if is_new:
                user_id_sql = '@User_ID OUTPUT,'
            elif not is_request:
                fields.append('User_ID')
                args.append(uid)

            if is_request:
                sql = '''
                    DECLARE @RT int, @ErrMsg nvarchar(500), @Request_ID int

                    %s
                    EXEC @RT = sp_Users_AccountRequest_i @Request_ID OUTPUT, %s, @ErrMsg=@ErrMsg OUTPUT

                    SELECT @RT AS [Return], @ErrMsg AS ErrMsg, @Request_ID AS Request_ID
                '''
            else:
                sql = '''
                    DECLARE @RT int, @ErrMsg nvarchar(500), @User_ID int
                    SET @ErrMsg = NULL

                    EXEC @RT = sp_Users_u %s %s, @ErrMsg=@ErrMsg OUTPUT

                    SELECT @RT AS [Return], @ErrMsg AS ErrMsg, @User_ID AS [User_ID]

                '''

            sql = sql % (user_id_sql, ','.join('@%s=?' % x for x in fields))

            with request.connmgr.get_connection() as conn:
                result = conn.execute(sql, args).fetchone()

            if not result.Return:

                if is_new:
                    # force to language of request?
                    gettext = get_translate_fn(request, user['Culture'])

                    subject = gettext('Your CIOC Community Manager Site Account')
                    welcome_message = gettext(welcome_email_template) % {
                        'FirstName': user['FirstName'],
                        'UserName': user['UserName'],
                        'Password': password,
                        'url': request.route_url('login')}

                    email.email('admin@cioc.ca', user['Email'], subject, welcome_message)
                    request.session.flash(_('User Successfully Added'))
                    return HTTPFound(location=request.route_url('user', uid=result.User_ID))
                elif is_request:
                    subject = 'CIOC Community Manager Account Request'
                    tmpl_args = {'url': request.route_url('user_new', _query=[('reqid', result.Request_ID)])}
                    tmpl_args.update(user)
                    request_message = request_email_template % tmpl_args
                    email.email('admin@cioc.ca', 'admin@cioc.ca', subject, request_message)

                    return HTTPFound(location=request.route_url('request_account_thanks'))

                if is_account:
                    request.session.flash(_('Account successfully updated'))
                else:
                    request.session.flash(_('User successfully modified'))

                return HTTPFound(location=request.current_route_url())

            model_state.add_error_for('*', _('Could not add user: ') + result.ErrMsg)
            manage_areas = form_data.get('manage_areas') or []

        else:
            data = model_state.data
            decoded = variable_decode(request.POST)
            data['manage_areas'] = manage_areas = decoded.get('manage_areas') or []
            if is_account:
                manage_areas = request.user.ManageAreaList or []
            log.debug('errors: %s', model_state.form.errors)

        account_request = user = None
        cm_name_map = {}
        if not is_request:
            with request.connmgr.get_connection() as conn:
                if is_new:
                    account_request = conn.execute('EXEC sp_Users_AccountRequest_s ?', reqid).fetchone()
                else:
                    if is_account:
                        user = conn.execute('EXEC sp_Users_s ?', uid).fetchone()

                    else:
                        user = request.context.user

                cm_name_map = {str(x[0]): x[1] for x in
                               conn.execute('EXEC sp_Community_ls_Names ?',
                                            ','.join(str(x) for x in manage_areas)).fetchall()}

        if is_new:
            if not account_request:
                request.session.flash(_('Account Request Not Found'), 'errorqueue')
                return HTTPFound(location=request.route_url('users'))
        elif not is_request:
            if not user:
                raise HTTPNotFound()

        if is_new:
            title_text = _('Add New User')
        elif is_request:
            title_text = _('Request Account')
        elif is_account:
            title_text = _('Update Account')
        else:
            title_text = _('Modify User')

        return {'title_text': title_text, 'account_request': account_request,
                'user': user, 'cm_name_map': cm_name_map, 'is_admin': not is_request and not is_account,
                'is_account': is_account}

    @view_config(route_name="user_new", renderer='user.mak', permission='edit')
    @view_config(route_name="user", renderer='user.mak', permission='edit')
    @view_config(route_name="request_account", renderer="user.mak", permission=NO_PERMISSION_REQUIRED)
    @view_config(route_name="account", renderer="user.mak", permission='view')
    def get(self):
        request = self.request
        _ = request.translate

        is_new = not not request.matched_route.name == 'user_new'
        is_request = not not request.matched_route.name == 'request_account'
        is_account = not not request.matched_route.name == 'account'

        if is_new:
            reqid = self._get_request_id()
        elif is_account:
            uid = request.user.User_ID
        elif not is_request:
            validator = validators.IntID(not_empty=True)
            try:
                uid = validator.to_python(request.matchdict.get('uid'))
            except validators.Invalid:
                raise HTTPNotFound()

        account_request = None
        user = None
        cm_name_map = {}
        manage_areas = []
        manage_external = []
        external_systems = []

        if not is_request:
            if is_new:
                with request.connmgr.get_connection() as conn:
                    cursor = conn.execute('EXEC sp_Users_AccountRequest_s ?; EXEC sp_External_System_l', reqid)
                    account_request = cursor.fetchone()

                    cursor.nextset()

                    external_systems = cursor.fetchall()

                    cursor.close()

            else:
                if is_account:
                    with request.connmgr.get_connection() as conn:
                        cursor = conn.execute('EXEC sp_Users_s ?', uid)
                        user = cursor.fetchone()

                        cursor.nextset()
                        cm_tmp = cursor.fetchall()

                        cursor.nextset()
                        ex_tmp = cursor.fetchall()
                        cursor.close()
                else:
                    with request.connmgr.get_connection() as conn:
                        cursor = conn.execute('EXEC sp_External_System_l')

                        external_systems = cursor.fetchall()

                        cursor.close()

                    user = request.context.user
                    cm_tmp = request.context.manage_areas
                    ex_tmp = request.context.manage_external

                manage_areas = [str(x[0]) for x in cm_tmp]
                manage_external = [str(x[0]) for x in ex_tmp]
                cm_name_map = {str(x[0]): x[1] for x in cm_tmp}

        if is_new:
            if not account_request:
                request.session.flash(_('Account Request Not Found'), 'errorqueue')
                return HTTPFound(location=request.route_url('users'))
        elif not is_request:
            if not user:
                return HTTPNotFound()

        data = request.model_state.data
        if is_new:
            data['user'] = account_request
            if account_request.CanUseRequestedName:
                data['user.UserName'] = account_request.PreferredUserName
            elif account_request.CanUseLastPlusInital:
                data['user.UserName'] = account_request.LastName.lower() + account_request.FirstName[0].lower()
            elif account_request.CanUseDottedJoin:
                data['user.UserName'] = '.'.join((account_request.FirstName, account_request.LastName))
        elif not is_request:
            data['user'] = user
            data['manage_areas'] = manage_areas
            data['manage_external'] = manage_external

        if is_new:
            title_text = _('Add New User')
        elif is_account:
            title_text = _('Update Account')
        elif is_request:
            title_text = _('Request Account')
        else:
            title_text = _('Modify User')

        return {'title_text': title_text, 'account_request': account_request,
                'cm_name_map': cm_name_map, 'user': user, 'is_admin': not is_request and not is_account,
                'is_account': is_account, 'external_systems': external_systems}

    @view_config(route_name='request_account_thanks', renderer='request_thanks.mak', permission=NO_PERMISSION_REQUIRED)
    def thanks(self):
        return {}

    @view_config(route_name='request_reject', renderer='confirmdelete.mak', request_method='POST', permission='edit')
    def reject_confirm(self):
        request = self.request

        reqid = self._get_request_id()

        sql = '''
            Declare @ErrMsg as nvarchar(500),
            @RC as int

            EXECUTE @RC = dbo.sp_Users_AccountRequest_Reject ?, ?, @ErrMsg=@ErrMsg OUTPUT

            SELECT @RC as [Return], @ErrMsg AS ErrMsg
        '''
        with request.connmgr.get_connection() as conn:
            result = conn.execute(sql, reqid, request.user.UserName).fetchone()

        _ = request.translate
        if not result.Return:
            request.session.flash(_('The Account Request was successfully rejected'))
            return HTTPFound(location=request.route_url('users'))

        request.session.flash(_('Unable to reject Account Request: ') + result.ErrMsg, 'errorqueue')
        if result.Return == 3:
            # reqid does not exist
            return HTTPFound(location=request.route_url('users'))

        _ = request.translate
        return HTTPFound(location=request.route_url('user_new', _query=[('reqid', reqid)]))

    @view_config(route_name='request_reject', renderer='confirmdelete.mak', permission='edit')
    def reject(self):
        request = self.request
        _ = request.translate

        reqid = self._get_request_id()

        return {'title_text': _('Reject Account Request'),
                'prompt': _('Are you sure you want to reject this account request?'),
                'continue_prompt': _('Reject'),
                'extra_hidden_params': [('reqid', reqid)]}

    def _get_request_id(self):
        request = self.request
        _ = request.translate

        validator = validators.IntID()
        try:
            reqid = validator.to_python(request.params.get('reqid'))
        except validators.Invalid as e:
            request.session.flash(_('Invalid Account Request ID: ') + e.message, 'errorqueue')
            raise HTTPFound(location=request.route_url('users'))

        return reqid

    @view_config(context='pyramid.httpexceptions.HTTPForbidden', route_name="user", renderer='not_authorized_users.mak', permission=NO_PERMISSION_REQUIRED, custom_predicates=[lambda context, request: not not request.user])
    def not_authorized(self):
        return {}
