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
</div>
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
<tr>
	<td class="ui-widget-header field">${_('User Name')}</th>
	<td class="ui-widget-content">
	${renderer.errorlist("user.UserName")}
	${renderer.text("user.UserName", maxlength=200)}
	</td>
</tr>
<tr>
	<td class="ui-widget-header field">${renderer.label('user.Culture', _('Start Language'))}</th>
	<td class="ui-widget-content">
        ${renderer.errorlist('user.Culture')}
        ${renderer.select('user.Culture', languages)}
	</td>
</tr>
<tr>
	<td class="ui-widget-header field">${renderer.label('user.FirstName', _('First Name'))}</th>
	<td class="ui-widget-content">
		${renderer.errorlist('user.FirstName')}
        ${renderer.text('user.FirstName', max=50)}
	</td>
</tr>
<tr>
	<td class="ui-widget-header field">${renderer.label('user.LastName', _('Last Name'))}</th>
	<td class="ui-widget-content">
		${renderer.errorlist('user.LastName')}
        ${renderer.text('user.LastName', max=50)}
	</td>
</tr>
<tr>
	<td class="ui-widget-header field">${renderer.label('user.Organization', _('Organization'))}</th>
	<td class="ui-widget-content">
		${renderer.errorlist('user.Organization')}
        ${renderer.text('user.Organization')}
	</td>
</tr>
<tr>
	<td class="ui-widget-header field">${renderer.label('user.Initials', _('Initials'))}</th>
	<td class="ui-widget-content">
		${renderer.errorlist('user.Initials')}
        ${renderer.text('user.Initials', max=6)}
	</td>
</tr>
<tr>
	<td class="ui-widget-header field">${renderer.label('user.Email', _('Email'))}</th>
	<td class="ui-widget-content">
		${renderer.errorlist('user.Email')}
        ${renderer.email('user.Email')}
	</td>
</tr>
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
	<td colspan="2">
	<input type="submit" name="Submit" value="${_('Add') if action=='add' else _('Update')}"> 
	%if not is_add and can_delete:
	<input type="submit" name="Delete" value="${_('Delete')}"> 
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
${cc.make_cm_checklist_template('mangage_areas')}
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
