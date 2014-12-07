
<%inherit file="master.mak"/>
<%block name="title">${_('Password Reset')}</%block>
<%block name="sitenav"/>

<% renderer = request.model_state.renderer %>

${renderer.error_notice()}
<form action="${request.current_route_path(_form=True)}" method="post">
${renderer.form_passvars()}
<div class="hidden">
${renderer.hidden('came_from')}
</div>
<table class="form-table">
<tr>
	<td class="ui-widget-header">${renderer.label('LoginName', _('Login: '))}</td>
	<td class="ui-widget-content">
		${renderer.errorlist('LoginName')}
		${renderer.text('LoginName')}
	</td>
</tr>
</table>
<br>
<input type="submit" value="${_('Email New Password')}">
</form>

