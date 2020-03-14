tool
extends "./IKBone2D.gd"

var classType = preload("./IKBone2D.gd");

export(int) var length = 100;
export(Enums.JointType) var type;
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
	if not Engine.editor_hint:
		joints.clear();
		get_joints(self);
		nJoints = joints.size();
		origin = joints[0].global_position;
		if(joints[nJoints-1].type == 0):
			target = Node2D.new();
			get_owner().call_deferred("add_child", target);
			target.global_position = joints[nJoints-1].global_position;
	if Engine.editor_hint:
		check_joints(self);

func check_joints(node):
	if(node is classType):
		max_length += node.length;
		joints.append(node);
		if(node.type != Enums.JointType.SUBBASE && node.type != Enums.JointType.END):
			for child in node.get_children():
				check_joints(child);

func get_joints(node):
	if(node is classType):
		max_length += node.length;
		joints.append(node);
		if(node.type != Enums.JointType.SUBBASE && node.type != Enums.JointType.END):
			if(node.get_child_count()>0):
				for child in node.get_children():
					get_joints(child);
		else:
			target = preload("res://addons/IK2D/IKMouseTarget2D.tscn").instance();
			get_tree().get_root().call_deferred("add_child",target);
			target.global_position = node.global_position;


func _draw():
	if not Engine.editor_hint:
		if(get_child_count() > 0):
			draw_line(Vector2(0,0), get_child(0).position, Color(1,0,0));

func _process(delta):
	if not Engine.editor_hint:
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


func _get_configuration_warning():
	if(get_parent().type != Enums.JointType.SUBBASE):
		return 'Parent is not SubBase'
	if(!find_end(self)):
		return "Can't find End or SubBase in Children"
	return ''

func find_end(node):
	if(node.type == Enums.JointType.END || node.type == Enums.JointType.SUBBASE):
		return true;
	for child in node.get_children():
		return find_end(child);
	return false;