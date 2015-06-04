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
