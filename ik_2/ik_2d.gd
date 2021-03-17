tool
extends Node2D
class_name IK2D

export(bool) var IK_on := true
export(Array) var root_bone_paths : Array
export(Array) var joint_paths : Array
export(Array) var target_paths : Array
var root_bones : Array
var joints : Array
var targets : Array



func _ready():
	if Engine.editor_hint or not Engine.editor_hint:
		initialize()

func initialize():
		process_priority = 1
		root_bones.clear()
		root_bone_paths.clear()
		joints.clear()
		joint_paths.clear()
		find_roots(get_parent())
		validate_needed_nodes()
		var idx := 0
		for root_bone in root_bones:
			joint_paths.append([])
			joints.append([])
			initialize_bone(root_bone, idx)
			get_joints(root_bone, idx)
			idx += 1

func get_joints(node, idx):
	joint_paths[idx].append(get_path_to(node))
	joints[idx].append(node)
	joints.append(node)
	for child in node.get_children():
		if child is IKBone2D or child is IKEnd2D:
			get_joints(child, idx)


func validate_needed_nodes():
	var idx := 0
	for child in get_parent().get_children():
		if child is IKRoot2D:
			idx += 1
	if root_bones.size() != idx:
		root_bones.clear()
		for root_bone_path in root_bone_paths:
			root_bones.append(get_node(root_bone_path))
	if targets.size() != idx:
		targets.clear()
		for target_path in target_paths:
			targets.append(get_node(target_path))

func _get_configuration_warning():
	if not root_bone_paths:
		return "Can't find Roots"
	if target_paths.size() != root_bone_paths.size():
		return "Not enough assigned Targets"
	return ''

func find_roots(node):
	var idx := 0
	for child in node.get_children():
		if child is IKRoot2D:
			root_bone_paths.append(get_path_to(child));
			root_bones.append(child)
			child.ik_handler = self
			child.IK_handler_path = child.get_path_to(self)
			child.root_idx = idx
			idx += 1

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

func initialize_bone(bone, root_idx):
	for child in bone.get_children():
		if child is IKBone2D or child is IKEnd2D:
			bone.child_bone_path = bone.get_path_to(child)
			bone.child_bone = child
			bone.length = bone.global_position.distance_to(child.global_position)
			bone.IK_handler_path = bone.get_path_to(self)
			bone.ik_handler = self
			initialize_bone(child, root_idx)
		if child is IKEnd2D:
			root_bones[root_idx].end_bone = child
			root_bones[root_idx].end_bone_path = root_bones[root_idx].get_path_to(child)
			root_bones[root_idx].ready = true


func _process(_delta):
	if Engine.editor_hint or not Engine.editor_hint:
		if targets.size() == root_bones.size() and root_bones and IK_on:
			pass
			#calculate_ik()
"""
func calculate_ik():
	var target_dist = root_bone.global_position.distance_to(target.global_position)
	var reach = 0.0
	for bone in joints:
		if not bone is IKEnd2D:
			reach += bone.length
	var rel_dist = root_bone.end_bone.global_position.distance_to(target.global_position)
	if rel_dist != 0:
		if target_dist > reach:
			#target is not reachable
			for i in joints.size()-1:
				#moves all joints except the root to their correct positions reaching for the target
				rel_dist = joints[i].global_position.distance_to(target.global_position)
				var lambda = joints[i].length / rel_dist
				joints[i+1].global_position = (1 - lambda) * joints[i].global_position + lambda * target.global_position
		else:
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
				
"""
