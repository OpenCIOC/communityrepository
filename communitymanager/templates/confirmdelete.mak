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
<input type="submit" value="${continue_prompt}">
</form>

