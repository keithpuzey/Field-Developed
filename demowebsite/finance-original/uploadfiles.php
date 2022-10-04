<html lang="en">
<head>
<Title>File Upload Tutorial</Title>
</head>
<body>
 
	<form action="uploadfiles.php" method="post" enctype="multipart/form-data">
	<p>
	<label for="my_upload">Select the file to upload:</label>
	<input id="my_upload" name="my_upload" type="file">
	</p>
	<input type="submit" value="Upload Now">
	</form>
</body>
</html>
<?php 
if ($_SERVER['REQUEST_METHOD'] == 'POST') 
{
  if (is_uploaded_file($_FILES['my_upload']['tmp_name'])) 
  { 
  	//First, Validate the file name
  	if(empty($_FILES['my_upload']['name']))
  	{
  		echo " File name is empty! ";
  		exit;
  	}

  	$upload_file_name = $_FILES['my_upload']['name'];
  	//Too long file name?
  	if(strlen ($upload_file_name)>100)
  	{
  		echo " too long file name ";
  		exit;
  	}

  	//replace any non-alpha-numeric cracters in th file name
  	$upload_file_name = preg_replace("/[^A-Za-z0-9 \.\-_]/", '', $upload_file_name);

  	//set a limit to the file upload size
  	if ($_FILES['my_upload']['size'] > 1000000) 
  	{
		echo " too big file ";
  		exit;        
    }

    //Save the file
    $dest=__DIR__.'/uploads/'.$upload_file_name;
    if (move_uploaded_file($_FILES['my_upload']['tmp_name'], $dest)) 
    {
    	echo 'File Has Been Uploaded !';
    }
  }
}