extends Spatial

func _ready() -> void:
	yield(get_tree().create_timer(5), "timeout")
	queue_free()
