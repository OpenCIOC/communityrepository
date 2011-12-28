<%inherit file="master.mak"/>
<%! import json %>

<%block name="title">${_('Browse Communities')}</%block>

<style type="text/css">
    #tree-root li, #tree-root .tree-node-icon {
        background-image:url("/static/img/d.png"); background-repeat:no-repeat; background-color:transparent;
    }
    #tree-root li { background-position:-90px 0; background-repeat:repeat-y;  line-height: 18px;}
    #tree-root li.tree-node-last { background:transparent; }
    #tree-root .tree-open > .tree-node-icon { background-position:-72px 0; }
    #tree-root .tree-closed > .tree-node-icon { background-position:-54px 0; }
    #tree-root .tree-leaf > .tree-node-icon { background-position:-36px 0; }
    #tree-root {
        padding: 0;
    }

    .tree-node-expander, .community-name {
        cursor: pointer;
    }
    ul.tree-branch {
        list-style-type: none;
        padding-left: 1.5em;
        margin: 0em;
    }
    .tree-node-icon {
        vertical-align: bottom;
        display: inline-block;
        text-decoration: none;
        width: 18px;
        height: 18px;
        margin: 0;
        padding: 0;
    }
    a.ui-icon {
        display: inline-block;
        border: none;
    }
</style>

<% user = request.user %>
%if user and (user.Admin or user.ManageAreaList):
<p>${_('Add new:')} <a href="${request.route_path('community', cmid='new')}">${_('Community')}</a> | <a href="${request.route_path('community', cmid='new', _query=[('altarea', 'on')])}">${_('Alternate Search Area')}</a></p>
%endif

<p><a id="close-all-nodes" href="#">${_('Close All')}</a> 
%if user and user.ManageAreaList:
| <a id="reset-open-nodes" href="#">${_('Show Editable Communities')}</a>
%endif
</p>
<%def name="tree_level(node, map, last=False)">
<% children = map.get(node.CM_ID) %>
<li class="tree-node ${'tree-leaf tree-closed' if not children else ''} ${'tree-node-last' if last else ''}" data-id="${node.CM_ID}" id="tree-node-${node.CM_ID}">
    <span class="ui-icon tree-node-icon ${'tree-node-expander' if children else ''}">${_('Open/Close')}</span>
    <a href="#" class="community-name" data-id="${node.CM_ID}" title="${_('Click for Details')}">${node.Name}</a>
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
<script id="details-template" type="text/html">
</script>
<div id="dialog" style="display: none;">

</div>
<script type="text/javascript" src="${request.static_path('communitymanager:static/js/browse.js')}"></script>
<script type="text/javascript">
(function($) {
    var open_nodes = [], default_open = ${json.dumps(request.user.ManageAreaList)|n},
        details_url = ${json.dumps(request.route_path('json_community', cmid='CMID'))|n}, dialog=null,
    remove = function(arr, from, to) {
        var rest = arr.slice((to || from) + 1 || arr.length);
        arr.length = from < 0 ? arr.length + from : from;
        return arr.push.apply(arr, rest);
    },
    toggle_node = function(event) {
        var self = $(this), li = self.parent(), is_open = li.hasClass('tree-open'), ul = li.children('ul'),
            cm_id = li.data('id'), in_array = $.inArray(cm_id, open_nodes);
        if (is_open) {
                if (in_array >=0) {
                    remove(open_nodes, in_array);
                }
                li.removeClass('tree-open');
                li.addClass('tree-closed');
                ul.slideUp();
        } else {
            ul.slideDown();
            li.removeClass('tree-closed');
            li.addClass('tree-open');
            open_nodes.push(cm_id);
        }
        amplify.store('open_nodes', open_nodes);

    },
    show_community_details = function(evt) {
        var self = $(this), cm_id = self.data('id');
        $.ajax({
            url: details_url.replace('CMID', cm_id),
            dataType: 'json',
            success: function(data) {
                if (data.fail) {
                    // XXX Log something?
                    return;
                }

                dialog.html(data.community_info);
                dialog.dialog('option', 'title', data.community_name)
                dialog.dialog('open');
            }
        });
        return false;
    },
    close_all = function(evt) {
        $('.tree-branch .tree-branch').hide();
        $('.tree-node').removeClass('tree-open').addClass('tree-closed');
        amplify.store('open_nodes', []);
        return false;
    },
    open_node_set = function(nodes, force_parents_open) {
        var tree_container = $('#treecontainer').hide(),
            set = {};
        for (var i=0; i < nodes.length; i++) {
            set[nodes[i]] = true;
        }

        $.each(nodes, function(idx, val) {
            var li = $('#tree-node-' + val).removeClass('tree-closed').addClass('tree-open'),
                ul = $('#tree-branch-' + val).show();
            if (force_parents_open) {
                li.parents('.tree-node').removeClass('tree-closed').addClass('tree-open').
                    each(function(idx, val) { set[val] = true; });
                ul.parents('.tree-branch').show();
            }
        })

        nodes = [];
        $.each(set, function(key, val) {
            nodes.push(key);
        });

        open_nodes = nodes;
        amplify.store('open_nodes', open_nodes);

        tree_container.show()
    },
    show_default = function(evt) {
        close_all();
        open_node_set(default_open, true);
        return false;
    },
    init = function($) {
        var force_parents_open = false;
        open_nodes = amplify.store('open_nodes');
        $('#tree-root').on('click', '.tree-node-icon', toggle_node).
            on('click', '.community-name', show_community_details);
        if (!open_nodes && open_nodes !== []) {
            if (default_open) {
                open_nodes = default_open;
                force_parents_open = true
            } else {
                open_nodes = [];
            }
        }

        if (open_nodes) {
            open_node_set(open_nodes, force_parents_open);   
        }
        dialog = $('#dialog').dialog({autoOpen: false})

        $('#close-all-nodes').click(close_all);
        $('#reset-open-nodes').click(show_default);
    };
    $(init);
})(jQuery);
</script>
</%block>


