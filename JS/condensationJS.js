/*
	Add file takes a file object and puts a file label in the list

	@Param: fileInfo; obj; object that contains info necessary to add a new event.
		fileInfo parameters include: 
			name
			size
			chunks
*/
function addFile(fileInfo)
{
	var $FileObj = $("#FileTemplate").clone();

	$FileObj.attr("id","");

	if(fileInfo.name)
		$FileObj.find(".file-name").html(fileInfo.name);

	if(fileInfo.size)
		$FileObj.find(".file-size").html(fileInfo.size);

	if(fileInfo.chunks)
		$FileObj.find(".file-chunk").html(fileInfo.chunk);

	$(".file-list-container").append($FileObj);
}




function updateCloudData(totalCloudAmount, filledCloudAmount)
{
	var percentFilled = filledCloudAmount/totalCloudAmount * 100;
	var amountLeft = totalCloudAmount - filledCloudAmount;

	var currentUnit = "mb";

	percentFilledString = percentFilled + "%";

	$(".space-fill").css({"width":percentFilledString});

	if(amountLeft > 1024)
	{
		amountLeft = amountLeft/1024;
		currentUnit = "gb";
	}


	$(".number-amount-left").html(amountLeft + " " + currentUnit); 
}

$("#UploadButton").click(function() {
	$('#InputFile').click();
});

$("#AddCloud").click(function(){
	$(".new-cloud-panel").fadeIn();
});

$(".new-cloud-cover").click(function(){
	$(".new-cloud-panel").fadeOut();
});

$(".Google").click(function(){
	gapi.auth.authorize(
		           {'client_id': CLIENT_ID, 'scope': SCOPES, 'immediate': false},
		           login);
});

$(".Dropbox").click(function(){
	//Call DB auth
});

$(".OneDrive").click(function(){
	//Call OneDrive auth
});

document.getElementById('InputFile').addEventListener('change', handleFileSelect, false);


//This defines what to do with the files collected - namely, pass them to ruby
function handleFileSelect(evt) 
{
    var files = evt.target.files; // FileList object
    Save(true, files[0], "test1");
}

//Initialization stuff
//Call list function in loops here
