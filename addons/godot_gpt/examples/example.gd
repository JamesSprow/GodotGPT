extends Node2D



func _ready():
	var gpt: GPTRequest = $GPTRequest
	
	gpt.gpt_request_completed.connect(_on_gpt_request_completed)
	
	#gpt.gpt_request("this game is based tell me abt that")
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_http_request_completed)

	# Perform the HTTP request. The URL below returns a PNG image as of writing.
	var error = http_request.request("https://via.placeholder.com/512")
	if error != OK:
		push_error("An error occurred in the HTTP request.")


# Called when the HTTP request is completed.
func _http_request_completed(result, response_code, headers, body):
	var image = Image.new()
	var error = image.load_png_from_buffer(body)
	if error != OK:
		push_error("Couldn't load the image.")

	var texture = ImageTexture.new()
	texture.create_from_image(image)

	# Display the image in a TextureRect node.
	var texture_rect = $TextureRect
	add_child(texture_rect)
	texture_rect.texture = texture
	print("displaying texture")

func _on_gpt_request_completed(response_text: String):
	print(response_text)
