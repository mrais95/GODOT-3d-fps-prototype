extends KinematicBody

var speed = 15
var point = Vector3(52,12,0)

func _process(_delta):
	
	var direction
	
	if point.distance_to(transform.origin) > 1:
		direction = point - transform.origin
		direction = direction.normalized() * speed
	else:
		direction = point - transform.origin
	
	move_and_slide(direction)
	
