extends Bone2D

export(Array,int) var lengths = [100];
export(int) var type = TYPE.JOINT;
enum TYPE {ROOT, JOINT, SUBBP, SUBBC, END}

func _draw():
	if(get_child_count() > 0):
		draw_line(Vector2(0,0), get_child(0).position, Color(1,0,0));

func _process(delta):
	update();