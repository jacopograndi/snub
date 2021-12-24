extends Node


func load_parse_json (path):
	var data_file = File.new()
	if data_file.open(path, File.READ) != OK:
		return
	var data_text = data_file.get_as_text()
	data_file.close()
	var data_parse = JSON.parse(data_text)
	if data_parse.error != OK:
		return
	var data = data_parse.result
	return data

func parse_dir (path : String, extension : String = ""):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin(true)
	var file = dir.get_next()
	while file != "":
		if file.ends_with(extension):
			files.append(file)
		file = dir.get_next()
	return files
