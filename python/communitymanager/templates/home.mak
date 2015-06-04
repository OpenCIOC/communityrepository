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
<%block name="title">${_('Welcome to the CIOC Communities Repository!')}</%block>

<p>${_('This repository acts as the source of authorized "Communities Taxonomy" data used by CIOC software users and some of their partner agencies. In order to foster collaboration, the geographic taxonomy contained in this site has been made available under a Creative Commons license that allows free use in any application.')}</p>

<p>${_('This repository provides the following features:')}</p>
<ul>
	<li>Communities searching tools</li>
	<li>A list of, and download files for, official releases of the Communities Taxonomy data</li>
	<li>A log of changes made to the data in the repository for each official release, as well as recent changes not yet incorporated into a release</li>
	<li>Editorial tools for repository managers</li>
</ul>
%if not request.user:
<p>${_('If you wish to request an account, please visit the ')}<a href="${request.route_path('request_account')}">${_('Request Account')}</a>${_(' page; accounts must be approved. <em>Note that accounts are not required to search or download the Community Taxonomy</em>, but are required to become an editor or suggest a change.')}</p>
%endif
<p>${_('The ongoing maintenance of this repository is provided by volunteers. When requesting an account, you will have the opportunity to request administrative privileges for specific geographic areas. Please be aware that we may need to limit the number of editors in order to encourage editorial consistency; therefore, not all requests for administrative privileges will be granted. Training is required for all editors, and those who participate in the maintenance of this repository must work collaboratively with their co-editors to facilitate co-operative and consistent data maintenance activities.')}</p>
<p>${_('Do you have further questions about the CIOC Communities Repository? Please visit the ')} <a href="${request.route_path('faq')}">${_('Frequently Asked Questions')}</a>${_(' page')}.</p>
%if not request.user:
<p>${_('Already have an account?')} <a href="${request.route_path('login')}">${_('Login Now!')}</a>
%endif

