extends Control

var id: int = 0

var data: Dictionary = {
	"Red" = 0,
	"Blue" = 0,
	"Green" = 0
}

func set_name(n: String):
	$VBoxContainer/Label.text = n

func to_text(d: Dictionary):
	var r: String = ""
	for k in d.keys():
		r += k + ": " + str(d[k]) + '\n'
	return r

func update():
	$VBoxContainer/dataLabel.text = to_text(data)
