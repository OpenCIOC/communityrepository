<%inherit file="master.mak"/>
<%block name="title">${_('Login')}</%block>
<%block name="sitenav"/>

<% renderer = request.model_state.renderer %>

%if has_data:
${renderer.error_notice()}
<form action="${request.route_path('login', _form=True)}" method="post">
${renderer.form_passvars()}
<div class="hidden">
${renderer.hidden('came_from')}
</div>
<table class="form-table">
<tr>
	<td class="ui-widget-header">${renderer.label('LoginName', _('Login:'))}</td>
	<td class="ui-widget-content">
		${renderer.errorlist('LoginName')}
		${renderer.text('LoginName')}
	</td>
</tr>
<tr>
	<td class="ui-widget-header">${renderer.label('LoginPwd', _('Password:'))}</td>
	<td class="ui-widget-content">
		${renderer.errorlist('LoginPwd')}
		${renderer.password('LoginPwd', maxlength=None)}
	</td>
</tr>
</table>
<br>
<input type="submit" value="${_('Login')}">
</form>

%else:

${renderer.error_msg(_('This tool does not have any data'))}
%if failed_updates:
    <p>${_('There have been failed updates, please check the <a href="%s">status page</a>.') % request.route_path('status')|n}</p>
%elif has_updated:
    <p>${_('This machine is not configured to recieve data. Please contact your administrator.')|n}</p>
%else:
    <p>${_('This machine has not had a sucecessful first sync. Please <a href="%s">try now </a>.') % request.route_path('pull')|n}</p>
%endif

%endif

