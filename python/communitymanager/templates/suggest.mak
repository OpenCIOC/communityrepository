<%inherit file="master.mak"/>
<%block name="title">${_('Community Change Suggestion')}</%block>


${renderer.error_notice()}
<form method="post" action="${request.current_route_path(_form=True)}">
<div class="hidden">
${renderer.form_passvars()}
%if extra_hidden_params:
%endif
</div>
${renderer.required_field_instructions()}
<table class="form-table">
<tr>
    <td class="ui-widget-header field">${renderer.label('Suggestion', _('Community Change Suggestion'))} ${renderer.required_flag()}</td>
</tr>
<tr>
    <td class="ui-widget-content">
    ${renderer.errorlist('Suggestion')}
    ${renderer.textarea('Suggestion')}
    </td>
</tr>
</table>
<input type="submit" value="${_('Submit')}">
</form>

