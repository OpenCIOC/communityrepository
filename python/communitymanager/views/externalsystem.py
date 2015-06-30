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
from xml.sax.saxutils import quoteattr
from datetime import datetime
import tempfile
import zipfile

# 3rd party
from pyramid.httpexceptions import HTTPNotFound, HTTPFound
from pyramid.view import view_config, view_defaults
from pyramid.security import Allow, DENY_ALL, Everyone
from pyramid.response import FileIter
from markupsafe import Markup

# this app
from communitymanager.lib import validators, bufferedzip
from communitymanager.views.base import ViewBase


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
            (Allow, Everyone, 'view'),
            (Allow, 'area:admin', ('edit', 'view')),
            (Allow, 'area-external:' + self.external_system.SystemCode, ('edit', 'view')),
            DENY_ALL
        ]


class ExternalCommunityRoot(ExternalSystemRoot):
    def __init__(self, request):
        super(ExternalCommunityRoot, self).__init__(request)

        validator = validators.IntID(not_empty=True)
        try:
            self.EXTID = validator.to_python(request.matchdict.get('EXTID'))
        except validators.Invalid:
            raise HTTPNotFound


class ExternalCommunityBaseSchema(validators.Schema):

    AreaName = validators.UnicodeString(max=200, not_empty=True)
    PrimaryAreaType = validators.String(max=30)
    SubAreaType = validators.String(max=30)
    ProvinceState = validators.IntID()
    ExternalID = validators.String(max=50)
    AIRSExportType = validators.String(max=20)

    Parent_ID = validators.IntID()
    Parent_IDName = validators.UnicodeString()

    CM_ID = validators.IntID()
    CM_IDName = validators.UnicodeString()


class ExternalCommunitySchema(validators.Schema):
    allow_extra_fields = True
    filter_extra_fields = True

    external_community = ExternalCommunityBaseSchema()


