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
<%! 
import json

from markupsafe import Markup 
%>

<% 
is_add = not (external_community and external_community.EXT_ID)
%>

<%block name="title">
<% is_add = not (external_community and external_community.EXT_ID) %>
    ${_('Add External Community') if is_add else _('Edit External Community')}
</%block>


${renderer.error_notice()}
<form method="post" action="${request.current_route_path(_form=True)}" id="EntryForm">
<div class="hidden">
${renderer.form_passvars()}
</div>
${renderer.required_field_instructions()}
<table class="form-table">
<tr>
	<td class="ui-widget-header field">${renderer.label('external_community.AreaName', _('Area Name'))} ${renderer.required_flag()}</th>
	<td class="ui-widget-content">
	${renderer.errorlist("external_community.AreaName")}
	${renderer.text("external_community.AreaName", maxlength=200)}
	</td>
</tr>
<tr>
	<td class="ui-widget-header field">${renderer.label('external_community.PrimaryAreaType', _('Primary Area Type'))}</th>
	<td class="ui-widget-content">
		${renderer.errorlist('external_community.PrimaryAreaType')}
        ${renderer.select('external_community.PrimaryAreaType', [('','')] + area_types)}
	</td>
</tr>
<tr>
	<td class="ui-widget-header field">${renderer.label('external_community.SubAreaType', _('Sub Area Type'))}</th>
	<td class="ui-widget-content">
		${renderer.errorlist('external_community.SubAreaType')}
        ${renderer.select('external_community.SubAreaType', [('','')] + area_types)}
	</td>
</tr>
<tr>
	<td class="ui-widget-header field">${renderer.label('external_community.ProvinceState', _('Province, State and/or Country'))} ${renderer.required_flag()}</th>
	<td class="ui-widget-content">
		${renderer.errorlist('external_community.ProvinceState')}
        ${renderer.select('external_community.ProvinceState', ([('','')] if is_add else []) + prov_state)}
	</td>
</tr>
<tr>
	<td class="ui-widget-header field">${renderer.label('external_community.ExternalID', _('External ID'))}</th>
	<td class="ui-widget-content">
	${renderer.errorlist("external_community.ExternalID")}
	${renderer.text("external_community.ExternalID", maxlength=50)}
	</td>
</tr>
<tr>
	<td class="ui-widget-header field">${renderer.label('external_community_CM_IDWeb', _('Community Mapping'))} ${renderer.required_flag()}</th>
	<td class="ui-widget-content">
		${renderer.errorlist('external_community.CM_ID')}
        ${renderer.hidden('external_community.CM_ID', id='external_community_CM_ID')}
        ${renderer.text('external_community.CM_IDName', id='external_community_CM_IDWeb')}
	</td>
</tr>
<tr>
	<td colspan="2">
	<input type="submit" name="Submit" value="${_('Add') if is_add else _('Update')}"> 
	%if not is_add:
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
<script type="text/javascript" src="${request.static_path('communitymanager:static/js/community.min.js')}"></script>
<script type="text/javascript">
(function($) {
    var community_link = ${json.dumps(request.route_path('json_parents'))|n};
    $(function() {
        init_cached_state();

        init_municipality_autocomplete($('#external_community_CM_IDWeb'), community_link, '${_("An unknown community was entered")}');

        restore_cached_state();
    });
})(jQuery);
</script>
</%block>