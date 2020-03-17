tool
extends "./IKBone2D.gd"

func _ready():
	type = Enums.JointType.JOINT;

func _draw():
	if not Engine.editor_hint:
		if(get_child_count() > 0):
			draw_line(Vector2(0,0), get_child(0).position, Color(1,0,0));

func _process(delta):
	update();
	execute(delta);