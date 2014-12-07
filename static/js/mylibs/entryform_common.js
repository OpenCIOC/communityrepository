if (typeof(entryform) == 'undefined') {
	entryform = {};
}


function create_checklist_onbefore_fns ($, field, added_values, add_new_value) {
	cache_register_onbeforeunload(function(cache) {
		cache[field + '_added'] = added_values;
	});
	cache_register_onbeforerestorevalues(function (cache) {
		var array = cache[field + '_added'];
		if (!array) {
			return;
		}
		$.each(array, function (index, item) {
			add_new_value(item.chkid, item.display, "");
		});
	});
}

function basic_chk_add_html($, field) {
	return function (chkid, display) {
		$('#' + field + '_existing_add_table').
			append($('<tr>').
				append($('<td>').
					append($('<input>').
						prop({
							id: field + '_ID_' + chkid,
							type: 'checkbox',
							checked: true,
							defaultChecked: true,
							name: field + '_ID',
							value: chkid 
							})
					).
					append(document.createTextNode(' ' + display))
				).
				append($('<td>').
					append($('<input>').
						prop({
							id: field + '_NOTES_' + chkid,
							name: field + '_NOTES_' + chkid,
							size: entryform.chk_notes_size,
							maxlength: entryform.chk_notes_maxlen
							})
					)
				)
			);
	};
}

function init_autocomplete_checklist($, options) {
	var field = options.field;
	var source = options.source;
	options.minLength = options.minLength || 1;
	options.delay = options.delay || 300;
	options.add_new_html = options.add_new_html || basic_chk_add_html($, field);
	options.match_prop = options.match_prop || 'value';
	
	var added_values = options.added_values || [];
	var add_new_value = function(chkid, display) {
		//console.log('add');
		var existing_chk = document.getElementById(field + '_ID_' + chkid);
		if (existing_chk) {
			existing_chk.checked = true;
			//already exists
			return;
		}


		added_values.push({chkid: chkid, display: display});

		options.add_new_html(chkid, display);

	}

	create_checklist_onbefore_fns($, field, added_values, add_new_value);

	var newfield = $('#NEW_' + field);

	var cache = {};

	var after_add = function(evt) {
		//console.log('after add');
		newfield.
			data({chkid: "", display: ""}).
			prop('value', "").
			focus();

		$('#' + field + '_error').hide('slow', function() {
				$(this).remove();
		});
	}

	var look_for_value = null;
	var source_fn = null;
	(function (source) {
		var array, url;
		if ( $.isArray(source) ) {
			array = source;
			source_fn = function( request, response ) {
				// escape regex characters
				var matcher = new RegExp( $.ui.autocomplete.escapeRegex(string_ci_ai(request.term)));
				response( $.grep( array, function(value) {
					return matcher.test( string_ci_ai(value[options.match_prop] || value));
				}) );
			};
			look_for_value = function(invalue, response) {
				var inputvalue = string_ci_ai(invalue);
				var values = $.grep(array, function(value) {
							return string_ci_ai(string_ci_ai(value[options.match_prop] || value)) === inputvalue;
						});
				if (values.length === 1) {
					response(values[0]);
					return true;
				} else {
					response();
				}
				
			}
		} else if ( typeof source === "string" ) {
			url = source;
			source_fn = create_caching_source_fn($, url, cache, options.match_prop),
			look_for_value = function(invalue, response, dont_source) {
				var inputvalue = string_ci_ai(invalue);
				var content = cache.content;
				if (cache.content) {
					var values = $.grep(cache.content, function(value) {
								return string_ci_ai(value[options.match_prop]) === inputvalue;
							});
					if (values.length === 1) {
						response(values[0]);
						return;
					}
				}
				if (dont_source || string_ci_ai(cache.term || "") === inputvalue) {
					response();
					return;
				}

				source_fn({term: inputvalue}, function(data) {
							look_for_value(invalue, response, true);
						});
			};
		} else {
			source_fn = source;
			look_for_value = options.look_for_fn;
		}
	})(source);

	var do_show_error = function() {
		if ($("#" + field + "_error").length === 0) {
			//console.log('error');
			$('#' + field + '_new_input_table').before($('<div class="ui-widget clearfix" style="margin: 0.25em;">\
                <div class="ui-state-error error-field-wrapper"> \
                <span class="ui-icon ui-icon-alert error-notice-icon"></span>[MSG]\
                </div>\
            </div>'.replace('[MSG]', $('<div>').text(options.not_found_msg || 'Not Found').html())).
					hide().
					prop('id', field + '_error'));
					
			$("#" + field + "_error").show('slow');
		}
	}

	var on_add_click = function(evt) {
		//console.log('onclick');
		var chkid = newfield.data('chkid');
		var display = newfield.data('display');
		var newfieldval = newfield[0].value;
		if (chkid && display && display == newfieldval) {
			add_new_value(chkid, display);
			after_add();
			return;

		}
		look_for_value(newfield[0].value, function(item) {
			if (item) {
				add_new_value(item.chkid, item[options.match_prop]);
				after_add();
			} else {
				do_show_error();
			}
		});

	};
	var add_button = $("#add_" + field).click(on_add_click);

	newfield.
		autocomplete({
			focus:function(e,ui) {
				return false;
			},
			source: source_fn,
			minLength: options.minLength,
			delay: options.delay,
			select: function(evt, ui) {
				newfield.data({
					chkid: ui.item.chkid,
					display: ui.item[options.match_prop]
					});
			}
		}).
		keypress(function (evt) {
			if (evt.keyCode == '13') {
				evt.preventDefault();
				newfield.autocomplete('close');
				add_button.trigger('click');
			}
		});
}

