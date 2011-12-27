<%inherit file="master.mak"/>
<%block name="title">${_('Downloads')}</%block>

%if request.user.Admin:
<p><a href="${request.route_path('publish')}">${_('Publish New File')}</a></p>
%endif

%if files:
<ul>
%for dt, fname, log in files:
    <li><a href="${request.route_path('download', filename=fname)}">${request.format_datetime(dt)}</a></li>
%endfor
</ul>
%else:
${self.printInfoMessage(_('No downloads available'))}
%endif
