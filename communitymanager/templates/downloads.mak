<%inherit file="master.mak"/>
<%namespace file="changelog.mak" name="changelog"/>

<%block name="title">${_('Downloads')}</%block>

%if request.user.Admin:
<p><a href="${request.route_path('publish')}">${_('Publish New File')}</a></p>
%endif

%if files:
<ul id="download-list">
%for dt, fname, log in files:
    <li>
    %if not dt:
    ${_('The following changes have not been released:')}
    %else:
    <a href="${request.route_path('download', filename=fname)}">${request.format_datetime(dt)}</a>
    %endif
    %if log:
    ${changelog.makeLogTable(log)}
    %endif
    </li>
%endfor
</ul>
%else:
${self.printInfoMessage(_('No downloads available'))}
%endif
