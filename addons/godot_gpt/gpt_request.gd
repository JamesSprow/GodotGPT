# This script extends the HTTPRequest node and defines functionality for making requests to the GPT API.
extends HTTPRequest
# Define a custom class name "GPTRequest" for easy reference and instantiation in other scripts.
class_name GPTRequest

## Wrapper class that provides an interface for OpenAI ChatGPT completions requests

# Exported variables for configuration of the GPT request parameters.
## Value between 0.0 and 1.0, higher values mean more random responses
@export var temperature: float = 0.5
## Maximum amount of tokens in request
@export var max_tokens: int = 1024
## Which ChatGPT model to use
@export var model: String = "gpt-3.5-turbo"
## API key used in request to OpenAI ChatGPT
@export var api_key: String
## URL endpoint to send requests to
@export var api_url: String = "https://api.openai.com/v1/chat/completions"

# Define signals to notify other nodes when a GPT request is completed or failed.
## Emitted when this node receives a valid response from ChatGPT
signal gpt_request_completed(gpt_text: String)
## Emitted when this node receives an invalid response from ChatGPT
signal gpt_request_failed

# Function called when the node is added to the scene. Sets up signal connections.
func _ready() -> void:
	# Connect the built-in signal of HTTPRequest to our custom handler.
	request_completed.connect(_on_request_completed)

# Callback function to handle the completion of the HTTP request.
func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var json: JSON = JSON.new()
	# Parse the received response body.
	var error: Error = json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	
	var failed: bool = false
	# Check for errors during parsing.
	if error:
		failed = true
	# Check if the parsed response is a dictionary.
	if not response is Dictionary:
		failed = true
	# Check if the response contains an error field.
	if not failed and response.has("error"):
		printerr("gpt request error: ", response["error"])
		failed = true
	# If any errors occurred, emit the "gpt_request_failed" signal.
	if failed:
		gpt_request_failed.emit()
		return

	# Extract the GPT response text from the parsed data.
	var gpt_text: String = response.choices[0].message.content
	# Call a function for any post-processing needed on the GPT response.
	_request_completed_post_process(gpt_text)
	
	# Emit the "gpt_request_completed" signal with the extracted text.
	gpt_request_completed.emit(gpt_text)

# Placeholder function to handle any post-processing on the received GPT response.
# Currently does nothing but can be filled in if needed.
func _request_completed_post_process(gpt_response: String) -> void:
	pass

## Takes a prompt to send to ChatGPT and sends a request to ChatGPT
func gpt_request(prompt: String) -> Error:
	# Create the message structure for the request.
	var messages: Array[Dictionary] = [
		{
			"role": "user",
			"content": prompt
		}
	]
	# Call the function to make the completions request.
	return gpt_completions_request(messages)

## Function to send a completions request to ChatGPT
func gpt_completions_request(messages: Array[Dictionary]) -> Error:
	# Structure the request body with the specified parameters.
	var body = JSON.new().stringify({
		"messages": messages,
		"temperature": temperature,
		"max_tokens": max_tokens,
		"model": model
	})
	# Make the HTTP POST request to the GPT API endpoint.
	var error: Error = request(api_url, ["Content-Type: application/json", "Authorization: Bearer " + api_key], HTTPClient.METHOD_POST, body)
	# Return any error that might have occurred.
	return error
