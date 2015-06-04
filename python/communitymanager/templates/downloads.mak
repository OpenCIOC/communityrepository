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
