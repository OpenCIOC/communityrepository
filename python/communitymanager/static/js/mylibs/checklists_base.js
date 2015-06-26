/* =========================================================================================
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
  ========================================================================================= */

(function() {
var $ = jQuery;
var init_municipality_autocomplete = function(fields, url, errmsg) {
	fields.each(function() {
		var cache = {}, self = this, my_id = this.id,
			shadow_id = my_id.replace('Web', ''), 
			shadow_el = $('#' + shadow_id),
			input_el = $(this).
				data('cm_info', {'value': this.value, 'chkid': shadow_el[0].value}).
				autocomplete({
					focus:function(event,ui) {
						return false;
					},
					source: create_caching_source_fn($,url, cache),
					minLength: 1,
                    select: function(event, ui) {
                        input_el.data('cm_info', {
                            chkid: ui.item.chkid,
                            value: ui.item.value
                        });
                    },
                    close: function() {
                        if (!input_el.is(':focus')) {
                            on_blur_timeout();
                        }
                    }
				}).
				keypress(function (evt) {
					if (evt.keyCode == '13') {
						evt.preventDefault();
						input_el.autocomplete('close');
					}
				}),
            on_blur_timeout = function() {
                var info = input_el.data('cm_info'), value=self.value,
                    testvalue, content;
                if (!value) {
                    shadow_el[0].value = '';
                    return;
                }
                if (info && info.chkid && info.value && info.value === value) {
                    shadow_el[0].value = info.chkid;
                    return;
                }
                 
                testvalue = string_ci_ai(value);
                if (cache.content) {
                    var values = $.grep(cache.content, function(value) {
                        return string_ci_ai(value.value) === testvalue;
                    });
                    if (values.length === 1) {
                        shadow_el[0].value = values[0].chkid;
                        input_el.data('cm_info', values[0]);
                        return;
                    }
                }

                setTimeout(function() { input_el[0].focus(); }, 1);
                alert(errmsg);
            };

            input_el.blur(function() {
                if (! (input_el.autocomplete('widget')).is(':visible')) {
                    on_blur_timeout();
                }
            });
				

	});
	
};
window['init_municipality_autocomplete'] = init_municipality_autocomplete;
})();
