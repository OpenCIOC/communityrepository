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
