#Handlers
#  @author Amol
#  @version 1.0
#  @data 1/16/15
#
#This file is designed to pass inputs from the commandline parser to the right databases


#-------------HANDLERS--------------------------------------------------------------------#

require 'rubygems'
require 'json'


#Function handles input from commandline parser for upload commands and passes
#the file-to-be-uploaded to the right cloud
#
#@param: file_name; string; the file name of the file to be uploaded
#@param: file_size; int; the size of the file to be uploaded
#@param: File; file; the file to be uploaded
#
#@return: bool; if everything runs as expected, returns true; else returns false (outputs stuff if the error is in the handler)

def upload_to_cloud_handler(file_path)

	if not file_path
		puts "There was an error: the file_path was nil"
		return false
	end

	if not File.zero?(file_path)
		puts "There was an error: the file_path returned an empty file"
		return false
	end

	file_size = File.size(file_path)

	file = File.open(file_path)

	most_filled_cloud = get_most_filled_cloud file_size

	Object.const_get(most_filled_cloud).file_put file_path, file

	# if most_filled_cloud
	# 	if most_filled_cloud == "Drive"
	# 	 	if not Google.file_put file_path, File
	# 	 		puts "There was an error putting the file in Google"
	# 	 		return false
	# 	 	end
	# 	elsif most_filled_cloud == "DropBox"
	# 		if not Dropbox.file_put file_path, File
	# 			puts "There was an error putting the file in DropBox"	
	# 			return false
	# 		end
	# 	end
	# else
	# 	puts "There was an error getting the right cloud"
	# 	return false
	# end

	return true
end


#Function handles input from commandline parser for download commands
#
#@param: fileName; string; the file name of the file to be downloaded
#@param: File; file; the file to be uploaded
#
#@return: bool; if everything runs as expected, returns true; else returns false (outputs stuff if the error is in the handler)

def download_from_cloud_handler(file_name)
	if not file_name
		puts "There was an error: the file_name was nil"
		return false
	end

	file_cloud = get_cloud_of_file_from_file_name file_name #GET CLOUD OF FILE FROM NAME

	if file_cloud == "Drive"
		File = Google.file_get file_name
	elsif file_cloud == "DropBox"
		File = Dropbox.file_get file_name
	end

	if not File
		puts "There was an error getting the file"
		return false
	else
		download_file File 
		return true
	end
end

#------------Helper Functions-----------------------------------------------------#

#Function gets the most filled registered cloud that fits within the filesize
#@param: file_size; int; the file_size parsing the databases

def get_most_filled_cloud(file_size)
	cloud_usage_list = condense.get_cloud_usage

	min_size = cloud_usage_list.select{|name, size| size > file_size}.min_by{ |name, size| size}[0]

	if not min_size
		#Call chunking stuff here
	else
		return min_size
	end
end