extends Node2D

export(NodePath) var Root;
var joints = [];
var bones;
var max_length = 0;
var distance_threshold = 1;
#var sampling_distance = .0005;
#var learning_rate = .0015;

#var end_effector = Vector2();

func _ready():
	if(get_child_count() != 0):
		get_joints(self);

func get_joints(var n):
	if(get_child_count() == 0):
		return;
	for c in n.get_children():
		if "length" in c:
			joints.append(c);
			max_length += c.length;
			get_joints(n.get_node(c.get_path()));
	return;

func _physics_process(delta):
	fabrik($Target2D.global_position);
	#InverseKinematics(get_local_mouse_global_position());
	pass;

#n = number of joints
#pi = global_position p of joint i.
#di = distance d between joint i and joint i+1
#target = target global_position for pn
#output = new global_positions for all the joints in order
func fabrik(var target):
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
#returns new calculated global_position to travel to
func ForwardKinematics():
	#rotation
	var prevPoint = joints[0].global_position;
	var rot = 0;
	for i in joints.size():
		if(i == 0):
			pass;
		else:
			#Rotate
			rot += joints[i-1].rotation;
			var nextPoint = prevPoint + joints[i].start_offset.rotated(rot);
			prevPoint = nextPoint;
	end_effector = prevPoint;
	return prevPoint;

#returns float gradiant given a target global_position, an array of angles, and the index of the joint currently accessed
func PartialGradient(var target, var i):
	#Saves the angle,
	#it will be restored later
	var angle = joints[i].rotation;
	
	#Gradient : [F(x+SamplingDistance) - F(x)] / h
	var f_x = DistanceFromTarget(target);
	
	joints[i].rotation += sampling_distance;
	var f_x_plus_d = DistanceFromTarget(target);
	
	var gradient = (f_x_plus_d - f_x) / sampling_distance;
	
	#Restores
	joints[i].rotation = angle;
	
	return gradient;

#returns a float distance from the target global_position
func DistanceFromTarget(var target):
	var point = ForwardKinematics()
	#print(target.distance_to(point))
	return target.distance_to(point);


func InverseKinematics(var target):
	if (DistanceFromTarget(target) < distance_threshold):
	    return;
	var y = n;
	for i in joints.size():
		#Gradient descent
		#Update : Solution -= LearningRate * Gradient
		var gradient = PartialGradient(target, y);
		joints[y].rotation -= learning_rate * gradient;
		#Clamp
		#joint.rotation = clamp(joint.rotation, joint.min_angle, joint.max_angle);
		
		#Early termination
		if (DistanceFromTarget(target) < distance_threshold):
		    return;
		y -= 1;
"""

"""
func InverseKinematics(var target):
	var distance_from_target = target.distance_to(joints[0].global_position);
	
	#Angle from Joint0 and Target
	var diff = target.global_position - joints[0].global_position;
	var angle_from_target = Mathf.atan2(diff.y, diff.x);
	
	#Is the target reachable?
	#If not, we stretch as far as possible
	if (max_length < distance_from_target):
		joints[0].rotation = angle_from_target;
		for i in joints.size():
			if(i == 0):
				pass;
			else:
				joints[i].rotation = 0;
	else:
		for i in joints.size():
			if(joints[i].has_joint_child()
			float cosAngle0 = ((length2 * length2) + (length0 * length0) - (length1 * length1)) / (2 * length2 * length0);
			float angle0 = Mathf.Acos(cosAngle0) * Mathf.Rad2Deg;
			
			float cosAngle1 = ((length1 * length1) + (length0 * length0) - (length2 * length2)) / (2 * length1 * length0);
			float angle1 = Mathf.Acos(cosAngle1) * Mathf.Rad2Deg;
			
			#So they work in Unity reference frame
			jointAngle0 = atan - angle0;
			jointAngle1 = 180f - angle1;
"""
