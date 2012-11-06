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
		$('.copy_citations').live('click', function(eventObject){
			var obj = {};
			$('.citation_checkbox :checked').each(function(index, element) {
				var key = $(element).val();
				obj[key] = citations_manager.renderred_citations[key];
				alert(Object.keys(obj).length);
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
