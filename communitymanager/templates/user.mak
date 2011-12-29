<%inherit file="master.mak"/>
<%namespace file="cm_checklist.mak" name="cc"/>
<%! 
import json

from markupsafe import Markup 
from communitymanager.lib import syslanguage
%>

<% 
active_cultures = syslanguage.active_cultures()
culture_map = syslanguage.culture_map()
languages = sorted((culture_map[x] for x in active_cultures), key=lambda x: x.LanguageName)
languages = [(x.Culture, x.LanguageName) for x in languages]

%>

<%block name="title">${title_text}</%block>

${renderer.error_notice()}
<form method="post" action="${request.current_route_path(_form=True)}">
<div class="hidden">
${renderer.form_passvars()}
%if account_request:
<input type="hidden" name="reqid" value="${account_request.Request_ID}">
%endif
</div>
${renderer.required_field_instructions()}
<table class="form-table">
%if account_request:
<tr>
	<td class="ui-widget-header field">${_('Request Date')}</th>
	<td class="ui-widget-content">${request.format_date(account_request.REQUEST_DATE)}</td>
</tr>
<tr>
	<td class="ui-widget-header field">${_('Request IP')}</th>
	<td class="ui-widget-content">${account_request.IPAddress}</td>
</tr>
%if account_request.REJECTED_DATE:
<tr>
	<td class="ui-widget-header field">${_('Rejected')}</th>
	<td class="ui-widget-content">${request.format_date(account_request.REJECTED_DATE)} ${_('by')} ${account_request.REJECTED_BY}</td>
</tr>
%endif
%endif
%if is_account:
<tr>
    <td class="ui-widget-header field">${_('Manage Areas')}</td>
    <td class="ui-widget-content">
    %if user.Admin:
        ${_('You are an Admin user and can modify any community')}
    %else:
        ${_('You can manage sub-communities of:')}
        ${', '.join(sorted(cm_name_map.values()))}
    %endif
    <td>
</tr>
%endif
%if user:
${self.makeMgmtInfo(user)}
%endif
<tr>
	<td class="ui-widget-header field">${renderer.label("user.UserName", _('User Name'))} ${renderer.required_flag()}</th>
	<td class="ui-widget-content">
	${renderer.errorlist("user.UserName")}
	${renderer.text("user.UserName", maxlength=50)}
	</td>
</tr>
<tr>
	<td class="ui-widget-header field">${renderer.label('user.Culture', _('Start Language'))} ${renderer.required_flag()}</th>
	<td class="ui-widget-content">
        ${renderer.errorlist('user.Culture')}
        ${renderer.select('user.Culture', languages)}
	</td>
</tr>
<tr>
	<td class="ui-widget-header field">${renderer.label('user.FirstName', _('First Name'))} ${renderer.required_flag()}</th>
	<td class="ui-widget-content">
		${renderer.errorlist('user.FirstName')}
        ${renderer.text('user.FirstName', max=50)}
	</td>
</tr>
<tr>
	<td class="ui-widget-header field">${renderer.label('user.LastName', _('Last Name'))} ${renderer.required_flag()}</th>
	<td class="ui-widget-content">
		${renderer.errorlist('user.LastName')}
        ${renderer.text('user.LastName', max=50)}
	</td>
</tr>
<tr>
	<td class="ui-widget-header field">${renderer.label('user.Organization', _('Organization'))} ${renderer.required_flag()}</th>
	<td class="ui-widget-content">
		${renderer.errorlist('user.Organization')}
        ${renderer.text('user.Organization')}
	</td>
</tr>
<tr>
	<td class="ui-widget-header field">${renderer.label('user.Initials', _('Initials'))} ${renderer.required_flag()}</th>
	<td class="ui-widget-content">
		${renderer.errorlist('user.Initials')}
        ${renderer.text('user.Initials', max=6)}
	</td>
</tr>
<tr>
	<td class="ui-widget-header field">${renderer.label('user.Email', _('Email'))} ${renderer.required_flag()}</th>
	<td class="ui-widget-content">
		${renderer.errorlist('user.Email')}
        ${renderer.email('user.Email')}
	</td>
