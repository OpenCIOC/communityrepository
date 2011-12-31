<%inherit file="master.mak"/>

<%block name="title">${_('Review Suggestions')}</%block>

%if not suggestions:
    ${self.printInfoMessage(_('No Suggestions'))}
%endif
%if completed_suggestions and completed_suggestions[0]:
<p><a href="${request.current_route_path(_query=[('show_completed','on')])}">${_('Show %d Completed Suggestions') % completed_suggestions[0]}</a></p>
%elif not completed_suggestions:
<p><a href="${request.current_route_path(_query=[])}">${_('Hide Completed Suggestions')}</a></p>
%endif

%if suggestions:
<% show_completed = request.params.get('show_completed') %>
<table class="form-table tablesorter" id="suggestions">
<thead>
<tr>
<th class="ui-widget-header">${_('Action')}</th>
<th class="ui-widget-header">${_('Suggestion Date')}</th>
%if show_completed:
<th class="ui-widget-header">${_('Completed')}</th>
<th class="ui-widget-header">${_('Completed By')}</th>
%endif
<th class="ui-widget-header">${_('User Name')}</th>
<th class="ui-widget-header">${_('Suggestion')}</th>
</tr>
</thead>
%for suggestion in suggestions:
<tr>
<td class="ui-widget-content">
<% completed = suggestion.COMPLETED_DATE %>
%if not completed:
<a href="${request.route_path('complete_suggestion', _query=[('sjid', suggestion.Suggest_ID)])}">${_('Mark Completed')}</a>
%endif
</td>
<td class="ui-widget-content ${'inactive' if completed else '' |n}">${request.format_date(suggestion.CREATED_DATE)}</td>
%if show_completed:
<td class="ui-widget-content ${'inactive' if completed else '' |n}">${request.format_date(suggestion.COMPLETED_DATE)}</td>
<td class="ui-widget-content ${'inactive' if completed else '' |n}">${suggestion.COMPLETED_BY}</td>
%endif
<td class="ui-widget-content ${'inactive' if completed else '' |n}">${suggestion.UserName}</td>
<td class="ui-widget-content ${'inactive' if completed else '' |n}">${suggestion.Suggestion}</td>
</tr>
%endfor
</table>
%endif


<%block name="bottomscripts">
<script type="text/javascript" src="/static/js/libs/jquery.tablesorter.min.js"></script> 
<script type="text/javascript">
jQuery(function($) {
    $('#suggestions').tablesorter({headers: {0: {sorter: false}, ${5 if request.params.get('show_completed') else 3}: {sorter: false}}});
});
</script>
</%block>
