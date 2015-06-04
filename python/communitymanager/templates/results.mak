<%inherit file="master.mak"/>
<%! import json %>

<%block name="title">${_('Search Communities')}</%block>

<% user = request.user %>

<p id="action-bar">
<a class="ui-button ui-widget ui-state-default ui-corner-all ui-button-text-icon-primary" href="${request.route_path('communities')}"><span class="ui-icon ui-icon-arrowthick-1-w ui-button-icon-primary"></span><span class="ui-button-text">${_('Back to Browse')}</span></a>
%if user and (user.Admin or user.ManageAreaList):
<a class="ui-button ui-widget ui-state-default ui-corner-all ui-button-text-icon-primary" href="${request.route_path('community', cmid='new')}"><span class="ui-icon ui-icon-document ui-button-icon-primary"></span><span class="ui-button-text">${_('New Community')}</span></a>
<a class="ui-button ui-widget ui-state-default ui-corner-all ui-button-text-icon-primary" href="${request.route_path('community', cmid='new', _query=[('altarea', 'on')])}"><span class="ui-icon ui-icon-lightbulb ui-button-icon-primary"></span><span class="ui-button-text">${_('New Alternate Area')}</span></a></p>
%endif
</p>

<form action="${request.route_path('search', _form=True)}">
<div class="hidden">
${renderer.form_passvars()}
</div>

${renderer.errorlist('terms')}
${_('Search: ')} 
${renderer.text('terms')}
<button id="search-button" class="ui-button ui-widget ui-state-default ui-corner-all ui-button-icon-only" role="button" aria-disabled="false" title="${_('Search')}"><span class="ui-button-icon-primary ui-icon ui-icon-search"></span><span class="ui-button-text">${_('Search')}</span></button>
</form>
</p>

<div id="treecontainer">
<ul id="tree-root" class="tree-branch">
%for community in communities:
<li class="tree-node-last" data-id="${community.CM_ID}" id="tree-node-${community.CM_ID}">
    %if community.AlternativeArea:
    <em>
    %endif
    <a href="#" class="community-name" data-id="${community.CM_ID}" title="${_('Click for Details')}">${community.Display}</a>
    %if community.AlternativeArea:
    </em>
    %endif
    %if community.CanEdit:
        <a href="${request.route_path('community', cmid=community.CM_ID)}" class="ui-icon ui-widget-content ui-icon-document" title=${_('Edit')}>${_('Edit')}</a>
    %endif
%endfor
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
    init_browse(details_url, true, default_open);
});
</script>
</%block>


