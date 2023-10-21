extends Control

# Exported variable to store the API key used to interact with GPT.
@export var api_key: String

# Exported group of variables that are considered "internal".
# These are likely used for editor-only settings and adjustments.
@export_group("internal")
# Reference to the GPTChatRequest object which handles interactions with GPT.
@export var gpt: GPTChatRequest
# Reference to the ScrollContainer that wraps the chat history.
@export var chat_history_scroll: ScrollContainer
# Reference to the container that holds individual chat messages.
@export var chat_history: VBoxContainer
# Reference to the control that captures user input.
@export var prompt_input: Control

# Reference to the PackedScene for individual chat entries. This is likely a pre-designed UI element.
@export var chat_entry_scene: PackedScene

# Function called when the node is added to the scene. Initializes various properties and connections.
func _ready():
	# Connect the signal from GPTChatRequest that is emitted when a request is completed.
	gpt.gpt_request_completed.connect(_on_gpt_request_completed)
	# Connect the signal for when the user submits a prompt.
	prompt_input.prompt_submitted.connect(send_chat_request)

# Callback function for when a GPT request has been completed.
func _on_gpt_request_completed(response_text: String):
	# Add the response from GPT to the chat.
	add_text_to_chat("ChatGPT", response_text)
	# Disable the button in the input control.
	prompt_input.set_button_state(false)

# Function to send the user's chat request to GPT.
func send_chat_request(prompt: String) -> void:
	# If the user's prompt is empty, return without sending a request.
	if prompt == "":
		return
	
	# Set the API key of the GPTChatRequest object.
	gpt.api_key = api_key
	
	# Add the user's message to the chat.
	add_text_to_chat("Me", prompt)
	# Send the user's message to GPT and store any error that might occur.
	var err: Error = gpt.gpt_chat_request(prompt)
	
	# If there was an error, display it in the chat.
	if err:
		add_text_to_chat("Error", "Failed to send request to ChatGPT API")
	else:
		# Otherwise, enable the button in the input control.
		prompt_input.set_button_state(true)

# Function to add a new chat entry to the chat history.
func add_text_to_chat(from: String, text: String) -> void:
	# Instantiate a new chat entry from the PackedScene.
	var chat_entry: Node = chat_entry_scene.instantiate()
	# Configure the chat entry with the sender's name and the message text.
	chat_entry.configure(from, text)
	
	# Check if the user's view was scrolled to the bottom of the chat history.
	var scroll_to_bottom: bool = false
	# Get the vertical scrollbar of the chat history scroll container.
	var v_scroll: VScrollBar = chat_history_scroll.get_v_scroll_bar()
	# If the scroll value is near the max value, set the flag to scroll to the bottom.
	if v_scroll.value >= v_scroll.max_value - v_scroll.page:
		scroll_to_bottom = true
	
	# Add the new chat entry to the chat history container.
	chat_history.add_child(chat_entry)
	
	# If the flag to scroll to the bottom is set, do so after waiting for a frame.
	# This ensures the scrollbar updates correctly.
	if scroll_to_bottom:
		await get_tree().process_frame
		chat_history_scroll.scroll_vertical = int(v_scroll.max_value)
