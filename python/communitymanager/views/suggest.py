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

# 3rd party
from pyramid.view import view_config
from pyramid.httpexceptions import HTTPFound


# this app
from communitymanager.lib import validators
from communitymanager.views.base import ViewBase


import logging
log = logging.getLogger('communitymanager.views.suggest')


class SuggestSchema(validators.Schema):
    allow_extra_fields = True
    filter_extra_fields = True

    Suggestion = validators.UnicodeString(not_empty=True)


class Suggest(ViewBase):
    @view_config(route_name="suggest", request_method="POST", renderer='suggest.mak', permission='view')
    def post(self):
        request = self.request

        model_state = request.model_state
        model_state.form.variable_decode = True
        model_state.schema = SuggestSchema()

        if model_state.validate():
            data = model_state.form.data
            args = [request.user.User_ID, data.get('Suggestion')]

            sql = '''
                DECLARE @RC int, @ErrMsg nvarchar(500)

                EXEC @RC = sp_Suggestion_i %s, @ErrMsg OUTPUT

                SELECT @RC AS [Return], @ErrMsg AS ErrMsg

                ''' % (', '.join('?' * (len(args))))

            with request.connmgr.get_connection() as conn:
                result = conn.execute(sql, args).fetchone()

            if not result.Return:
                _ = request.translate
                msg = _('Thank you for your suggestion.')
                request.session.flash(msg)

                return HTTPFound(location=request.route_url('home'))

            model_state.add_error_for('*', result.ErrMsg)

        return {}

    @view_config(route_name="suggest", renderer='suggest.mak', permission='view')
    def get(self):

        return {}

    @view_config(route_name="review_suggestions", renderer='review.mak', permission='edit')
    def review(self):
        request = self.request
        show_completed = not not request.params.get('show_completed')

        completed_suggestions = None
        with request.connmgr.get_connection() as conn:
            cursor = conn.execute('EXEC sp_Suggestion_l ?', show_completed)

            suggestions = cursor.fetchall()

            if not show_completed:
                cursor.nextset()
                completed_suggestions = cursor.fetchone()

            cursor.close()

        return {'suggestions': suggestions, 'completed_suggestions': completed_suggestions}

    @view_config(route_name="complete_suggestion", request_method='POST', renderer='confirmdelete.mak', permission='edit')
    def complete_confirm(self):
        request = self.request

        sjid = self._get_suggestion_id()

        sql = '''
            Declare @ErrMsg as nvarchar(500),
            @RC as int

            EXECUTE @RC = dbo.sp_Suggestion_u_Complete ?, ?, @ErrMsg=@ErrMsg OUTPUT

            SELECT @RC as [Return], @ErrMsg AS ErrMsg
        '''
        with request.connmgr.get_connection() as conn:
            result = conn.execute(sql, sjid, request.user.UserName).fetchone()

        _ = request.translate
        if not result.Return:
            request.session.flash(_('The suggestion was marked completed'))
        else:
            request.session.flash(_('Unable mark suggestion completed: ') + result.ErrMsg, 'errorqueue')

        return HTTPFound(location=request.route_url('review_suggestions'))

    @view_config(route_name="complete_suggestion", renderer='confirmdelete.mak', permission='edit')
    def complete(self):
        request = self.request
        _ = request.translate

        return {
            'title_text': _('Complete Suggestion'),
            'prompt': _('Are you sure you want to mark this suggestion completed?'),
            'continue_prompt': _('Complete'),
            'extra_hidden_params': [('sjid', self._get_suggestion_id())]
        }

    def _get_suggestion_id(self):
        request = self.request
        _ = request.translate

        validator = validators.IntID()
        try:
            sjid = validator.to_python(request.params.get('sjid'))
        except validators.Invalid, e:
            request.session.flash(_('Invalid Suggestion ID: ') + e.message, 'errorqueue')
            raise HTTPFound(location=request.route_url('review_suggestions'))

        return sjid
