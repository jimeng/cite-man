var citations_manager = citations_manager || {};

citations_manager.setCookie = function(cookie_name, cookie_value, expiry_days) {
	var expires = new Date();
	expires.setDate(expires.getDate() + expiry_days);
	var c_value = escape(cookie_value) + ((exdays == null) ? "" : "; expires=" + expires.toUTCString());
	document.cookie = cookie_name + "=" + c_value;
};

citations_manager.getCookie = function(cookie_name) {
	var cookies = document.cookie.split(";");
	for (var i = 0; i < cookies.length; i++) {
	  var name = cookies[i].substr(0, cookies[i].indexOf("="));
	  var value = cookies[i].substr(cookies[i].indexOf("=") + 1);
	  name = name.replace(/^\s+|\s+$/g,"");
	  if (name == cookie_name) {
	    return unescape(value);
	  }
	}
};

/**
 * Converts the given data structure to a JSON string.
 * Argument: arr - The data structure that must be converted to JSON
 * Example: var json_string = array2json(['e', {pluribus: 'unum'}]);
 * 			var json = array2json({"success":"Sweet","failure":false,"empty_array":[],"numbers":[1,2,3],"info":{"name":"Binny","site":"http:\/\/www.openjs.com\/"}});
 * http://www.openjs.com/scripts/data/json_encode.php
 * BSD License
 * http://opensource.org/licenses/BSD-3-Clause
 */
function array2json(arr) {
    var parts = [];
    var is_list = (Object.prototype.toString.apply(arr) === '[object Array]');

    for(var key in arr) {
    	var value = arr[key];
        if(typeof value == "object") { //Custom handling for arrays
            if(is_list) parts.push(array2json(value)); /* :RECURSION: */
            else parts[key] = array2json(value); /* :RECURSION: */
        } else {
            var str = "";
            if(!is_list) str = '"' + key + '":';

            //Custom handling for multiple data types
            if(typeof value == "number") str += value; //Numbers
            else if(value === false) str += 'false'; //The booleans
            else if(value === true) str += 'true';
            else str += '"' + value + '"'; //All other things
            // :TODO: Is there any more datatype we should be in the lookout for? (Functions?)

            parts.push(str);
        }
    }
    var json = parts.join(",");
    
    if(is_list) return '[' + json + ']';//Return numerical JSON
    return '{' + json + '}';//Return associative JSON
}

citations_manager.renderred_citations = {};

citations_manager.oauthUsers = ['mendeley'];

