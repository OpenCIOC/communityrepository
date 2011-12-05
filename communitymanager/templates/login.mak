<%inherit file="master.mak"/>
<%block name="title">${_('Login')}</%block>
<%block name="sitenav"/>

<% renderer = request.model_state.renderer %>

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
