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
self.languages = [(x.Culture, x.LanguageName) for x in languages]
is_add = not (community and community.CM_ID)
can_delete = True
%>

<%block name="title">
<% is_add = not (community and community.CM_ID) %>
%if is_alt_area:
    ${_('Add Alternate Search Area') if is_add else  _('Edit Alternate Search Area')}
        
%else:
    ${_('Add Community') if is_add else _('Edit Community')}

%endif
</%block>


${renderer.error_notice()}
<form method="post" action="${request.current_route_path(_form=True)}" id="EntryForm">
<div class="hidden">
${renderer.form_passvars()}
%if is_alt_area:
${renderer.hidden('altarea', 'on')}
%endif
</div>
${renderer.required_field_instructions()}
<table class="form-table">
%if community:
%if not is_alt_area:
<tr>
    <td class="ui-widget-header field">${_('Status')}</td>
    <td class="ui-widget-content">
	%if community.ChildCommunities:
		${_('This Community is a Parent for: ')}
        <em>${Markup(", ").join(x['Name'] for x in community.ChildCommunities)}</em>
        <% can_delete = False %>
	%else:
		${_('This Community <strong>is not</strong> being used as a Parent Community.')|n}
	%endif

    %if community.AltSearchArea:
        <br>${_('This Community is part of the following Alternate Search Areas: ')}
        <em>${Markup(', ').join(x['Name'] for x in community.AltSearchArea)}</em>
        <% can_delete = False %>
    %else:
        <br>${_('This Community <strong>is not</strong> part of an Alternate Search Area.')|n}
    %endif

	%if can_delete:
	<br>${_('Because this Community is not being used, you can delete it using the button at the bottom of the form.')}
	%else:
		<br>${_('Because this Community is being used, you cannot currently delete it.')}
	%endif
    </td>
</tr>
%endif
${self.makeMgmtInfo(community)}
<tr>
	<td class="ui-widget-header field">${_('GUID')}</th>
	<td class="ui-widget-content">${community.CM_GUID}</td>
</tr>
%endif
<tr>
	<td class="ui-widget-header field">${_('Name')} ${renderer.required_flag()}</th>
	<td class="ui-widget-content">
	<table class="form-table">
%for culture in active_cultures:
<% lang = culture_map[culture] %>
	<tr>
	<td class="field-label-clear">${renderer.label("descriptions." +lang.FormCulture + ".Name", lang.LanguageName)}</td>
	<td>
	${renderer.errorlist("descriptions." + lang.FormCulture + ".Name")}
	${renderer.text("descriptions." + lang.FormCulture + ".Name", maxlength=200)}
	</td>
	</tr>
%endfor
	</table>
	</td>
</tr>
<tr>
	<td class="ui-widget-header field">${renderer.label('community_ParentCommunityWeb', _('Parent Community'))} ${renderer.required_flag()}</td>
	<td class="ui-widget-content">
		${renderer.errorlist('community.ParentCommunity')}
        ${renderer.hidden('community.ParentCommunity', id='community_ParentCommunity')}
        ${renderer.text('community.ParentCommunityName', id='community_ParentCommunityWeb')}
	</td>
</tr>
<tr>
	<td class="ui-widget-header field">${renderer.label('community.ProvinceState', _('Province, State and/or Country'))} ${renderer.required_flag()}</td>
	<td class="ui-widget-content">
		${renderer.errorlist('community.ProvinceState')}
        ${renderer.select('community.ProvinceState', [('','')] + prov_state)}
	</td>
</tr>
<tr>
	<td class="ui-widget-header field">${_('Alternate Name(s)')}</th>
	<td class="ui-widget-content">
        <table class="form-table${' hidden' if not renderer.form.data.get('alt_names') else ''}" id="alt-name-target">
        <tr><th class="ui-widget-header">${_('Alt Name')}</th><th class="ui-widget-header">${_('Language')}</th><th class="ui-widget-header">${_('Delete')}</th></tr>
        %for i,alt_name in enumerate(renderer.form.data.get('alt_names') or []):
                <% prefix = 'alt_names-%d.' % i %>
                ${make_alt_name(prefix)}
        %endfor
        </table>
        <input type="button" id="add-alternate-name" value="${_('Add')}">
	</td>
</tr>
%if is_alt_area:
<tr>
	<td class="ui-widget-header field"><label for="NEW_cm_checklist">${_('Search Communities')}</label></th>
	<td class="ui-widget-content">
    ${cc.make_cm_checklist_ui('alt_areas', alt_area_name_map)}
	</td>
</tr>
%endif
<tr>
    <td class="ui-widget-header field">${renderer.label('ReasonForChange', _('Reason for Addition') if is_add else _('Reason for Change'))} ${renderer.required_flag()}</td>
    <td class="ui-widget-content">
    ${renderer.errorlist('ReasonForChange')}
    ${renderer.textarea('ReasonForChange')}
    </td>
</tr>
<tr>
	<td colspan="2">
	<input type="submit" name="Submit" value="${_('Add') if is_add else _('Update')}"> 
	%if not is_add and can_delete:
	<input type="submit" name="Delete" value="${_('Delete')}"> 
	%endif
	<input type="reset" value="${_('Reset Form')}"></td>
</tr>
</table>
</table>

<%def name="make_alt_name(prefix)">
<tr>
                <td class="ui-widget-content">
                    ${renderer.errorlist(prefix + 'AltName')}
                    ${renderer.text(prefix + 'AltName')}
                </td>
                <td class="ui-widget-content">
                    ${renderer.errorlist(prefix + 'Culture')}
                    ${renderer.select(prefix + 'Culture', self.languages)}
                </td>
                <td class="ui-widget-content">
                    ${renderer.errorlist(prefix + 'Delete')}
                    ${renderer.checkbox(prefix + 'Delete')}
                </td>
</tr>
</%def>

<%block name="bottomscripts">
<div class='hidden'>
<form id="stateForm" name="stateForm">
<textarea id="cache_form_values"></textarea>
</form>
</div>
<script type="text/html" id="alt-name-template">
${make_alt_name('alt_names-[COUNT].')}
</script>
%if is_alt_area:
${cc.make_cm_checklist_template('alt_areas')}
%endif
<script type="text/javascript" src="${request.static_path('communitymanager:static/js/community.min.js')}"></script>
<script type="text/javascript">
<%
parent_kw = {}
search_area_kw = {}
if community and community.ParentCommunity:
    parent_kw = {'_query': [('parent', community.ParentCommunity)]}

if community:
    search_area_kw = {'_query': [('cmid', community.CM_ID)]}
%>
(function($) {
    var parent_link = ${json.dumps(request.route_path('json_parents', **parent_kw))|n},
        search_area_link = ${json.dumps(request.route_path('json_search_areas', **search_area_kw))|n};
    $(function() {
        init_cached_state();

        init_municipality_autocomplete($('#community_ParentCommunityWeb'), parent_link, '${_("An unknown community was entered")}');

        init_community_edit($);
        init_cm_checklist($, search_area_link, {field: 'cm_checklist', not_found_msg:'${_("Not Found")|n}', match_prop: 'label', parent_cmid_input: $('#community_ParentCommunity')});

        restore_cached_state();
    });
})(jQuery);
</script>
</%block>