@view_defaults(route_name="external_community")
class ExternalCommunties(ViewBase):

    @view_config(route_name="external_systems", renderer='externalsystems.mak', permission='view')
    def system_list(self):
        request = self.request

        with request.connmgr.get_connection() as conn:
            external_systems = conn.execute('EXEC sp_External_System_l').fetchall()

        return {'external_systems': external_systems}

    @view_config(route_name="external_community_list", renderer='externalcommunities.mak', permission='view')
    def list(self):
        request = self.request
        external_system = request.context.external_system

        with request.connmgr.get_connection() as conn:
            external_communities = conn.execute('EXEC sp_External_Community_l ?', external_system.SystemCode).fetchall()

        can_edit = False

        user = request.user
        ManageExternalSystemList = (user and user.ManageExternalSystemList) or []

        if (user and user.Admin) or external_system.SystemCode in ManageExternalSystemList:
            can_edit = True

        return {'external_communities': external_communities, 'external_system': external_system, 'can_edit': can_edit}

    @view_config(route_name='external_community_add', request_method='POST', renderer='externalcommunity.mak', permission='edit')
    @view_config(match_param='action=edit', request_method='POST', renderer='externalcommunity.mak', permission='edit')
    def save(self):
        request = self.request
        external_system = request.context.external_system

        model_state = request.model_state
        model_state.form.variable_decode = True
        model_state.schema = ExternalCommunitySchema()

        EXTID = None
        is_add = request.matched_route.name == 'external_community_add'

        if not is_add:
            EXTID = request.context.EXTID

        if not is_add and request.params.get('Delete'):
            return HTTPFound(location=request.current_route_url(action='delete'))

        if model_state.validate():
            cm_data = model_state.value('external_community', {})
            args = [EXTID, external_system.SystemCode]
            fields = ['AreaName', 'PrimaryAreaType', 'SubAreaType', 'ProvinceState', 'ExternalID', 'AIRSExportType', 'Parent_ID', 'CM_ID']
            args += [cm_data.get(x) for x in fields]

            sql = '''
            DECLARE @RC int, @EXT_ID int, @ErrMsg nvarchar(500)

            SET @EXT_ID = ?

            EXEC @RC = sp_External_Community_u ?, @EXT_ID OUTPUT, %s, @ErrMsg OUTPUT

            SELECT @RC AS [Return], @EXT_ID AS EXT_ID, @ErrMsg AS ErrMsg
            ''' % ','.join('?' * len(fields))

            with request.connmgr.get_connection() as conn:
                result = conn.execute(sql, args).fetchone()

            if not result.Return:
                _ = request.translate
                msg = _('External Community Saved.')

                request.session.flash(msg)
                EXTID = result.EXT_ID
                location = request.route_url(
                    'external_community', action='edit', SystemCode=external_system.SystemCode, EXTID=EXTID)
                return HTTPFound(location=location)

            model_state.add_error_for('*', result.ErrMsg)

        return self._get_edit_info()

    @view_config(route_name='external_community_add', renderer='externalcommunity.mak', permission='edit')
    @view_config(match_param='action=edit', renderer='externalcommunity.mak', permission='edit')
    def edit(self):
        edit_info = self._get_edit_info()

        if not edit_info['is_add']:
            data = self.request.model_state.form.data
            data['external_community'] = edit_info['external_community']

        return edit_info

    def _get_edit_info(self):
        request = self.request
        external_system = request.context.external_system

        is_add = request.matched_route.name == 'external_community_add'

        EXTID = None

        external_community = None
        area_types = []
        prov_state = []
        with request.connmgr.get_connection() as conn:
            if not is_add:
                EXTID = request.context.EXTID

                cursor = conn.execute('EXEC sp_External_Community_s ?, ?', external_system.SystemCode, EXTID)

                external_community = cursor.fetchone()

                if not external_community:
                    cursor.close()
                    raise HTTPNotFound

                cursor.close()

            cursor = conn.execute('EXEC sp_External_Community_s_FormLists')

            area_types = cursor.fetchall()

            cursor.nextset()

            prov_state = cursor.fetchall()

            cursor.nextset()

            airs_export_types = cursor.fetchall()

            cursor.close()

        return {
            'external_community': external_community,
            'area_types': map(tuple, area_types),
            'prov_state': map(tuple, prov_state),
            'airs_export_types': [x[0] for x in airs_export_types],
            'is_add': is_add
        }

    @view_config(match_param='action=delete', request_method='POST', renderer='confirmdelete.mak', permission='edit')
    def confirm_delete(self):
        request = self.request
        context = request.context
        _ = request.translate

        EXTID = context.EXTID
        SystemCode = context.external_system.SystemCode

        sql = '''
        DECLARE @ErrMsg nvarchar(500), @RC int

        EXEC @RC = dbo.sp_External_Community_d ?, ?, @ErrMsg OUTPUT

        SELECT @RC AS [Return], @ErrMsg AS ErrMsg
        '''

        with request.connmgr.get_connection() as conn:
            result = conn.execute(sql, SystemCode, EXTID).fetchone()

        if not result.Return:
            request.session.flash(_('The External Community was successfully deleted'))
            return HTTPFound(location=request.route_url('external_community_list', SystemCode=SystemCode))

        request.session.flash(_('Unable to delete External Community: ') + result.ErrMsg, 'errorqueue')

        if result.Return == 3:
            # External Community does not exist
            return HTTPFound(location=request.route_url('external_community_list', SystemCode=SystemCode))

        return HTTPFound(location=request.current_route_url(action='edit'))

    @view_config(match_param='action=delete', renderer='confirmdelete.mak', permission='edit')
    def delete(self):
        request = self.request
        context = request.context
        _ = request.translate

        EXTID = context.EXTID
        SystemCode = context.external_system.SystemCode

        with request.connmgr.get_connection() as conn:
            external_community = conn.execute('EXEC sp_External_Community_s ?, ?', SystemCode, EXTID).fetchone()

        if not external_community:
            raise HTTPNotFound()

        title = _('Delete External Community')
        prompt = _('Are you sure you want to delete the external community: <em>%s</em>?')

        return {'title_text': title,
                'prompt': Markup(prompt) % external_community.AreaName,
                'continue_prompt': _('Delete'), 'use_reason_for_change': False}

    @view_config(route_name='json_external_community_parents', renderer='json', permission='edit')
    def autocomplete_parents(self):
        request = self.request
        _ = request.translate

        term_validator = validators.UnicodeString(not_empty=True)
        try:
            terms = term_validator.to_python(request.params.get('term'))
        except validators.Invalid:
            return []

        SystemCode = request.context.external_system.SystemCode

        retval = []
        with request.connmgr.get_connection() as conn:
            ext_id_validator = validators.IntID()
            try:
                ext_id = ext_id_validator.to_python(request.params.get('extid'))
            except validators.Invalid:
                ext_id = None

            cursor = conn.execute('EXEC sp_External_Community_ls_ParentSelector ?, ?, ?', SystemCode, ext_id, terms)

            cols = ['chkid', 'value', 'label']

            in_tmpl = _(' (in %s)')
            values = (x[:2] + (x[2] + ((in_tmpl % x[3]) if x[3] else ''),) for x in cursor.fetchall())
            retval = [dict(zip(cols, x)) for x in values]

            cursor.close()

        return retval

    @view_config(route_name='json_communities', renderer='json', permission='view')
    def autocomplete_communities(self):
        request = self.request
        _ = request.translate

        term_validator = validators.UnicodeString(not_empty=True)
        try:
            terms = term_validator.to_python(request.params.get('term'))
        except validators.Invalid:
            return []

        retval = []
        with request.connmgr.get_connection() as conn:
            cursor = conn.execute('EXEC sp_Community_ls_Autocomplete ?', terms)

            cols = ['chkid', 'value', 'label']

            in_tmpl = _(' (in %s)')
            values = (x[:2] + (x[2] + ((in_tmpl % x[3]) if x[3] else ''),) for x in cursor.fetchall())
            retval = [dict(zip(cols, x)) for x in values]

            cursor.close()

        return retval

    @view_config(route_name='external_community_download', permission='view')
    def download(self):
        request = self.request
        external_system = request.context.external_system

        names = ['SystemCode', 'SystemName', 'CopyrightHolder1', 'CopyrightHolder2', 'ContactEmail']
        root_parameters = [getattr(external_system, x) for x in names]

        isodate = datetime.now().replace(microsecond=0).isoformat()
        names.append('date')
        root_parameters.append(isodate)

        isodate = isodate.replace(':', '-')

        values = [quoteattr(unicode(x) if x is not None else u'') for x in root_parameters]
        root_parameters = u' '.join(u'='.join(x) for x in zip(names, values))

        fname = u"CommunityMap-%s-%s.xml" % (external_system.SystemCode, isodate)

        file = tempfile.TemporaryFile()
        with bufferedzip.BufferedZipFile(file, 'w', zipfile.ZIP_DEFLATED) as zf:
            with request.connmgr.get_connection() as conn:
                cursor = conn.execute('EXEC sp_External_Community_l_xml ?', external_system.SystemCode)

                _write_xml_data(root_parameters, cursor, zf, fname)

        length = file.tell()
        file.seek(0)
        res = request.response
        res.content_type = 'application/zip'
        res.charset = None
        res.app_iter = FileIter(file)
        res.content_length = length
        res.headers['Content-Disposition'] = 'attachment;filename=%s.zip' % fname[:-4]
        return res


def _write_xml_data(root_parameters, cursor, zipfile, fname):

    with tempfile.TemporaryFile() as file:
        file.write(u'<?xml version="1.0" encoding="UTF-8"?>\n'.encode('utf-8'))
        file.write((u'<ExternalSystem %s>\n' % root_parameters).encode('utf-8'))

        for nextset, tagname in enumerate([u'ExternalCommunities', u'CommunityMapping']):
            if nextset:
                cursor.nextset()

            file.write((u'<%s>' % tagname).encode('utf-8'))

            while True:
                rows = cursor.fetchmany(2000)
                if not rows:
                    break

                rows = u'\n'.join(x[0] for x in rows) + u'\n'
                file.write(rows.encode('utf-8'))

            file.write((u'</%s>' % tagname).encode('utf-8'))

        file.write(u'</ExternalSystem>\n'.encode('utf-8'))

        file.seek(0)
        zipfile.writebuffer(file, fname)
