<%inherit file="master.mak"/>
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
</style>

<%def name="tree_level(node, map, last=False)">
<% children = map.get(node.CM_ID) %>
<li class="tree-node ${'tree-leaf' if not node.HasChildren else ''} ${'tree-open' if node.OpenItem else 'tree-closed'} ${'tree-node-last' if last else ''}" data-id="${node.CM_ID}">
    <span class="tree-node-icon ${'tree-node-expander' if node.HasChildren else ''}"></span>
    ${node.Name}
%if children:
    <ul class="tree-branch">
        %for i,child in enumerate(children):
        ${tree_level(child, map, i==len(children)-1)}
        %endfor
    </ul>
%endif
</li>
</%def>
<div id="treecontainer">
<ul id="tree-root" class="tree-branch">
    ${tree_level(start_communities[None][0], start_communities, True)}
</ul>
</div>


<%block name="bottomscripts">
<script type="text/javascript">
(function($) {
    var toggle_node = function(event) {
        var self = $(this), li = self.parent(), is_open = li.hasClass('tree-open'), ul = li.children('ul');
        if (is_open) {
                li.removeClass('tree-open');
                li.addClass('tree-closed');
                ul.slideUp('slow');
        } else {
            if (ul.length) {
                ul.slideDown('slow');
                li.removeClass('tree-closed');
                li.addClass('tree-open');
            } else {
                // XXX fetch data
            }
        }

    }
    init = function($) {
        $('#tree-root').on('click', '.tree-node-icon', toggle_node);
    };
    $(init);
})(jQuery);
</script>
</%block>


