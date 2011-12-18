(function() {
var $ = jQuery
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
					minLength: 1
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
                if (info && info['chkid'] && info['value'] && info['value'] === value) {
                    shadow_el[0].value = info['chkid'];
                    return;
                }
                 
                testvalue = string_ci_ai(value);
                if (cache.content) {
                    var values = $.grep(cache.content, function(value) {
                        return string_ci_ai(value['value']) === testvalue;
                    });
                    if (values.length === 1) {
                        shadow_el[0].value = values[0]['chkid'];
                        input_el.data('cm_info', values[0])
                        return
                    }
                }

                this.focus();
                alert(errmsg);
            }

            input_el.blur(function() {
                setTimeout(on_blur_timeout, 100);
            });
				

	});
	
};
window['init_municipality_autocomplete'] = init_municipality_autocomplete;
})();