citations_manager.init = function() {
	$(document).ready(function(){
		$('.copy_citations').attr('disabled', 'true')

		$('#new_source a').live('click', function(eventObject){
			var href = $(eventObject.target).attr('href');
			$.ajax(href, {
				success : function(data){
					$('#dialog').html(data);
					$('#dialog').dialog({
						title: "New Citations Source",
						width: 700,
						modal: true,
						draggable: true,
						autoOpen: true,
						buttons: [{
							text: "Save",
							click: function(button){
								var form_tag = $(button.target).closest('.ui-dialog').find('.source_form form');
								var url = $(form_tag).attr('action');
								var params = $(form_tag).serialize();
								$.ajax(url, {
									dataType: 'html',
									data: params,
									type: 'POST',
									success: function(html) {
										$('#sources_list').html(html);
										$('#items_list').html('');
										$('#dialog').dialog("close");
										$('#dialog').html('');
									}
								});
							}
						}, {
							text: "Cancel",
							click: function(){
								$('#dialog').dialog("close");
								$('#dialog').html('');
							}
						}]
					});
				}
			});
			return false;
		});		
		$('#preferences a').live('click', function(eventObject){
			var href = $(eventObject.target).attr('href');
			$.ajax(href, {
				success : function(data){
					$('#dialog').html(data);
					$('#dialog').dialog({
						title: "Preferences",
						width: 700,
						modal: true,
						draggable: true,
						autoOpen: true,
						buttons: [{
							text: "Save",
							click: function(button){
								var form_tag = $(button.target).closest('.ui-dialog').find('.preferences_form form');
								var url = $(form_tag).attr('action');
								var params = $(form_tag).serialize();
								$.ajax(url, {
									dataType: 'html',
									data: params,
									type: 'POST',
									success: function(html) {
										//$('#sources_list').html(html);
										//$('#items_list').html('');
										$('#dialog').dialog("close");
										$('#dialog').html('');
									}
								});
							}
						}, {
							text: "Cancel",
							click: function(){
								$('#dialog').dialog("close");
								$('#dialog').html('');
							}
						}]
					});
				}
			});
			return false;		
		});
		$('.source_name').live('click', function(eventObject){
			var citations_url = $(eventObject.target).siblings('.items_link').find('a').attr('href');
			$('.person_source').removeClass('selectedSource');
			$(eventObject.target).closest('.person_source').addClass('selectedSource')
			//alert("load_citations");
			var source_id = $(eventObject.target).siblings('.source_id').text();
			var details_url = $(eventObject.target).siblings('.show_link').find('a').attr('href');
			var oauth_url = $(eventObject.target).siblings('.oauth_url').find('a').attr('href');
			//alert('source_id == ' + source_id + "\n details_url == " + details_url + "\n oauth_url == " + oauth_url);
			citations_manager.load_source(source_id, details_url, citations_url, oauth_url);
		});
		$('.show_link a').live('click', function(eventObject){
			var href = $(eventObject.target).attr('href');
			$.ajax(href, {
				success : function(data){
					$('#dialog').html(data);
					return false;
				}
			});
			return false;
		});
		$('.revise_link a').live('click', function(eventObject){
			var href = $(eventObject.target).attr('href');
			$.ajax(href, {
				success : function(data){
					$('#dialog').html(data);
					var provider_name = $('#dialog').find('#provider-select-div select option:selected').val();
					var new_provider_details = $('#dialog').find('#provider-specifics form #' + provider_name);
					var old_provider_details = $('#dialog').find("#provider-details .provider");
					$('#provider-specifics form').append(old_provider_details);
					$('#provider-details').append(new_provider_details);
					$('#dialog').dialog({
						title: "New Citations Source",
						modal: true,
						draggable: true,
						autoOpen: true,
						buttons: [{
							text: "Update",
							click: function(button){
								var form_tag = $(button.target).closest('.ui-dialog').find('.source_form form');
								var url = $(form_tag).attr('action');
								var params = $(form_tag).serialize();
								$.ajax(url, {
									data: params,
									type: 'POST',
									success: function(html) {
										$('#sources_list').html(html);
										$('#items_list').html('');
										$('#dialog').dialog("close");
										$('#dialog').html('');
									}
								});
							}
						}, {
							text: "Cancel",
							click: function(){
								$('#dialog').dialog("close");
								$('#dialog').html('');
							}
						}]
					});
				}
			});
			return false;
		});
		$('.remove_link a').live('click', function(eventObject){
			var url = $(eventObject.target).attr('href');
			$('#dialog').html('Are you sure?');
			$('#dialog').dialog({
				title: "Delete Citations Source",
				modal: true,
				autoOpen: true,
				buttons: [{
					text: "OK",
					click: function(){
						$.ajax(url, {
							type: 'DELETE',
							success: function(html) {
								$('#sources_list').html(html);
								$('#items_list').html('');
								$('#dialog').dialog("close");
								$('#dialog').html('');
							}
						});
					}
				},{
					text: "Cancel",
					click: function(){
						$('#dialog').dialog("close");
						$('#dialog').html('');
					}
				}]
			});			
			return false;
			
		});
		$('#provider-select-div select').live('change', function(eventObject){
			var provider_name = $(eventObject.target).val();
			var new_provider_details = $('#provider-specifics form #' + provider_name);
			var old_provider_details = $("#provider-details .provider");
			$('#provider-specifics form').append(old_provider_details);
			$('#provider-details').append(new_provider_details);
		});
		$('.citation_checkbox :checkbox').live('change', function(eventObject){
			var check_count = $('.citation_checkbox :checked').length;
			if(check_count > 0) {
				$('.copy_citations').attr('disabled', 'false');
			} else {
				$('.copy_citations').attr('disabled', 'true');
			}
		});
		$('.cite_action').ajaxStop(function(){
			if(citations_manager.copy_count  && citations_manager.copy_count  > 0) {
				alert("citations_manager.copy_count == " + citations_manager.copy_count + "\ncitations_manager.new_count  == " + citations_manager.new_count + "\ncitations_manager.err_count  == " + citations_manager.err_count );
			}
			citations_manager.copy_count = -1;
			citations_manager.new_count = 0;
			citations_manager.err_count = 0;
		});
		$('.cite_action a').live('click', function(eventObject){
			eventObject.preventDefault();
			var url = $(eventObject.target).attr('href');
			citations_manager.new_count = 0;
			citations_manager.err_count = 0;
			citations_manager.copy_count = $('.citation_checkbox :checked').size();
			$('.citation_checkbox :checked').each(function(index, element) {
				var key = $(element).val();
				var val = citations_manager.renderred_citations[key];
				var token = $('#clipboard_form').find('input[name="authenticity_token"]').val();
				var params = {'citation_id' : key, 'citation' : array2json(val), 'authenticity_token' : token};
				$.ajax(url, {
					type : 'POST',
					data : params,
					dataType : 'json',
					success : function(jsObj){
						citations_manager.new_count++;
					},
					error : function(jqXHR, textStatus, errorThrown){
						alert("Error processing click: " + textStatus + "\n code: " + errorThrown);
						citations_manager.err_count++;
					}

				});
			});
			alert('add ' + new_count + ' citations to clipboard (' + err_count + ' errors).')
			
			return false;
		});
		$('#show_clipboard').find('a').live('click', function(eventObject) {
			eventObject.preventDefault();
			var url = $(eventObject.target).attr('href');
			$.ajax(url, {
				success : function(data){
					$('#clipboard').html(data);
					$('#clipboard').dialog({
						title: "Clipboard",
						width: 700,
						modal: true,
						draggable: true,
						autoOpen: true,
						buttons: [{
							text: "Paste",
								click: function(button){
									$('#clipboard').dialog("close");
									$('#clipboard').html('');
								}
						}, {
							text: "Close",
								click: function(){
									$('#clipboard').dialog("close");
									$('#clipboard').html('');
								}
						}]
					});
				}
			});			
			return false;
		});
	});
};

