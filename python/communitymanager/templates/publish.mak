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
<%namespace file="changelog.mak" name="changelog"/>

<%block name="title">${_('Publish New Download')}</%block>

<form method="POST" action="${request.current_route_path(_form=True)}">
<div class="hidden">
${renderer.form_passvars()}
</div>
<input type="submit" value="${_('Confirm Creation of New Download')}">
</form>

%if logentries:
${self.printInfoMessage(_('The following changes have been made since the last file was published'))}
${changelog.makeLogTable(logentries)}
%else:
${self.printInfoMessage(_('There have been no changes since the last file was published'))}
%endif
