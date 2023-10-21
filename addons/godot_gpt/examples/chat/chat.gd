extends Control

@export var gpt: GPTChatRequest
@export var chat_history_scroll: ScrollContainer
@export var chat_history: VBoxContainer
@export var prompt_input: Control

@export var chat_entry_scene: PackedScene

func _ready():
	gpt.gpt_request_completed.connect(_on_gpt_request_completed)
	prompt_input.prompt_submitted.connect(send_chat_request)

func _on_gpt_request_completed(response_text: String):
	add_text_to_chat("ChatGPT", response_text)
	prompt_input.set_button_state(false)

func send_chat_request(prompt: String) -> void:
	# no need to send a request if the prompt is empty
	if prompt == "":
		return
	
	add_text_to_chat("Me", prompt)
	var err: Error = gpt.gpt_chat_request(prompt)
	
	if err:
		add_text_to_chat("Error", "Failed to send request to ChatGPT API")
	else:
		prompt_input.set_button_state(true)

func add_text_to_chat(from: String, text: String) -> void:
	var chat_entry: Node = chat_entry_scene.instantiate()
	chat_entry.configure(from, text)
	
	# if the user was scrolled to the bottom of the chat history,
	# we should move their view down to fit the new entry
	var scroll_to_bottom: bool = false
	var v_scroll: VScrollBar = chat_history_scroll.get_v_scroll_bar()
	if v_scroll.value >= v_scroll.max_value - v_scroll.page:
		scroll_to_bottom = true
	
	chat_history.add_child(chat_entry)
	
	if scroll_to_bottom:
		# must wait for tree to update to be able to change scroll_vertical correctly
		await get_tree().process_frame
		chat_history_scroll.scroll_vertical = int(v_scroll.max_value)
