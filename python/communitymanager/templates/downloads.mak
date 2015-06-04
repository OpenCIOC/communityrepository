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

<%block name="title">${_('Downloads')}</%block>

%if request.user and request.user.Admin:
<p><a href="${request.route_path('publish')}">${_('Publish New File')}</a></p>
%endif

%if files:
<p><a rel="license" href="https://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons Licence" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/80x15.png" /></a> ${_('The geography data on this site is licensed under a ')}<a rel="license" href="https://creativecommons.org/licenses/by/4.0/">${_('Creative Commons Attribution 4.0 International License')}</a>.</p>
<ul id="download-list">
%for i, (dt, fname, log) in enumerate(files):
    <li>
    %if not dt:
    ${_('The following changes have not been released: ')}
    %else:
    <a href="${request.route_path('download', filename=fname)}">${request.format_datetime(dt)}</a>
    %endif
    %if log:
    ${changelog.makeLogTable(log)}
    %endif
    </li>
%endfor
</ul>
%endif:
%if not files or i==0 and not dt:
${self.printInfoMessage(_('No downloads available'))}
%endif
