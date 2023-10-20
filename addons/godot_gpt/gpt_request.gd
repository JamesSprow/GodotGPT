extends HTTPRequest
class_name GPTRequest

@export var temperature: float = 0.5
@export var max_tokens: int = 1024
@export var model: String = "gpt-3.5-turbo"
@export var api_key: String
@export var api_url: String = "https://api.openai.com/v1/chat/completions"

signal gpt_request_completed(gpt_text: String)
signal gpt_request_failed

func _ready() -> void:
	request_completed.connect(on_request_completed)

func on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	printt(result, response_code, headers, body)
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

	print("response: ", response)
	var gpt_text: String = response.choices[0].message.content
	gpt_request_completed.emit(gpt_text)

func gpt_request(prompt: String, _temperature: float = temperature, _max_tokens: int = max_tokens, _model: String = model) -> Error:
	var body = JSON.new().stringify({
		"messages" : [
		{
			"role": "user",
			"content": prompt
		}
			],
		"temperature": temperature,
		"max_tokens": max_tokens,
		"model": _model
	})
	var error: Error = request(api_url, ["Content-Type: application/json", "Authorization: Bearer " + api_key], HTTPClient.METHOD_POST, body)
	return error
