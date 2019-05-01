extends Position2D

#var min_angle = -100;
#var max_angle = 100;
export(float) var length = 0;
var joints = [];
var allJoints = [];
var targets = []
var sprites = [];
export(String) var type = "";
export(NodePath) var EndTarg;

func _ready():
	initialize();

func initialize():
	get_joints_and_sprites();
	set_type();

func get_joints_and_sprites():
	if(get_child_count() == 0):
		return;
	for n in get_children():
		if "length" in n:
			joints.append(n);
		if "texture" in n:
			sprites.append(n);
	return;

func set_type():
	if(type == "root"):
		return;
	elif(joints.size()>1):
		type = "sub";
	elif(joints.size()==0):
		type = "end";
	elif(joints.size()<1):
		type = "norm";

func get_all_joints_and_Targets():
	if(get_child_count() == 0):
		return;
	for n in get_children():
		if "length" in n:
			#append value to new array
			#append new array to allJoints
			#append end effectors and sub-bases to targets array
			pass;
	

func _draw():
	for j in joints:
		draw_line(Vector2(0,0), j.position, Color(1,0,0));

func _physics_process(delta):
	update();

func fabrik():
	if(type == "norm"):
		get_parent().fabrik();
	if(type == "end"):
		get_parent().fabrik();
	else:
		#The distance between root and target
		var n = joints.size() - 1;
		var dist = joints[0].global_position.distance_to(target);
		#Check whether the target is within reach
		if(dist > max_length):
			#The target is unreachable
			var r = [];
			r.resize(joints.size());
			var lamb = [];
			lamb.resize(joints.size());
			for i in n:
				#Find the distance ri between the target and the joint global_position pi
				r[i] = target.distance_to(joints[i].global_position);
				lamb[i] = joints[i].length/r[i];
				#Find the new joint global_positions.
				joints[i+1].global_position = (1 - lamb[i]) * joints[i].global_position + lamb[i] * target;
		else:
			#The target is reachable; thus, set as b the initial global_position of the joint p1
			var b = joints[0].global_position;
			#Check whether the distance between the end effector pn and the target is greater than a distance threshold.
			var difA = joints[n].global_position.distance_to(target);
			while(difA > distance_threshold):
				#STAGE 1: FORWARD REACHING
				#Set the end effector pn as target
				
				joints[n].global_position = target;
				var y = n-1;
				var r = [];
				r.resize(joints.size());
				var lamb = [];
				lamb.resize(joints.size());
				for i in n:
					#Find the distance ri between the new joint global_position pi+1 and the joint pi
					r[y] = joints[y+1].global_position.distance_to(joints[y].global_position);
					lamb[y] = joints[y].length/r[y];
					#Find the new joint global_positions pi.
					joints[y].global_position = (1 - lamb[y]) * joints[y+1].global_position + lamb[y] * joints[y].global_position;
					y-=1
				#STAGE 2: BACKWARD REACHING
				#Set the root p1 its initial global_position.
				joints[0].global_position = b;
				
				for i in n:
					#Find the distance ri between the new joint global_position pi and the joint pi+1
					r[i] = joints[i+1].global_position.distance_to(joints[i].global_position);
					lamb[i] = joints[i].length/r[i];
					#Find the new joint global_positions pi.
					joints[i+1].global_position = (1 - lamb[i]) * joints[i].global_position + lamb[i] * joints[i+1].global_position;
				difA = joints[n].global_position.distance_to(target);



"""
var start_offset = 0;
func _ready():
	start_offset = position;

func get_limb(var node):
	if "joints" in node:
		return node;
	else:
		return get_limb(node.get_parent());

func get_relative_position_to_limb():
	return get_relative_transform_to_parent(get_limb(get_parent())).get_origin()"""