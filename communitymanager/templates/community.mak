<%inherit file="master.mak"/>
<%! 
import json

from markupsafe import Markup 
from communitymanager.lib import syslanguage
%>


<%block name="title">${_('Edit Alternate Search Area') if is_alt_area else _('Edit Community')}</%block>

<% 
active_cultures = syslanguage.active_cultures()
culture_map = syslanguage.culture_map()
languages = sorted((culture_map[x] for x in active_cultures), key=lambda x: x.LanguageName)
self.languages = [(x.Culture, x.LanguageName) for x in languages]
%>

${renderer.error_notice()}
<form method="post" action="${request.current_route_path(_form=True)}">
<div class="hidden">
${renderer.form_passvars()}
%if is_alt_area:
${renderer.hidden('altarea', 'on')}
%endif
</div>
<table class="form-table">
%if community:
<tr>
    <td class="ui-widget-header field">${_('Status')}</td>
    <td class="ui-widget-content">
	%if community.ChildCommunities:
		${_('The following Communities are using this Community as a parent community:')}
        ${Markup(", ").join(x['Name'] for x in community.ChildCommunities)}
	%else:
		<br>${_('This Community <strong>is not</strong> being used by any Communities as a Parent Community.')|n}
	%endif
    </td>
</tr>
${self.makeMgmtInfo(community)}
%endif
<tr>
	<td class="ui-widget-header field">${_('Name')}</th>
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
	<td class="ui-widget-header field">${renderer.label('community.ParentCommunityWeb', _('Parent Community'))}</th>
	<td class="ui-widget-content">
		${renderer.errorlist('community.ParentCommunity')}
        ${renderer.hidden('community.ParentCommunity', id='community_ParentCommunity')}
        ${renderer.text('community.ParentCommunityName', id='community_ParentCommunityWeb')}
	</td>
</tr>
<tr>
	<td class="ui-widget-header field">${renderer.label('community.ProvinceState', _('Province/State'))}</th>
	<td class="ui-widget-content">
		${renderer.errorlist('community.ProvinceState')}
        ${renderer.select('community.ProvinceState', [('','')] + prov_state)}
	</td>
</tr>
<tr>
	<td class="ui-widget-header field">${_('Alternate Names')}</th>
	<td class="ui-widget-content">
        <table class="form-table${' hidden' if not renderer.form.data.get('alt_names') else ''}" id="alt-name-target">
        <tr><th class="ui-widget-header">${_('Delete')}</th><th class="ui-widget-header">${_('Language')}</th><th class="ui-widget-header">${_('Alt Name')}</th></tr>
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
	<td class="ui-widget-header field">${_('Search Communities')}</th>
	<td class="ui-widget-content">
        <% form_alt_areas = renderer.form.data.get('alt_areas') or [] %>
        <ul id="alt-area-target" ${'' if form_alt_areas else 'class="hidden"' |n}>
            %for i,alt_area in enumerate(form_alt_areas):
                ${make_alt_area(str(i), alt_area, alt_area_name_map.get(alt_area))}
            %endfor
        </ul>

        <div id="search_community_new_input_table"><input type="text" class="text" id="NEW_search_community" maxlength="200"> <input type="button" id="add_search_community" value="${_('Add')}"></div>
	</td>
</tr>
%endif
<tr>
    <td class="ui-widget-header field">${renderer.label('ReasonForChange', _('Reason for Change'))}</td>
    <td class="ui-widget-content">
    ${renderer.errorlist('ReasonForChange')}
    ${renderer.textarea('ReasonForChange')}
    </td>
</tr>
<tr>
	<td colspan="2">
	<input type="submit" name="Submit" value="${_('Add') if action=='add' else _('Update')}"> 
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
                    ${renderer.errorlist(prefix + 'Delete')}
                    ${renderer.checkbox(prefix + 'Delete')}
                </td>
                <td class="ui-widget-content">
                    ${renderer.errorlist(prefix + 'Culture')}
                    ${renderer.select(prefix + 'Culture', self.languages)}
                </td>
                <td class="ui-widget-content">
                    ${renderer.errorlist(prefix + 'AltName')}
                    ${renderer.text(prefix + 'AltName')}
                </td>
</tr>
</%def>
<%def name="make_alt_area(number, value, label)">
            <li>
                ${renderer.errorlist('alt_areas-' + number)}
                ${renderer.checkbox('alt_areas-' + number, checked=True, id="search_community_ID_" + str(value), value=value, label= ' ' + label)}
            </li>
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
<script type="text/html" id="alt-area-template">
${make_alt_area('[COUNT]', '[ID]', '[LABEL]')}
</script>
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
        init_search_areas_checklist($, search_area_link, {field: 'search_community', not_found_msg:'${_("Not Found")|n}'});

        restore_cached_state();
    });
})(jQuery);
</script>
</%block>
