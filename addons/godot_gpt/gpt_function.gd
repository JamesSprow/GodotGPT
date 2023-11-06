## [GPTFunction] is a helper class to provide a simple interface to create function descriptions without manually creating dictionaries
extends Resource
class_name GPTFunction

@export var name: String = ""
@export_multiline var description: String = ""
@export var parameters: Dictionary = {}

@export var required_parameters: PackedStringArray = []

## Compiles the object into a [Dictionary] for use in a request to ChatGPT
## Example output for a function that can get the current weather given a location and optionally a temperature unit:
## [code]
## {
##   "name": "get_current_weather",
##   "description": "Get the current weather in a given location",
##   "parameters": {
##     "type": "object",
##     "properties": {
##       "location": {
##         "type": "string",
##         "description": "The city and state, e.g. San Francisco, CA"
##       },
##       "unit": {
##         "type": "string",
##         "enum": ["celsius", "fahrenheit"]
##       }
##     },
##     "required": ["location"]
##   }
## }
## [/code]
func compile() -> Dictionary:
	return {
		"name": name,
		"description": description,
		"parameters": parameters,
		"required": required_parameters
	}
