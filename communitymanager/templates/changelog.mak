<%def name="makeLogTable(logentries)">
<table class="form-table">
<tr>
<th class="ui-widget-header">${_('Date')}</th>
<th class="ui-widget-header">${_('Modified By')}</th>
<th class="ui-widget-header">${_('Comment')}</th>
</tr>
%for entry in logentries:
<tr>
<td class="ui-widget-content">${request.format_datetime(entry.MODIFIED_DATE)}</td>
<td class="ui-widget-content">${entry.MODIFIED_BY}</td>
<td class="ui-widget-content">${entry.ChangeComment}</td>
</tr>
%endfor
</table>
</%def>

