<%def name="makeLogTable(logentries)">
<table class="form-table">
<tr>
<td class="ui-widget-header">${_('Date')}</td>
<td class="ui-widget-header">${_('Modified By')}</td>
<td class="ui-widget-header">${_('Type')}</td>
<td class="ui-widget-header">${_('Community Name')}</td>
<td class="ui-widget-header">${_('Comment')}</td>
</tr>
<% types = {True: _('Add'), False: _('Delete'), None: _('Update')} %>
%for entry in logentries:
<tr>
<td class="ui-widget-content">${request.format_datetime(entry.MODIFIED_DATE)}</td>
<td class="ui-widget-content">${entry.MODIFIED_BY}</td>
<td class="ui-widget-content">${types[entry.TypeOfChange]}</td>
<td class="ui-widget-content">
    %if entry.FormerName != entry.CurrentName:
    ${entry.FormerName or ''} 
    ${'->' if entry.FormerName and entry.CurrentName and entry.FormerName != entry.CurrentName else ''}
    ${entry.CurrentName or ''}
    %else:
    ${entry.CurrentName or entry.FormerName or ''}
    %endif
    </td>
<td class="ui-widget-content">${entry.ChangeComment}</td>
</tr>
%endfor
</table>
</%def>

