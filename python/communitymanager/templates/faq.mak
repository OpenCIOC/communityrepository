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

<%block name="title">${_('Frequently Asked Questions')}</%block>

<h2>${_(u'''What do I need to do if I want to use the Community Taxonomy in my project?''')|n}</h2>

<p>${_(u'''The Community Taxonomy data is available with a <a href="https://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 license.</a> That means that you can use the Taxonomy freely, but should provide attribution back to this website to allow others to make use of this resource. An ideal place for this type of attribution would be somewhere that you allow detailed browsing of the Community Taxonomy, but any appropriate spot (like an FAQ, copyright statement, or About page) is fine as long as it can be reasonably found.''')|n}</p>

<h2>${_(u'''Do I have to contribute back my changes?''')|n}</h2>

<p>${_(u'''It is not a requirement to contribute changes back, but this is strongly encouraged. By giving your changes back, you will be ensuring that the master version of the Community Taxonomy meets your needs, and therefore continue to benefit from the contributions of others.''')|n}</p>

<h2>${_(u'''Who owns my contributions?''')|n}</h2>

<p>${_(u'''In order to ensure that the data provided here can be licensed appropriately, it is required that all contributions be submitted with a transfer of intellectual property to the CIOC Organization, and licensing under the Creative Commons license. Note that the Creative Commons license means that contributors have free, perpetual rights to use, share, reformat, redistribute, or change the information they contribute; the only requirement is attribution. You will always be able to make use of your own contributions.''')|n}</p>

<h2>${_(u'''I need to map my changes to an external geographic system. What are my options?''')|n}</h2>

<p>${_(u'''The Community Repository software supports the maintenance of mappings to 3<sup>rd</sup> party systems. Please contact <a href="mailto:community-repo@cioc.ca">community-repo@cioc.ca</a> for more information.''')|n}</p>

<h2>${_(u'''I need more information for each community than what the Community Taxonomy supports. Can additional data elements be added?''')|n}</h2>

<p>${_(u'''The Community Repository is based on an open source project with an <a href="http://www.apache.org/licenses/LICENSE-2.0">Apache 2.0 license</a>.  You may be able to contribute enhancements to this project to meet your needs. For more information, visit <a href="https://bitbucket.org/cioc/communityrepository">https://bitbucket.org/cioc/communityrepository</a> or contact <a href="mailto:community-repo@cioc.ca">community-repo@cioc.ca</a>.''')|n}</p> 

<h2>${_(u'''I would like to become an editor for [Region]. How are editors chosen?''')|n}</h2>

<p>${_(u'''Anyone may apply to become an editor in a given region, but there is no guarantee that any person will be granted editorial privileges. All new editors must receive an orientation to Community Taxonomy management to ensure that they understand the structure and conventions of the Taxonomy. New editors may not be accepted if there are already sufficient editors for a given region. Editors are expected to follow a code of conduct which includes working collaboratively with other editors in their region and informing them of changes. Failure to work co-operatively or follow editorial guidelines may lead to revocation of editorial privileges. To request a change in editorial privileges on an existing account, please contact <a href="mailto:community-repo@cioc.ca">community-repo@cioc.ca</a>.''')|n}</p>

<h2>${_(u'''I want to add information for a new Country/State/Province where you do not currently have information. How do I get started?''')|n}</h2>

<p>${_(u'''If you have structured information you wish to contribute to cover an area not currently part of this Taxonomy, it may be possible to get introductory editors training and/or an initial import of the data at no cost to you. Please contact <a href="mailto:community-repo@cioc.ca">community-repo@cioc.ca</a> for more information (Note: you must currently own or plan to create the data you wish to contribute and agree to transfer the intellectual property under the Creative Commons license).''')|n}</p>

<h2>${_(u'''How do I submit a change request if I am not an Editor?''')|n}</h2>

<p>${_(u'''Anyone may suggest a change to the Community Taxonomy using the "Suggest Change" link in the menu. Please provide enough context so that the managing editor of the region can respond to the request, including supporting documentation links if possible.''')|n}</p>

<h2>${_(u'''When are new releases to the Taxonomy published?''')|n}</h2>

<p>${_(u'''New releases are published by request, generally once per quarter (4 times per year). You may send a request to <a href="mailto:community-repo@cioc.ca">community-repo@cioc.ca</a> to request that recent changes be evaluated for publication.''')|n}</p>

<h2>${_(u'''I need help integrating this system into my software project. Where can I get more information?''')|n}</h2>

<p>${_(u'''Data structure information, and even example code, is available through the open source project for the Community Repository <a href="https://bitbucket.org/cioc/communityrepository">https://bitbucket.org/cioc/communityrepository</a>. It is anticipated that more example open-source software code demonstrating the application of the Community Taxonomy will be made available in the near future, at which time this page will be updated. Further assistance or training may be available at a cost, please contact <a href="mailto:community-repo@cioc.ca">community-repo@cioc.ca</a>.''')|n}</p>
