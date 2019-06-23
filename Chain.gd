extends Skeleton2D

export(NodePath) var rootPath;
export(NodePath) var targetPath;
var root;
var target;
var tolerance = 0.1;
var lengths = [];
var joints = [];
var nJoints = 0;
var max_length = 0;
var origin = Vector2();

var constrained = false;
var left = .89;
var right = .89;
var up = .89;
var down = .89;

func _ready():
	root = get_node(rootPath);
	target = get_node(targetPath);
	get_joints(root);
	nJoints = joints.size();
	origin = joints[0];
	pass;
	
func get_joints(var n):
	if "length" in n:
		max_length += n.length;
		lengths.append(n.length);
		joints.append(n);
		if(n.get_child_count() != 0):
			get_joints(n.get_child(0));

func _process(delta):
	solve();

func solve():
	var dist =joints[0].global_position.distance_to(target.global_position);
	
	if(dist > max_length):
		#target out of reach
		for i in nJoints-1:
			var r = target.global_position.distance_to(joints[i].global_position);
			var l = lengths[i] / r;
			
			joints[i+1].global_position = (1 - l) * joints[i].global_position + l * target.global_position;
	else:
		#target in reach
		var bcount = 0;
		var dif = joints[nJoints-1].global_position.distance_to(target.global_position);
		while(dif > tolerance):
			backward();
			forward();
			dif = joints[nJoints-1].global_position.distance_to(target.global_position);
			bcount = bcount + 1;
			if(bcount > 10):
				break;
	pass;


func backward():
	joints[nJoints-1].global_position = target.global_position;
	var i = nJoints-2;
	for y in nJoints-1:
		var r = joints[i+1].global_position.distance_to(joints[i].global_position);
		var l = lengths[i] / r;
		
		joints[i].global_position = (1 - l) * joints[i+1].global_position + l * joints[i].global_position;

func forward():
	joints[0].global_position = origin.global_position;
	for i in nJoints-1:
		var r = joints[i+1].global_position.distance_to(joints[i].global_position);
		var l = lengths[i] / r;
		
		joints[i+1].global_position = (1 - l) * joints[i].global_position + l * joints[i+1].global_position;

