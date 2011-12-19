<%inherit file="master.mak"/>

<%block name="title">${_('User Management')}</%block>

%if user_requests:
<h3>${_('Account Requests')}</h3>
<table class="form-table">
<tr>
<th class="ui-widget-header">${_('Action')}</th>
<th class="ui-widget-header">${_('Request Date')}</th>
<th class="ui-widget-header">${_('User Name')}</th>
<th class="ui-widget-header">${_('Name')}</th>
<th class="ui-widget-header">${_('Organization')}</th>
<th class="ui-widget-header">${_('Email')}</th>
<th class="ui-widget-header">${_('Manage Area')}</th>
</tr>
%for user in user_requests:
<tr>
<td class="ui-widget-content"><a href="${request.route_path('user_new', _query=[('reqid', user.Request_ID)])}">${_('Add')}</a></td>
<td class="ui-widget-content">${request.format_date(user.REQUEST_DATE)}</td>
<td class="ui-widget-content">${user.PreferredUserName}</td>
<td class="ui-widget-content">${u' '.join((user.FirstName,user.LastName))}</td>
<td class="ui-widget-content">${user.Organization}</td>
<td class="ui-widget-content">${user.Email}</td>
<td class="ui-widget-content">${_('Yes') if user.ManageAreaRequest else _('No')}</td>
</tr>
%endfor
</table>

<h3>${_('Existing Users')}</h3>
%endif
<table class="form-table">
<tr>
<th class="ui-widget-header">${_('Action')}</th>
<th class="ui-widget-header">${_('User Name')}</th>
<th class="ui-widget-header">${_('Name')}</th>
<th class="ui-widget-header">${_('Initials')}</th>
<th class="ui-widget-header">${_('Organization')}</th>
<th class="ui-widget-header">${_('Email')}</th>
<th class="ui-widget-header">${_('Admin')}</th>
<th class="ui-widget-header">${_('Active')}</th>
<th class="ui-widget-header">${_('Manage Communities')}</th>
</tr>
%for user in users:
<tr>
<td class="ui-widget-content"><a href="${request.route_path('user', uid=user.User_ID)}">${_('Edit')}</a></td>
<td class="ui-widget-content">${user.UserName}</td>
<td class="ui-widget-content">${u' '.join((user.FirstName,user.LastName))}</td>
<td class="ui-widget-content">${user.Initials}</td>
<td class="ui-widget-content">${user.Organization}</td>
<td class="ui-widget-content">${user.Email}</td>
<td class="ui-widget-content">${_('Yes') if user.Admin else _('No')}</td>
<td class="ui-widget-content">${_('Yes') if not user.Inactive else _('No')}</td>
<td class="ui-widget-content">${u', '.join(user.ManageCommunities)}</td>
</tr>
%endfor
</table>
