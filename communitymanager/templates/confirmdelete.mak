<%inherit file="master.mak"/>
<%! 
import json

from markupsafe import Markup 
from communitymanager.lib import syslanguage
%>


<%block name="title">${title_text}</%block>


${renderer.error_notice()}
<p>${prompt}
<br>${_('Use your back button to return to the form if you do not want to continue.')}
<form method="post" action="${request.current_route_path(_form=True)}">
<div class="hidden">
${renderer.form_passvars()}
%if extra_hidden_params:
%for name, value in extra_hidden_params:
    <input type="hidden" name="${name}" value="${value}">
%endfor
%endif
</div>
%if use_reason_for_change:
${renderer.required_field_instructions()}
<table class="form-table">
<tr>
    <td class="ui-widget-header field">${renderer.label('ReasonForChange', _('Reason for Delete'))} ${renderer.required_flag()}</td>
    <td class="ui-widget-content">
    ${renderer.errorlist('ReasonForChange')}
    ${renderer.textarea('ReasonForChange')}
    </td>
</tr>
</table>
%endif
<input type="submit" value="${continue_prompt}">
</form>

