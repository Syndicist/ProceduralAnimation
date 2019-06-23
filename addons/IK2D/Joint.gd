extends Bone2D

export(int) var length = 100;
export(String) var type = "Joint";

func _draw():
	if(get_child_count() > 0):
		draw_line(Vector2(0,0), get_child(0).position, Color(1,0,0));

func _process(delta):
	update();