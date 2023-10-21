# This script extends the Control node and manages interactions with the OpenAI Image API to generate and display images.

extends Control

# Exported variable to store the API key used to interact with the OpenAI Image API.
@export var api_key: String

# Exported group of variables that are considered "internal".
# These are likely used for editor-only settings and adjustments.
@export_group("internal")
# Reference to the OpenAIImageRequest object which handles interactions with the OpenAI Image API.
@export var image_request: OpenAIImageRequest
# Reference to the TextureRect node where generated images will be displayed.
@export var texture_rect: TextureRect
# Reference to the control used for entering and submitting prompts.
@export var prompt_input: Control

# State variable to check if the system is ready to send a new image request.
var state_ready: bool = true

# Function called when the node is added to the scene. Initializes properties and sets up signal connections.
func _ready():
	# Connect the signals from OpenAIImageRequest to callback functions in this script.
	# This allows for handling the results of image requests.
	image_request.image_request_completed.connect(_on_image_request_completed)
	image_request.image_request_failed.connect(_on_image_request_failed)

## Function to send an image request based on a given prompt.
func prompt(prompt: String):
	# Set the API key for the OpenAIImageRequest object.
	image_request.api_key = api_key
	
	image_request.image_request(prompt)

## Callback function for when an image request is successfully completed.
func _on_image_request_completed(image: Image):
	# Create a new ImageTexture from the received Image.
	var texture: ImageTexture = ImageTexture.new()
	texture = texture.create_from_image(image)
	# Set the generated texture to the TextureRect node for display.
	texture_rect.texture = texture
	
	# Update the state to indicate that the system is ready for a new request.
	state_ready = true
	# Disable the submit button in the input control.
	prompt_input.set_button_state(false)

## Callback function for when an image request fails.
func _on_image_request_failed():
	# Disable the submit button in the input control to indicate failure.
	prompt_input.set_button_state(false)
	state_ready = true

## Callback function to handle when a prompt is submitted using the input control.
func _on_prompt_input_prompt_submitted(prompt: String):
	# If the system isn't ready (e.g., a request is still in progress), return without doing anything.
	if !state_ready:
		return
	# Update the state to indicate that the system is busy.
	state_ready = false
	# Enable the submit button in the input control.
	prompt_input.set_button_state(true)
	# Send the entered prompt as an image request.
	prompt(prompt)
