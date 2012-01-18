<%def name="make_cm_checklist_item(prefix, value, label)">
            <li>
                ${renderer.errorlist(prefix)}
                ${renderer.checkbox(prefix, checked=True, id="cm_checklist_ID_" + str(value), value=value, label= ' ' + label)}
            </li>
</%def>

<%def name="make_cm_checklist_ui(name, name_map)">
        ${renderer.errorlist(name)}
        <% form_data = renderer.form.data.get(name) or [] %>
        <ul id="cm-checklist-target" ${'' if form_data else 'class="hidden"' |n}>
            %for i,item_id in enumerate(form_data):
                ${make_cm_checklist_item('-'.join((name, str(i))), item_id, name_map.get(str(item_id)))}
            %endfor
        </ul>

        <div id="cm_checklist_new_input_table"><input type="text" class="text" id="NEW_cm_checklist" maxlength="200"> <input type="button" id="add_cm_checklist" value="${_('Add')}"></div>
</%def>

<%def name="make_cm_checklist_template(name)">
<script type="text/html" id="cm-checklist-template">
${make_cm_checklist_item(name + '-[COUNT]', '[ID]', '[LABEL]')}
</script>
</%def>
