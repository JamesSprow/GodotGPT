extends Control

var bucket = preload("res://addons/godot_gpt/examples/function/bucket/bucket.tscn")
var n_buckets: int = 3

var buckets: Array = []

func _ready():
	
	
	for i in n_buckets:
		var b = bucket.instantiate()
		$VBoxContainer/HBoxContainer.add_child(b)
		b.set_name("Bucket "+str(i+1))
		buckets.append(b)
	
	update_buckets()

func get_bucket(n: int) -> Control:
	if n > 3:
		return null
	else:
		return buckets[n-1]

func update_buckets() -> void:
	for b in buckets:
		b.update()

func move_to_from_color(from: int, to: int, amnt: int, color: String) -> String:
	var f = get_bucket(from)
	var t = get_bucket(to)
	if f == null or t == null:
		return "Destination/source not valid"
	if f.data[color] < amnt:
		return "Not enough "+color+" balls in bucket "+str(from)+"."
	
	f.data[color] -= amnt
	t.data[color] += amnt
	
	update_buckets()
	
	return "Moved " + str(amnt) + " "+color+" balls from bucket "+str(from)+" to bucket "+str(to)+"."
