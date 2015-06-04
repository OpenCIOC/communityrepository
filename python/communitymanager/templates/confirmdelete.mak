<%doc>
  =========================================================================================
   Copyright 2015 Community Information Online Consortium (CIOC) and KCL Software Solutions
 
   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at
 
       http://www.apache.org/licenses/LICENSE-2.0
 
   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
  =========================================================================================
</%doc>

<%inherit file="master.mak"/>
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

