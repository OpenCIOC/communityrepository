<%inherit file="master.mak"/>
<%block name="title">${_('Publish New Download')}</%block>

<form method="POST" action="${request.current_route_path(_form=True)}">
<div class="hidden">
${renderer.form_passvars()}
</div>
<input type="submit" value="${_('Publish New Download')}">
</form>

%if logentries:
${self.printInfoMessage(_('The following changes have been made since the last file was published'))}
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
%else:
${self.printInfoMessage(_('There have been no changes since the last file was published'))}
%endif
