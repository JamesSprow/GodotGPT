extends HTTPRequest
class_name OpenAIImageRequest

@export var n: int = 1 #amount of images to generate
@export var size: String = "256x256" #resolution of image
@export var api_key: String #OpenAI API Key
@export var api_url: String = "https://api.openai.com/v1/images/generations" #url to send requests to

var image_http_request: HTTPRequest

#signals for external use
signal image_request_completed(image: Image) #emitted when image is ready, and passes an Image object
signal image_request_failed #emitted when generating an image fails

func _ready() -> void:
	request_completed.connect(on_request_completed)
	
	image_http_request = HTTPRequest.new()
	add_child(image_http_request)
	image_http_request.request_completed.connect(_image_url_request_completed)

#called when the OpenAI API request is completed, and requests the image from received URL
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
	
	#sends request for image given URL
	error = image_http_request.request(image_url)
	if error != OK:
		push_error("An error occurred requesting the generated image.")

#send an api request to OpenAI with the prompt for image
func image_request(prompt: String):
	var body = JSON.new().stringify({
		"prompt": prompt,
		"n": n, 
		"size": size 
	})
	var error: Error = request(api_url, ["Content-Type: application/json", "Authorization: Bearer " + api_key], HTTPClient.METHOD_POST, body)
	return error

# called when the request for the image is completed
func _image_url_request_completed(result, response_code, headers, body):
	var image: Image = Image.new()
	var error: Error = image.load_png_from_buffer(body)
	if error != OK:
		image_request_failed.emit()
		#push_error("Couldn't load the image.")
	
	image_request_completed.emit(image)
	#print("Successfully acquired generated image")
