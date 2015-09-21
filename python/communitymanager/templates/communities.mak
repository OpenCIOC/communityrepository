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
<%! import json %>

<%block name="title">${_('Browse Communities')}</%block>

<% user = request.user %>


<p id="action-bar">
<a class="ui-button ui-widget ui-state-default ui-corner-all ui-button-text-icon-primary" id="close-all-nodes" href="#"><span class="ui-icon ui-icon-folder-collapsed ui-button-icon-primary"></span><span class="ui-button-text">${_('Close All')}</span></a> 
%if user and user.ManageAreaList:
<a class="ui-button ui-widget ui-state-default ui-corner-all ui-button-text-icon-primary" id="reset-open-nodes" href="#"><span class="ui-icon ui-icon-folder-open ui-button-icon-primary"></span><span class="ui-button-text">${_('My Management Areas')}</span></a>
%endif
%if user and (user.Admin or user.ManageAreaList):
<a class="ui-button ui-widget ui-state-default ui-corner-all ui-button-text-icon-primary" href="${request.route_path('community', cmid='new')}"><span class="ui-icon ui-icon-document ui-button-icon-primary"></span><span class="ui-button-text">${_('New Community')}</span></a>
<a class="ui-button ui-widget ui-state-default ui-corner-all ui-button-text-icon-primary" href="${request.route_path('community', cmid='new', _query=[('altarea', 'on')])}"><span class="ui-icon ui-icon-lightbulb ui-button-icon-primary"></span><span class="ui-button-text">${_('New Alternate Area')}</span></a>
%endif
</p>
<p>
<form action="${request.route_path('search', _form=True)}">
<div class="hidden">
${renderer.form_passvars()}
</div>
<label for="terms">${_('Search: ')}</label>${renderer.text('terms')} <button id="search-button" class="ui-button ui-widget ui-state-default ui-corner-all ui-button-icon-only" role="button" aria-disabled="false" title="${_('Search')}"><span class="ui-button-icon-primary ui-icon ui-icon-search"></span><span class="ui-button-text">${_('Search')}</span></button>
</form>
</p>
%if external_systems:
<p>
<form action="${request.current_route_path(_form=True)}" method="GET">
<div class="hidden">
${renderer.form_passvars()}
</div>
<label for="ExternalSystem">${_('Show External Mapping: ')}</label> ${renderer.select('ExternalSystem', options = [('','')] + external_systems)} <button id="show-button" class="ui-button ui-widget ui-state-default ui-corner-all ui-button-icon-only" role="button" aria-disabled="false" title="${_('Show')}"><span class="ui-button-icon-primary ui-icon ui-icon-search"></span><span class="ui-button-text">${_('Show')}</span></button>
</form>
</p>
%endif
<%def name="tree_level(node, map, last=False)">
<% children = map.get(node.CM_ID) %>
<li class="tree-node ${'tree-leaf tree-closed' if not children else ''} ${'tree-node-last' if last else ''}" data-id="${node.CM_ID}" id="tree-node-${node.CM_ID}">
    <span class="ui-icon tree-node-icon ${'tree-node-expander' if children else ''}">${_('Open/Close')}</span>
    %if node.ExternalSystemMatch:
        <img src="/static/img/greencheck.gif">
    %endif
    %if node.AlternativeArea:
    <em>
    %endif
    <a href="#" class="community-name" data-id="${node.CM_ID}" title="${_('Click for Details')}">${node.Name}</a>
    %if node.AlternativeArea:
    </em>
    %endif
    %if node.CanEdit:
        <a href="${request.route_path('community', cmid=node.CM_ID)}" class="ui-icon ui-widget-content ui-icon-document" title=${_('Edit')}>${_('Edit')}</a>
    %endif
%if children:
    <ul class="tree-branch" style="display: none;" id="tree-branch-${node.CM_ID}">
        %for i,child in enumerate(children):
        ${tree_level(child, map, i==len(children)-1)}
        %endfor
    </ul>
%endif
</li>
</%def>
<div id="treecontainer">
<ul id="tree-root" class="tree-branch">
    ${tree_level(communities[None][0], communities, True)}
</ul>
</div>


<%block name="bottomscripts">
<div id="dialog" style="display: none;">
</div>
<script type="text/javascript" src="${request.static_path('communitymanager:static/js/browse.js')}"></script>
<script type="text/javascript">
jQuery(function($) {
    var default_open = ${json.dumps(request.user.ManageAreaList if request.user else [])|n},
        details_url = ${json.dumps(request.route_path('json_community', cmid='CMID'))|n};
   // $('#search-button').button({ icons: { primary: "ui-icon-search" }, text: false });
    init_browse(details_url, true, default_open);
});
</script>
</%block>


