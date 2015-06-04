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
<%block name="title">${_('Community Change Suggestion')}</%block>


${renderer.error_notice()}
<form method="post" action="${request.current_route_path(_form=True)}">
<div class="hidden">
${renderer.form_passvars()}
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