</tr>
%if is_admin:
<tr>
	<td class="ui-widget-header field">${_('Mangage Communities')}</th>
	<td class="ui-widget-content">
        %if account_request:
            %if account_request.ManageAreaRequest:
            <strong>${_('This user has requested area management permissions:')}</strong>
            %else:
            ${_('This user has not requested area management permissions.')}
            %endif
            %if account_request.ManageAreaDetail:
            <br><br>${account_request.ManageAreaDetail}
            %endif
            <br><br>
        %endif
        ${cc.make_cm_checklist_ui('manage_areas', cm_name_map)}
	</td>
</tr>
<tr>
	<td class="ui-widget-header field">${_('Admin User')}</th>
	<td class="ui-widget-content">
		${renderer.errorlist('user.Admin')}
        ${renderer.checkbox('user.Admin', label=' ' + _('This is an admin user'))}
	</td>
</tr>
	<td class="ui-widget-header field">${_('Inactive')}</th>
	<td class="ui-widget-content">
		${renderer.errorlist('user.Inactive')}
        ${renderer.checkbox('user.Inactive', label=' ' + _('This user is inactive'))}
	</td>
<tr>
</tr>
%elif not user:
<tr>
	<td class="ui-widget-header field">${_('Mangage Communities')}</th>
	<td class="ui-widget-content">
        ${self.printInfoMessage(_('By completing this section, you agree that any editorial contributions made are the property of CIOC.'))}
		${renderer.errorlist('user.ManageAreaRequest')}
        ${renderer.checkbox('user.ManageAreaRequest', label=' ' + _('I would like to request editorial privileges for this repository.'))}
        <br><br><strong>${renderer.label('user.ManageAreaDetail', _('Request Details (i.e. specific geographic areas you wish to manage):'))}</strong>
		<br>${renderer.errorlist('user.ManageAreaDetail')}
        ${renderer.textarea('user.ManageAreaDetail')}

    </td>
</tr>
%endif
%if not is_admin and not user:
<tr>
    <td class="ui-widget-header field">${renderer.label('TomorrowsDate', _('Tomorrows Date'))} ${renderer.required_flag()}</td>
    <td class="ui-widget-content">
        <div class="field-help">Please enter tomorrow's date in the format dd/mm/yyyy to help prevent spammers.</div>
        ${renderer.errorlist('TomorrowsDate')}
        ${renderer.text('TomorrowsDate', maxlength=60)}
    </td>
</tr>
%endif
%if is_account:
<tr>
    <td class="ui-widget-header field">${_('Change Password')}</td>
    <td class="ui-widget-content">
        ## XXX do 
        <table class="form-table">
            <tr>
            <td class="field-lable-clear">${renderer.label('password.CurrentPassword', _('Current Password'))}
            <td>${renderer.errorlist('password.CurrentPassword')}
                ${renderer.password('password.CurrentPassword')}
            </td>
            </tr>

            <tr>
            <td class="field-lable-clear">${renderer.label('password.Password', _('New Password'))}
            <td>${renderer.errorlist('password.Password')}
                ${renderer.password('password.Password', autocomplete="off")}
            </td>
            </tr>
            
            <tr>
            <td class="field-lable-clear">${renderer.label('password.ConfirmPassword', _('Confirm New Password'))}
            <td>${renderer.errorlist('password.ConfirmPassword')}
                ${renderer.password('password.ConfirmPassword', autocomplete="off")}
            </td>
            </tr>

        </table>
    </td>
</tr>
%endif
<tr>
	<td colspan="2" class="ui-widget-content">
	<input type="submit" name="Submit" value="${_('Add') if account_request else _('Request Account') if not user else _('Update')}"> 
	%if is_admin and user:
	<input type="submit" name="Delete" value="${_('Delete')}"> 
    %elif account_request:
	<input type="submit" name="Reject" value="${_('Reject')}"> 
	%endif
	<input type="reset" value="${_('Reset Form')}"></td>
</tr>
</table>
</table>

<%block name="bottomscripts">
<div class='hidden'>
<form id="stateForm" name="stateForm">
<textarea id="cache_form_values"></textarea>
</form>
</div>
${cc.make_cm_checklist_template('manage_areas')}
<script type="text/javascript" src="${request.static_path('communitymanager:static/js/community.min.js')}"></script>
<script type="text/javascript">
(function($) {
    var manage_cm_link = ${json.dumps(request.route_path('json_parents'))|n};
    $(function() {
        init_cached_state();

        init_cm_checklist($, manage_cm_link, {field: 'cm_checklist', not_found_msg:'${_("Not Found")|n}', match_prop: 'label'});

        restore_cached_state();
    });
})(jQuery);
</script>
</%block>
