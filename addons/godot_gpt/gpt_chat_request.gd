extends GPTRequest
class_name GPTChatRequest

var history: Array[Dictionary] = []

func _request_completed_post_process(gpt_response: String) -> void:
	super(gpt_response)
	history.append({
		"role": "system",
		"content": gpt_response
	})

func clear_history() -> void:
	history = []

func gpt_chat_request(prompt: String) -> Error:
	var message: Dictionary = {
		"role": "user",
		"content": prompt
	}
	var messages: Array[Dictionary] = history.duplicate()
	messages.append(message)
	
	history.append(message)
	
	return gpt_completions_request(messages)
