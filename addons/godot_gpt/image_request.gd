extends HTTPRequest
class_name ImageRequest

@export var n: int = 1
@export var size: String = "256x256"
@export var api_key: String
@export var api_url: String = "https://api.openai.com/v1/images/generations"

var image_http_request: HTTPRequest

signal image_request_completed
signal image_request_failed

func _ready() -> void:
	request_completed.connect(on_request_completed)
	
	image_http_request = HTTPRequest.new()
	add_child(image_http_request)
	image_http_request.request_completed.connect(_image_url_request_completed)

func on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var json: JSON = JSON.new()
	var error: Error = json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	
	var failed: bool = false
	if error:
		failed = true
	if not response is Dictionary:
		failed = true
	if not failed and response.has("error"):
		printerr("image request error: ", response["error"])
		failed = true
	if failed:
		image_request_failed.emit()
		return
	
	var image_url: String = response.data[0].url
	
	# Perform the HTTP request. The URL below returns a PNG image as of writing.
	#print("Requesting image from url: ", image_url)
	error = image_http_request.request(image_url)
	if error != OK:
		push_error("An error occurred requesting the generated image.")

func image_request(prompt: String):
	var body = JSON.new().stringify({
		"prompt": prompt,
		"n": n,
		"size": size 
	})
	var error: Error = request(api_url, ["Content-Type: application/json", "Authorization: Bearer " + api_key], HTTPClient.METHOD_POST, body)
	return error

# Called when the image url request is completed.
func _image_url_request_completed(result, response_code, headers, body):
	var image = Image.new()
	var error = image.load_png_from_buffer(body)
	if error != OK:
		push_error("Couldn't load the image.")
	
	image_request_completed.emit(image)
