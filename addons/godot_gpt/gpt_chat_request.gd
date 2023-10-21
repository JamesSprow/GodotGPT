# This script extends the GPTRequest class, defining functionality specific to handling chat requests with GPT.
extends GPTRequest
# Assign a custom class name "GPTChatRequest" for easier reference and instantiation in other scripts.
class_name GPTChatRequest

# Define a variable "history" to store the conversation history. Each entry is a dictionary with details about the message.
var history: Array[Dictionary] = []

# This function is called when a GPT request is completed.
# It processes the response from GPT and stores it in the history.
func _request_completed_post_process(gpt_response: String) -> void:
	# Call the base class's version of this function to ensure any base-level processing is carried out.
	super(gpt_response)
	# Append the GPT's response to the history with the role specified as "system".
	history.append({
		"role": "system",
		"content": gpt_response
	})

# This function clears the conversation history.
func clear_history() -> void:
	history = []

# This function initiates a chat request to GPT using the provided prompt.
# It structures the request based on the ongoing conversation history and sends it to GPT.
func gpt_chat_request(prompt: String) -> Error:
	# Create a dictionary representing the user's message.
	var message: Dictionary = {
		"role": "user",
		"content": prompt
	}
	# Duplicate the current conversation history to avoid directly modifying it.
	var messages: Array[Dictionary] = history.duplicate()
	# Append the user's message to the list of messages.
	messages.append(message)
	
	# Update the main conversation history with the user's message.
	history.append(message)
	
	# Send the updated list of messages to GPT to generate a completion and return any potential error.
	return gpt_completions_request(messages)
