<%inherit file="master.mak"/>
<%block name="title">${_('Welcome to the CIOC Communities Repository!')}</%block>

<p>${_('Currently, access to this repository is available to CIOC members and other designated organizations who have subscribed to this classification system by special arrangement with CIOC. This repository acts as the source of authorized "Communities" data used by CIOC members and some of their partner agencies. Access to this repository provides the following features: ')}</p>
<ul>
	<li>Communities searching tools</li>
	<li>Editorial tools for reposotiry managers</li>
	<li>A list of, and download files for, official releases of the CIOC Communities data</li>
	<li>Log of changes made to the data in the repository for each official relase, as well as recent changes not yet incorporated into a release</li>
</ul>
%if not request.user:
<p>${_('If you wish to request an account, please visit the ')}<a href="${request.route_path('request_account')}">${_('Request Account')}</a>${_(' page; requests should come from official CIOC membership contacts (administrative or technical contact) whenever possible. Requests that do not come from the official membership contact may need to be vetted by those official contacts.')}
%endif
<p>${_('The ongoing maintenance of this repository is provided by volunteers from the CIOC Community. When requesting an account, you will have the opportunity to request administrative privileges for specific geographic areas. Please be aware that we may need to limit the number of editors in order to encourage editorial consistency; therefore, not all requests for administrative privileges will be granted. Those who do participate in the maintenance of this repository will be put in touch with their co-editors to facilitate co-operative and consistent data maintenance activities.')}</p>
<p>${_('Do you have further questions about the CIOC Communities Repository? CIOC Members should post questions on the')} <a href="http://community.cioc.ca/message-board/">${_('CIOC Community Message Board')}</a>. ${_('Non-members may get information about subscribing to the CIOC Communities Repository by')} <a href="http://www.cioc.ca/contact.aspx">${_('contacting CIOC for details')}</a></p>
%if not request.user:
<p>${_('Already have an account?')} <a href="${request.route_path('login')}">${_('Login Now!')}</a>
%endif

