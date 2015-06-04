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

