extends Position2D

var start_offset = 0;
var min_angle = -100;
var max_angle = 100;
var length = 0;

func _ready():
	add_to_group("joints");
	start_offset = position;
	print(start_offset);
	length = position.x;

func _physics_process(delta):
	#print(rotation);
	pass;

func has_joint_child():
	for c in get_children():
		if start_offset in c:
			return true
	return false;

func get_limb(var node):
	if "joints" in node:
		return node;
	else:
		return get_limb(node.get_parent());

func get_relative_position_to_limb():
	return get_relative_transform_to_parent(get_limb(get_parent())).get_origin()