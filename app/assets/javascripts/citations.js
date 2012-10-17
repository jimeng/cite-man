var citations_manager = citations_manager || {};

citations_manager.init = function() {
	$(document).ready(function(){
		$('#new_source a').live('click', function(eventObject){
			var href = $(eventObject.target).attr('href');
			$.ajax(href, {
				success : function(data){
					$('#dialog').html(data);
					$('#dialog').dialog({
						title: "New Citations Source",
						width: 500,
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
						width: 600,
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
			var link_target = $(eventObject.target).siblings('.items_link_target').text();
			var citations_url = $(eventObject.target).siblings('.items_link').find('a').attr('href');
			if("frame" == link_target) {
				window.location = citations_url;
			} else {}
				$('.person_source').removeClass('selectedSource');
				$(eventObject.target).closest('.person_source').addClass('selectedSource')

				var source_id = $(eventObject.target).siblings('.source_id').text();
				var details_url = $(eventObject.target).siblings('.show_link').find('a').attr('href');

				citations_manager.load_source(source_id, details_url, citations_url);
			
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
	});
};

citations_manager.load_source = function(source_id, details_url, citations_url) {

	if(citations_url) {
		$.ajax(citations_url, {
			dataType: 'html',

			success: function(html) {
				$('#items_list').html(html);
			},
			error: function(jqXHR, textStatus, errorThrown){
				$('#items_list').html("Error processing click: " + textStatus + "\n code: " + errorThrown);
			}
		})
	} else if(details_url) {
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
		$('#items_list').html('');
	}

};

citations_manager.init();
