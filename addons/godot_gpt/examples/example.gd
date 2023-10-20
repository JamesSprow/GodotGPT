extends Control

@export var gpt: GPTChatRequest
@export var chat_text: RichTextLabel
@export var prompt_input: TextEdit

func _ready():
	gpt.gpt_request_completed.connect(_on_gpt_request_completed)

func _on_gpt_request_completed(response_text: String):
	add_text_to_chat(response_text, "ChatGPT")

func send_chat_request() -> void:
	var prompt: String = prompt_input.text
	prompt_input.text = ""
	
	# no need to send a request if the prompt is empty
	if prompt == "":
		return
	
	gpt.gpt_chat_request(prompt)
	add_text_to_chat(prompt, "Me")

func add_text_to_chat(text: String, from: String) -> void:
	chat_text.text += from + ": " + text
	if not chat_text.text.ends_with("\n"):
		chat_text.text += "\n"

func _on_button_pressed():
	send_chat_request()

func _on_prompt_submitted() -> void:
	send_chat_request()
