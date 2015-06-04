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

<%block name="title">${_('External Communities for %s') % _context.external_system.SystemName}</%block>

<% user = request.user %>
%if user and (user.Admin or user.ManageExternalSystemList):
<p id="action-bar">
<a class="ui-button ui-widget ui-state-default ui-corner-all ui-button-text-icon-primary" href="${request.route_path('external_community_add', SystemCode=_context.external_system.SystemCode)}"><span class="ui-icon ui-icon-document ui-button-icon-primary"></span><span class="ui-button-text">${_('New External Community')}</span></a>
</p>
%endif

<table class="form-table tablesorter" id="mapped-communities">
<thead>
<tr>
<th class="ui-widget-header">${_('Area Name')}</th>
<th class="ui-widget-header">${_('Primary Area Type')}</th>
<th class="ui-widget-header">${_('Sub Area Type')}</th>
<th class="ui-widget-header">${_('Province/State/Country')}</th>
<th class="ui-widget-header">${_('External ID')}</th>
<th class="ui-widget-header">${_('Mapped Community')}</th>
<th class="ui-widget-header">${_('Mapped Community Province/State/Country')}</th>
<th class="ui-widget-header">${_('Mapped Community Parent')}</th>
%if can_edit:
<th class="ui-widget-header">${_('Action')}</th>
%endif
</tr>
</thead>
%for community in external_communities:
<tr>
<td class="ui-widget-content">${community.AreaName}</td>
<td class="ui-widget-content">${community.PrimaryAreaTypeName or ''}</td>
<td class="ui-widget-content">${community.SubAreaTypeName or ''}</td>
<td class="ui-widget-content">${community.ProvinceStateCountry or ''}</td>
<td class="ui-widget-content">${community.ExternalID or ''}</td>
<td class="ui-widget-content">${community.MappedCommunityName or ''}</td>
<td class="ui-widget-content">${community.MappedProvinceStateCountry or ''}</td>
<td class="ui-widget-content">${community.MappedParentCommunityName or ''}</td>
%if can_edit:
<td class="ui-widget-content">
    <a href="${request.route_path('external_community', SystemCode=external_system.SystemCode, action='edit', EXTID=unicode(community.EXT_ID))}">${_('Edit')}</a>
</td>
%endif
</tr>
%endfor
</table>

<%block name="bottomscripts">
<script type="text/javascript" src="/static/js/libs/jquery.tablesorter.min.js"></script> 
<script type="text/javascript">
jQuery(function($) {
    $('#mapped-communities').tablesorter({headers: {8: {sorter: false}}});
});
</script>
</%block>
