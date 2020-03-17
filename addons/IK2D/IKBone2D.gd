tool
extends Bone2D

export(Enums.JointType) var type;

export(int) var length = 100;

export(float) var leftBound = -45.0;
export(float) var rightBound = 45.0;

var leftLimit = Vector2(0,0);
var rightLimit = Vector2(0,0);

var originalPos;

func _ready():
	if(get_child_count() > 0):
		originalPos = get_child(0).position;

func _process(delta):
	execute(delta);

var test = true;

func execute(delta):
	return;"""
	if(get_parent() is Skeleton2D && type != Enums.JointType.ROOT && test):
		test = false;
		print(get_parent().name);
		var root = load("res://addons/IK2D/Root.gd").new();
		root.length = length;
		root.leftBound = leftBound;
		root.rightBound = rightBound;
		root.global_position = global_position;
		get_parent().add_child(root);
		if(get_child_count()>0):
			root.add_child(get_child(0));
		root.type = Enums.JointType.ROOT
		queue_free();"""

"""
func execute(delta):
	if Engine.editor_hint:
		print("!!");
		if(get_child_count() > 0):
			print("!!");
			if(position.distance_to(get_child(0).position) > length):
				var angle = atan2(get_child(0).global_position.y - global_position.y, get_child(0).global_position.x - global_position.x);
				get_child(0).position = Vector2(100 * cos(angle), 100 * sin(angle));
"""