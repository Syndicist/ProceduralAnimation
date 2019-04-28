extends Node2D

const J = preload("physics_joint2D.gd")

var joints = [];
var bones;
var max_length = 0;
var distance_threshold = 5;
var sampling_distance = .0005;
var learning_rate = .0015;

var end_effector = Vector2();

func _ready():
	if(get_child_count() != 0):
		get_joints(self);
		get_bones();

func get_joints(var n):
	if(get_child_count() == 0):
		return;
	for c in n.get_children():
		if c is J:
			joints.append(c);
			max_length += c.length;
			get_joints(n.get_node(c.get_path()));
			return;
	return;

func get_bones():
	
	pass;

func _physics_process(delta):
	InverseKinematics(get_local_mouse_position());
	#ForwardKinematics();
	#joints[0].rotation = joints[0].position.angle_to_point(-get_local_mouse_position());
	#print(end_effector);
	#print(get_local_mouse_position());
	$Sprite.position = end_effector;
	pass;

#returns new calculated position to travel to
func ForwardKinematics():
	#rotation
	var prevPoint = joints[0].position;
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

#returns float gradiant given a target position, an array of angles, and the index of the joint currently accessed
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

#returns a float distance from the target position
func DistanceFromTarget(var target):
	var point = ForwardKinematics()
	#print(target.distance_to(point))
	return target.distance_to(point);


func InverseKinematics(var target):
	if (DistanceFromTarget(target) < distance_threshold):
	    return;
	var y = joints.size()-1;
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
func InverseKinematics(var target):
	var distance_from_target = target.distance_to(joints[0].position);
	
	#Angle from Joint0 and Target
	var diff = target.position - joints[0].position;
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
