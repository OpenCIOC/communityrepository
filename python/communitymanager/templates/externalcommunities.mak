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
<%! from markupsafe import Markup, escape %>

<%block name="title">${_('External Communities for %s') % _context.external_system.SystemName}</%block>

<% external_system = _context.external_system %>
<% holders = [x for x in [external_system.CopyrightHolder1, external_system.CopyrightHolder2] if x] %>
%if holders or external_system.Description or external_system.ContactEmail:
<p>
%if holders:
<strong>${_('Owner:')}</strong> ${_(' & ').join(holders)}<br>
%endif
%if external_system.ContactEmail:
<strong>${_('Contact:')}</strong> <a href="mailto:${external_system.ContactEmail}">${external_system.ContactEmail}</a><br>
%endif
%if external_system.Description:
<strong>${_('Description:')}</strong> ${external_system.Description}
%endif
</p>
%endif

<p id="action-bar">
%if can_edit:
<a class="ui-button ui-widget ui-state-default ui-corner-all ui-button-text-icon-primary" href="${request.route_path('external_community_add', SystemCode=_context.external_system.SystemCode)}"><span class="ui-icon ui-icon-document ui-button-icon-primary" aria-hidden="true"></span><span class="ui-button-text">${_('New External Community')}</span></a>
%endif
<a class="ui-button ui-widget ui-state-default ui-corner-all ui-button-text-icon-primary" href="${request.route_path('external_community_download', SystemCode=_context.external_system.SystemCode)}"><span class="ui-icon ui-icon-suitcase ui-button-icon-primary" aria-hidden="true"></span><span class="ui-button-text">${_('Download Mapping')}</span></a>
</p>

%if external_communities:
<p>${escape(_('Mapped communities that have been assigned to multple External Communities are marked with %s.')) % (Markup('''<span class="ui-state-error required-flag"><span class="ui-icon ui-icon-star" title="%s"}"><em>%s</em></span></span>''') % (_('Warning: Duplicate Mapping'), _('Warning: Duplicate Mapping')))}</p>
<table class="form-table tablesorter" id="mapped-communities">
<thead>
<tr>
<th class="ui-widget-header">${_('Area Name')}</th>
<th class="ui-widget-header">${_('Parent Community')}</th>
<th class="ui-widget-header">${_('Primary Area Type')}</th>
##<th class="ui-widget-header">${_('Sub Area Type')}</th>
<th class="ui-widget-header">${_('Province/State/Country')}</th>
##<th class="ui-widget-header">${_('External ID')}</th>
<th class="ui-widget-header">${_('AIRS Export Type')}</th>
<th class="ui-widget-header">${_('Mapped Community')}</th>
##<th class="ui-widget-header">${_('Mapped Community Province/State/Country')}</th>
<th class="ui-widget-header">${_('Mapped Community Parent')}</th>
%if can_edit:
<th class="ui-widget-header">${_('Action')}</th>
%endif
</tr>
</thead>
%for community in external_communities:
<tr>
<td class="ui-widget-content">${community.AreaName}</td>
<td class="ui-widget-content">${community.ParentName or ''}</td>
<td class="ui-widget-content">${community.PrimaryAreaTypeName or ''}</td>
##<td class="ui-widget-content">${community.SubAreaTypeName or ''}</td>
<td class="ui-widget-content">${community.ProvinceStateCountry or ''}</td>
##<td class="ui-widget-content">${community.ExternalID or ''}</td>
<td class="ui-widget-content">${community.AIRSExportType or ''}</td>
<td class="ui-widget-content">
%if community.DuplicateWarning:
<span class="ui-state-error required-flag"><span class="ui-icon ui-icon-star" title="${_('Warning: Duplicate Mapping')}"><em>${_('Warning: Duplicate Mapping')}</em></span></span>
%endif
${community.MappedCommunityName or ''}
</td>
##<td class="ui-widget-content">${community.MappedProvinceStateCountry or ''}</td>
<td class="ui-widget-content">${community.MappedParentCommunityName or ''}</td>
%if can_edit:
<td class="ui-widget-content">
    <a href="${request.route_path('external_community', SystemCode=external_system.SystemCode, action='edit', EXTID=unicode(community.EXT_ID))}">${_('Edit')}</a>
</td>
%endif
</tr>
%endfor
</table>
%else:
   <em>${_('No external communities found.')}</em> 
%endif

<%block name="bottomscripts">
%if external_communities:
<script type="text/javascript" src="/static/js/libs/jquery.tablesorter.min.js"></script> 
<script type="text/javascript">
jQuery(function($) {
    var mapped_communities = $('#mapped-communities')
%if can_edit:
    var number_of_elements = mapped_communities.find('thead tr th').length; 
    var args = {headers: {}};
    args.headers[number_of_elements-1] = {sorter: false}
%else:  
    var args = {};
%endif
    mapped_communities.tablesorter(args);
});
</script>
%endif
</%block>
