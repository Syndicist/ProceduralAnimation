tool
extends Node2D
class_name IK2D

export(bool) var IK_on := true
export(NodePath) var root_bone_path
export(Array) var joint_paths
export(NodePath) var target_path
var root_bone
var joints : Array
var target



func _ready():
	if Engine.editor_hint or not Engine.editor_hint:
		initialize()

func initialize():
		process_priority = 1
		joints.clear()
		joint_paths.clear()
		target = get_node(target_path)
		find_root(get_parent())
		validate_needed_nodes()
		joint_paths.append(root_bone_path)
		joints.append(root_bone)
		initialize_bone(root_bone)
		get_joints(root_bone)

func get_joints(node):
	for child in node.get_children():
		if child is IKBone2D or child is IKEnd2D:
			joint_paths.append(node.get_path_to(child))
			joints.append(child)
			get_joints(child)

func validate_needed_nodes():
	if not root_bone:
		print(get_parent().get_node(root_bone_path).name)
		root_bone = get_parent().get_node(root_bone_path)
	if not target:
		target = get_node(target_path)

func _get_configuration_warning():
	if not root_bone_path:
		return "Can't find Root"
	if not target_path:
		return "No Target assigned"
	return ''

func find_root(node):
	for child in node.get_children():
		if child is IKRoot2D:
			if not child.ik_handler:
				root_bone_path = get_parent().get_path_to(child);
				root_bone = child
				child.ik_handler = self
				child.IK_handler_path = child.get_path_to(self)
				return true;
	return false;

func find_end(node):
	node.end_bone = find_end_recurse(node)
	if node.end_bone:
		return true
	return false

func find_end_recurse(node):
	for child in node.get_children():
		print(child.name)
		if child is IKBone2D:
			find_end_recurse(child)
		if child is IKEnd2D:
			return node
	return null

func initialize_bone(bone):
	for child in bone.get_children():
		if child is IKBone2D or child is IKEnd2D:
			bone.child_bone_path = bone.get_path_to(child)
			bone.child_bone = child
			bone.length = bone.global_position.distance_to(child.global_position)
			bone.IK_handler_path = bone.get_path_to(self)
			bone.ik_handler = self
			initialize_bone(child)
		if child is IKEnd2D:
			root_bone.end_bone = child
			root_bone.end_bone_path = root_bone.get_path_to(child)
			root_bone.ready = true


func _process(_delta):
	if Engine.editor_hint or not Engine.editor_hint:
		if target and root_bone and IK_on:
			calculate_ik()

func calculate_ik():
	var rel_dist = root_bone.end_bone.global_position.distance_to(target.global_position)
	#target is reachable
	var initial_pos = root_bone.global_position
	
	#forward reaching
	#set end position to target
	root_bone.end_bone.global_position = target.global_position
	for i in range(joints.size()-2, 0, -1):
		rel_dist = joints[i].global_position.distance_to(target.global_position)
		var lambda = joints[i].length / rel_dist
		joints[i].global_position = (1 - lambda) * joints[i+1].global_position + lambda * joints[i].global_position

	#backward reaching
	#set root back to origin
	root_bone.global_position = initial_pos
	for i in joints.size()-1:
		rel_dist = joints[i+1].global_position.distance_to(joints[i].global_position)
		var lambda = joints[i].length / rel_dist
		joints[i+1].global_position = (1 - lambda) * joints[i].global_position + lambda * joints[i+1].global_position
		
