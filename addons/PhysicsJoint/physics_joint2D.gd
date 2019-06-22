extends Bone2D

enum TYPE {JOINT, SUB_BASE, END_EFFECTOR, ROOT};

export(Color) var color = Color(255,0,0);
export(int) var length = 100;
export(int) var type = TYPE.JOINT;
export(NodePath) var targetPath;
var target;

export(Array, int) var lengths;
var Root;
var joints = [];
var ends = [];
var max_lengths = [];
var max_length = 0;
var sub_idx;
var arm_idx = 0;
var distance_threshold = 1;
var done = false;
#var sampling_distance = .0005;
#var learning_rate = .0015;

func _ready():
	if(type == TYPE.SUB_BASE):
		target = self;
	elif(type == TYPE.END_EFFECTOR):
		target = get_node(targetPath);
	if(get_child_count() != 0 && (type == TYPE.SUB_BASE || type == TYPE.ROOT)):
		get_joints(self);
	arm_idx = 0;
	pass;


func find_parent_root_or_base(var n):
	if("type" in n.get_parent()):
		if(n.get_parent().type == TYPE.SUB_BASE || n.get_parent().type == TYPE.ROOT):
			sub_idx = n.get_index();
			return n.get_parent();
		else:
			return find_parent_root_or_base(n.get_parent());
	else:
		return null;

func get_joints(var n):
	if("type" in n):
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
		if(n.type == TYPE.JOINT):
			max_lengths[arm_idx] += n.length;
		if(get_child_count() == 0):
			return;
	return;

func _draw():
	for c in get_children():
		if("type" in c):
			draw_line(Vector2(0,0), c.position, color, 2);

func _process(delta):
	if(type == TYPE.SUB_BASE && !done):
		var sub = find_parent_root_or_base(self);
		if(sub != null):
			max_length = sub.max_lengths[sub_idx];
			for i in max_lengths:
				i += max_length;
				print(i)
			done = true;
	update();
	default_length = length;
	pass;

func _physics_process(delta):
	if(type == TYPE.SUB_BASE || type == TYPE.ROOT):
		#print(global_position);
		for c in ends:
			if(arm_idx >= ends.size()):
				arm_idx = 0;
			fabrik(c.target.global_position);
			arm_idx+=1;
	pass;


#n = number of joints
#pi = global_position p of joint i.
#di = distance d between joint i and joint i+1
#target = target global_position for pn
#output = new global_positions for all the joints in order
func fabrik(var target):
	#The distance between root and target
	var n = joints[arm_idx].size() - 1;
	var dist = joints[arm_idx][0].global_position.distance_to(target);
	
	#Check whether the target is within reach
	if(dist > max_lengths[arm_idx]):
		#The target is unreachable
		var r = [];
		r.resize(joints[arm_idx].size());
		var lamb = [];
		lamb.resize(joints[arm_idx].size());
		for i in n:
			#Find the distance ri between the target and the joint global_position pi
			r[i] = target.distance_to(joints[arm_idx][i].global_position);
			lamb[i] = joints[arm_idx][i].length/r[i];
			#Find the new joint global_positions.
			joints[arm_idx][i+1].global_position = (1 - lamb[i]) * joints[arm_idx][i].global_position + lamb[i] * target;
	else:
		#The target is reachable; thus, set as b the initial global_position of the joint p1
		var b = joints[arm_idx][0].global_position;
		#Check whether the distance between the end effector pn and the target is greater than a distance threshold.
		var difA = joints[arm_idx][n].global_position.distance_to(target);
		while(difA > distance_threshold):
			#STAGE 1: FORWARD REACHING
			#Set the end effector pn as target
			joints[arm_idx][n].global_position = target;
			var y = n-1;
			var r = [];
			r.resize(joints[arm_idx].size());
			var lamb = [];
			lamb.resize(joints[arm_idx].size());
			for i in n:
				#Find the distance ri between the new joint global_position pi+1 and the joint pi
				r[y] = joints[arm_idx][y+1].global_position.distance_to(joints[arm_idx][y].global_position);
				lamb[y] = joints[arm_idx][y].length/r[y];
				#Find the new joint global_positions pi.
				joints[arm_idx][y].global_position = (1 - lamb[y]) * joints[arm_idx][y+1].global_position + lamb[y] * joints[arm_idx][y].global_position;
				y-=1
			#STAGE 2: BACKWARD REACHING
			#Set the root p1 its initial global_position.
			#joints[arm_idx][0].global_position = b;
			
			for i in n:
				#Find the distance ri between the new joint global_position pi and the joint pi+1
				r[i] = joints[arm_idx][i+1].global_position.distance_to(joints[arm_idx][i].global_position);
				lamb[i] = joints[arm_idx][i].length/r[i];
				#Find the new joint global_positions pi.
				joints[arm_idx][i+1].global_position = (1 - lamb[i]) * joints[arm_idx][i].global_position + lamb[i] * joints[arm_idx][i+1].global_position;
			difA = joints[arm_idx][n].global_position.distance_to(target);
