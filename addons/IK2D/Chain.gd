extends Bone2D

export(NodePath) var targetPath;
export(Array,NodePath) var jointPaths;
export(int) var length = 100;
export(int) var type = TYPE.SUBBC;
enum TYPE {ROOT, JOINT, SUBBP, SUBBC, END}
var target;
var tolerance = 0.1;
var joints = [];
var nJoints = 0;
var max_length = 0;
var origin = Vector2();
var broke = false;

var constrained = false;
var left = .89;
var right = .89;
var up = .89;
var down = .89;

func _ready():
	target = get_node(targetPath);
	get_joints(self);
	nJoints = joints.size();
	origin = joints[0].global_position;
	if(joints[nJoints-1].type == TYPE.SUBBP):
		target = Node2D.new();
		get_owner().call_deferred("add_child", target);
		target.global_position = joints[nJoints-1].global_position;
	pass;

"""
func get_joints():
	for n in jointPaths:
		var j = get_node(n);
		max_length += j.length;
		joints.append(j);
"""

func get_joints(var n):
	if("type" in n):
		if(n.type == "SubBP";
		for c in n.get_children():
			if("type" in c):
				if(arm_idx >= lengths.size()):
					arm_idx = 0;
				if(n == self):
					max_lengths.append(lengths[arm_idx]);
					joints.append([]);
					joints[arm_idx].append(n);
				joints[arm_idx].append(c);
				if(c.type == TYPE.SUB_BASE || c.type == TYPE.END_EFFECTOR):
					ends.append(c);
				if(c.type != TYPE.SUB_BASE && c.type != TYPE.END_EFFECTOR):
					get_joints(n.get_node(c.get_path()));
				if(n == self):
					arm_idx += 1;
		max_lengths[arm_idx] += n.lengths[0];
		if(get_child_count() == 0):
			return;
	return;

func _draw():
	if(get_child_count() > 0):
		draw_line(Vector2(0,0), get_child(0).position, Color(1,0,0));

func _process(delta):
	update();

func solve():
	var dist = joints[0].global_position.distance_to(target.global_position);
	
	if(dist > max_length):
		broke = false;
		#target out of reach
		for i in nJoints-1:
			var r = target.global_position.distance_to(joints[i].global_position);
			var l = joints[i].length / r;
			
			joints[i+1].global_position = (1 - l) * joints[i].global_position + l * target.global_position;
	elif(!broke):
		#target in reach
		var bcount = 0;
		var dif = joints[nJoints-1].global_position.distance_to(target.global_position);
		while(dif > tolerance):
			backward();
			forward();
			dif = joints[nJoints-1].global_position.distance_to(target.global_position);
			bcount = bcount + 1;
			if(bcount > 1):
				break;
		
	pass;


func backward():
	joints[nJoints-1].global_position = target.global_position;
	var i = nJoints-2;
	for y in nJoints-1:
		var r = joints[i+1].global_position.distance_to(joints[i].global_position);
		var l = joints[i].length / r;
		
		joints[i].global_position = (1 - l) * joints[i+1].global_position + l * joints[i].global_position;
		i-=1;

func forward():
	joints[0].global_position = origin;
	for i in nJoints-1:
		var r = joints[i+1].global_position.distance_to(joints[i].global_position);
		var l = joints[i].length / r;
		
		joints[i+1].global_position = (1 - l) * joints[i].global_position + l * joints[i+1].global_position;

