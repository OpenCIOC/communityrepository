(function($) {
    var open_nodes = [], default_open = null,
        details_url = null, dialog=null,
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

                if (dialog.dialog('isOpen')) {
                    dialog.dialog('close');
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
        open_nodes = [];
        amplify.store('open_nodes', open_nodes);
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
                    each(function(idx, val) { set[$(val).data('id')] = true; });
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
    init = function(in_details_url, use_tree, in_default_open) {
        var force_parents_open = false, troot = $('#tree-root');
        details_url=in_details_url;
        default_open = in_default_open;

        troot.on('click', '.community-name', show_community_details);
        dialog = $('#dialog').dialog({autoOpen: false, minWidth: 450})

        if (use_tree) {
            open_nodes = amplify.store('open_nodes');
            troot.on('click', '.tree-node-icon', toggle_node);
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

            $('#close-all-nodes').click(close_all);
            $('#reset-open-nodes').click(show_default);
        }
    };
    window['init_browse'] = init;
})(jQuery);

