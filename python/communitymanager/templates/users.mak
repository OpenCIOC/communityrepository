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

<%block name="title">${_('User Management')}</%block>

%if user_requests:
<h3>${_('Account Requests')}</h3>
%if rejected_requests and rejected_requests[0]:
<p><a href="${request.current_route_path(_query=[('show_rejected','on')])}">${_('Show %d Rejected Requests') % rejected_requests[0]}</a></p>
%elif not rejected_requests:
<p><a href="${request.current_route_path(_query=[])}">${_('Hide Rejected Requests')}</a></p>
%endif
<table class="form-table tablesorter">
<thead>
<tr>
<th class="ui-widget-header">${_('Action')}</th>
<th class="ui-widget-header">${_('Request Date')}</th>
<th class="ui-widget-header">${_('User Name')}</th>
<th class="ui-widget-header">${_('Name')}</th>
<th class="ui-widget-header">${_('Organization')}</th>
<th class="ui-widget-header">${_('Email')}</th>
<th class="ui-widget-header">${_('Manage Area')}</th>
</tr>
</thead>
%for user in user_requests:
<tr>
<td class="ui-widget-content"><a href="${request.route_path('user_new', _query=[('reqid', user.Request_ID)])}">${_('Add')}</a>
%if not user.REJECTED_DATE:
| <a href="${request.route_path('request_reject', _query=[('reqid', user.Request_ID)])}">${_('Reject')}</a>
%endif
</td>
<% rejected = user.REJECTED_DATE %>
<td class="ui-widget-content ${'inactive' if rejected else '' |n}">${request.format_date(user.REQUEST_DATE)}</td>
<td class="ui-widget-content ${'inactive' if rejected else '' |n}">${user.PreferredUserName}</td>
<td class="ui-widget-content ${'inactive' if rejected else '' |n}">${u' '.join((user.FirstName,user.LastName))}</td>
<td class="ui-widget-content ${'inactive' if rejected else '' |n}">${user.Organization}</td>
<td class="ui-widget-content ${'inactive' if rejected else '' |n}">${user.Email}</td>
<td class="ui-widget-content ${'inactive' if rejected else '' |n}">${_('Yes') if user.ManageAreaRequest else _('No')}</td>
</tr>
%endfor
</table>

<h3>${_('Existing Users')}</h3>
%endif
<table class="form-table tablesorter" id="existing-users">
<thead>
<tr>
<th class="ui-widget-header">${_('User Name')}</th>
<th class="ui-widget-header">${_('Name')}</th>
<th class="ui-widget-header">${_('Initials')}</th>
<th class="ui-widget-header">${_('Organization')}</th>
<th class="ui-widget-header">${_('Email')}</th>
<th class="ui-widget-header">${_('Admin')}</th>
<th class="ui-widget-header">${_('Active')}</th>
<th class="ui-widget-header">${_('Manage Communities')}</th>
<th class="ui-widget-header">${_('Action')}</th>
</tr>
</thead>
<% my_uid = request.user.User_ID %>
%for user in users:
<tr>
<td class="ui-widget-content ${'inactive' if user.Inactive else '' |n}">${user.UserName}</td>
<td class="ui-widget-content ${'inactive' if user.Inactive else '' |n}">${u' '.join((user.FirstName,user.LastName))}</td>
<td class="ui-widget-content ${'inactive' if user.Inactive else '' |n}">${user.Initials}</td>
<td class="ui-widget-content ${'inactive' if user.Inactive else '' |n}">${user.Organization}</td>
<td class="ui-widget-content ${'inactive' if user.Inactive else '' |n}">${user.Email}</td>
<td class="ui-widget-content ${'inactive' if user.Inactive else '' |n}">${_('Yes') if user.Admin else _('No')}</td>
<td class="ui-widget-content ${'inactive' if user.Inactive else '' |n}">${_('Yes') if not user.Inactive else _('No')}</td>
<td class="ui-widget-content ${'inactive' if user.Inactive else '' |n}">${u', '.join(user.ManageCommunities)}</td>
<td class="ui-widget-content">
%if my_uid!=user.User_ID:
    <a href="${request.route_path('user', uid=user.User_ID)}">${_('Edit')}</a>
%endif
</td>
</tr>
%endfor
</table>

%if not user_requests and rejected_requests and rejected_requests[0]:
<h3>${_('Account Requests')}</h3>
<p><a href="${request.current_route_path(_query=[('show_rejected','on')])}">${_('Show %d Rejected Requests') % rejected_requests[0]}</a></p>
%endif

<%block name="bottomscripts">
<script type="text/javascript" src="/static/js/libs/jquery.tablesorter.min.js"></script> 
<script type="text/javascript">
jQuery(function($) {
    $('#existing-users').tablesorter({headers: {8: {sorter: false}}});
});
</script>
</%block>
