jQuery.fn.tableToCSV = function() {
    
    var clean_text = function(text){
        text = text.replace(/"/g, '""');
        return '"'+text+'"';
    };
    
	jQuery(this).each(function(){
			var table = jQuery(this);
			var caption = jQuery(this).find('caption').text();
			var title = [];
			var rows = [];

			jQuery(this).find('tr').each(function(){
				var data = [];
				jQuery(this).find('th').each(function(){
                    var text = clean_text(jQuery(this).text());
					title.push(text);
					});
				jQuery(this).find('td').each(function(){
                    var text = clean_text(jQuery(this).html());
					data.push(text);
					});
				data = data.join(",");
				rows.push(data);
				});
			title = title.join(",");
			rows = rows.join("\n");

			var csv = title + rows;
			var uri = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csv);
			var download_link = document.createElement('a');
			download_link.href = uri;
			//var ts = new Date().getTime();
			
			var ts  = jQuery('.download_import_data').attr('data-download');
			//var ts = "report";
			
			if(caption==""){
				download_link.download = ts+".csv";
			} else {
				download_link.download = caption+"-"+ts+".csv";
			}
			document.body.appendChild(download_link);
			download_link.click();
			document.body.removeChild(download_link);
	});
    
};