function only_items_chk_add_html($, field, before_add) {
	return function (chkid, display) {
		if (before_add) {
			before_add();
		}
		$('#' + field + '_existing_add_container').
			append($('<input>').
				prop({
					id: field + '_ID_' + chkid,
					type: 'checkbox',
					checked: true,
					defaultChecked: true,
					name: field + '_ID',
					value: chkid 
					})
			).
			append('&nbsp;').
			append(document.createTextNode(display)).
			append(' ; ');
	};
}

function init_check_for_autochecklist (confirm_string) {
	var $ = jQuery;

	var go_to_unadded_check = function(evt) {
		var check_add = $(this).data('jump_location');
		var input = document.getElementById(check_add);
		if (input) {
			input.scrollIntoView(true);
		}
	};

	var create_list_item = function() {
		return $('<li>').
			append($('<span>').
			data('jump_location', this.id).
			addClass('UnaddedChecklistJump SimulateLink').
			append($(this).parentsUntil('td[data-field-display-name]').parent().data('fieldDisplayName')));
	}

	var entry_form_items = $('input[id^=NEW_]');
	if (!entry_form_items.length) {
		// no elements, do nothing
		return;
	}
	$('#EntryForm').submit(function (event) {
			var fields = entry_form_items.map(function () { return this.value ? this : null; });
			if (fields.length && !event.isDefaultPrevented()) {
				var docontinue = confirm(confirm_string);
				if (!docontinue) {
					event.preventDefault();
					$("#SUBMIT_BUTTON").prop('disabled',false);

					var error_box = $('#unadded_checklist_error_box');
					var error_list = $('#unadded_checklist_error_list');
					var error_list_visible = error_box.is(':visible');

					if (error_list_visible) {
						error_list.children('ul:first').hide('slow',
							function() {
								$(this).remove();
							});
					}
					var ul = $("<ul>");

					if (error_list_visible) {
						ul.hide()
					}


					error_list.append(ul);
					

					$.each( fields.map(create_list_item), 
							function () { ul.append(this); });

					if (error_list_visible) {
						ul.show('slow');
					} else {
						error_box.show('slow');
					}

					return;

				}
				return;
			} else if (event.isDefaultPrevented()) {
				var error_box = $('#unadded_checklist_error_box');
				var error_list = $('#unadded_checklist_error_list');

				error_box.hide('slow',
						function() {
							error_list.children().remove();
						});
			}
		});

	$(".UnaddedChecklistJump").live('click', go_to_unadded_check);
	

}

