# This script extends the HTTPRequest node and is designed to interact with OpenAI's Image API.
# It manages the process of sending a prompt to the API, receiving an image URL in response, and then fetching the actual image.

extends HTTPRequest
# Assign a custom class name "OpenAIImageRequest" for easier reference and instantiation in other scripts.
class_name OpenAIImageRequest

# Exported variables for configuring the image request.
@export var n: int = 1 # Specifies the number of images to generate per request.
@export var size: String = "256x256" # Specifies the resolution of the generated images.
@export var api_key: String # OpenAI API authentication key.
@export var api_url: String = "https://api.openai.com/v1/images/generations" # URL endpoint for the image generation API.

# A separate HTTPRequest instance for fetching the actual image from the provided URL.
var image_http_request: HTTPRequest

## Signals for communicating with external nodes.
signal image_request_completed ## Emitted when an image is successfully retrieved. Passes the Image object.
signal image_request_failed ## Emitted in case of any errors during the image generation or retrieval process.

# Function called when the node is added to the scene. It initializes properties and sets up signal connections.
func _ready() -> void:
	# Connect the built-in signal of HTTPRequest to our custom handler.
	request_completed.connect(on_request_completed)
	
	# Instantiate the image_http_request object and add it as a child.
	image_http_request = HTTPRequest.new()
	add_child(image_http_request)
	# Connect its built-in signal to our custom handler.
	image_http_request.request_completed.connect(_image_url_request_completed)

## Callback function that's triggered when the initial API request to OpenAI completes.
## If successful, it initiates another request to fetch the image from the provided URL.
func on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var json: JSON = JSON.new()
	# Parse the received response body.
	var error: Error = json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	
	var failed: bool = false
	# Check for errors during parsing.
	if error:
		failed = true
	# Ensure the parsed response is a dictionary.
	if not response is Dictionary:
		failed = true
	# Check if the response contains an error field.
	if not failed and response.has("error"):
		printerr("image request error: ", response["error"])
		failed = true
	if failed:
		# If any errors occurred, emit the "image_request_failed" signal.
		image_request_failed.emit()
		return
	
	# Extract the URL of the generated image from the parsed data.
	var image_url: String = response.data[0].url
	
	# Send an HTTP request to fetch the image using the provided URL.
	error = image_http_request.request(image_url)
	if error != OK:
		push_error("An error occurred requesting the generated image.")

## Function to send an image generation request to OpenAI using the given prompt.
func image_request(prompt: String):
	# Structure the request body with the specified parameters.
	var body = JSON.new().stringify({
		"prompt": prompt,
		"n": n,
		"size": size
	})
	# Make a POST request to the OpenAI API endpoint with the structured body.
	var error: Error = request(api_url, ["Content-Type: application/json", "Authorization: Bearer " + api_key], HTTPClient.METHOD_POST, body)
	return error

## Callback function that handles the completion of the image URL fetch request.
func _image_url_request_completed(result, response_code, headers, body):
	# Create a new Image object and load the image data into it.
	var image: Image = Image.new()
	var error: Error = image.load_png_from_buffer(body)
	if error != OK:
		# If loading fails, emit the "image_request_failed" signal.
		image_request_failed.emit()
		# Optional: Uncomment the below line to also display an error message.
		#push_error("Couldn't load the image.")
	
	# If successful, emit the "image_request_completed" signal with the loaded Image.
	image_request_completed.emit(image)
	# Optional: Uncomment the below line to print a success message.
	#print("Successfully acquired generated image")