citations_manager.close_dialog = function() {
	$('#dialog').dialog("close");
	$('#dialog').html('');
};

citations_manager.load_source = function(source_id, details_url, citations_url, oauth_url) {
	//alert('getting citations');
	if(citations_url) {
		//alert('requesting html');
		$.ajax(citations_url, {
			dataType: 'html',
			success: function(html) {
				$('#items_list').html(html);
				alert('citations_manager.renderred_citations.length == ' + Object.keys(citations_manager.renderred_citations).length);
				$('.copy_citations').attr('disabled', 'true')

			},
			statusCode: {
				401: function(jqXHR, textStatus, errorThrown) {
					
					if(oauth_url && oauth_url !== '#') {
						
						$.ajax(oauth_url, {
							dataType: 'json',
							success : function(json) {
								if(json && json.authorize_url) {
									var iframe = '<iframe src="' + json.authorize_url + '" width="100%" height="360">mendeley dialog</iframe>'
									$('#dialog').html(iframe);
									$('#dialog').dialog({
										title: "Mendeley Authorization",
										modal: true,
										draggable: true,
										autoOpen: true,
										width: 700,
										height: 560,
										buttons: [{
											text: "Close",
												click: function(){
												$('#dialog').dialog("close");
												$('#dialog').html('');
											}
										}]
									});
								} else if(json && json.error) {
									$('#messages').html(json.error);
									$('#messages').show(4000, function() {
										$('#messages').hide(8000, function(){
											$('#messages').html('');
										});
									});
								}
							}
						});
					
					} else {
						$('#items_list').html("Error processing click: " + textStatus + "\n code: " + errorThrown + "\n oauth_url: " + oauth_url);
					}
				},
			},
			error: function(jqXHR, textStatus, errorThrown){
				$('#items_list').html("Error processing click: " + textStatus + "\n code: " + errorThrown);
			}
		})
	} else if(details_url) {
		//alert('requesting json');
		$.ajax(details_url, {
			dataType: 'json',

			success: function(jsObj) {
				var str = '<h3>Need a connector for this source</h3>\n<dl>\n';
				for(key in jsObj) {
					str += '<td>' + key + '</dt>\n<dd>' + jsObj[key] + '</dd>\n';
				}
				str += '</dl>\n';
								
				$('#items_list').html(str);
			},
			error: function(jqXHR, textStatus, errorThrown){
				$('#items_list').html("Error processing click: " + textStatus + "\n code: " + errorThrown);
			}
		})
	} else {
		//alert('no request');
		$('#items_list').html('');
	}

};

citations_manager.init();
