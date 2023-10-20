extends HTTPRequest
class_name GPTRequest

@export var temperature: float = 0.5
@export var max_tokens: int = 1024
@export var model: String = "gpt-3.5-turbo"
@export var api_key: String
@export var api_url: String = "https://api.openai.com/v1/chat/completions"

var history: Array[Dictionary] = []

signal gpt_request_completed(gpt_text: String)
signal gpt_request_failed

func _ready() -> void:
	request_completed.connect(on_request_completed)

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
		printerr("gpt request error: ", response["error"])
		failed = true
	if failed:
		gpt_request_failed.emit()
		return

	var gpt_text: String = response.choices[0].message.content
	
	history.append({
		"role": "system",
		"content": gpt_text
	})
	
	gpt_request_completed.emit(gpt_text)

func clear_history() -> void:
	history = []

func gpt_request(prompt: String) -> Error:
	var messages: Array[Dictionary] = [
		{
			"role": "user",
			"content": prompt
		}
	]
	return gpt_completions_request(messages)

func gpt_chat_request(prompt: String) -> Error:
	var messages: Array[Dictionary] = history.duplicate()
	messages.append({
		"role": "user",
		"content": prompt
	})
	return gpt_completions_request(messages)

func gpt_completions_request(messages: Array[Dictionary]) -> Error:
	var body = JSON.new().stringify({
		"messages": messages,
		"temperature": temperature,
		"max_tokens": max_tokens,
		"model": model
	})
	var error: Error = request(api_url, ["Content-Type: application/json", "Authorization: Bearer " + api_key], HTTPClient.METHOD_POST, body)
	return error
