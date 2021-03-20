tool
extends Node2D
class_name IK2D

export(bool) var IK_on := false
export(Array) var IK_path_array : Array
export(NodePath) var target_container_path : NodePath
export(int) var max_iterations := 10
export(bool) var initialized = false
var ik_array : Array
var target_container
var centroid : Centroid
var first_itr = true

func _ready():
	if Engine.editor_hint or not Engine.editor_hint:
		initialize()
		if initialized:
			IK_on = true

func initialize():
	first_itr = true
	if target_container_path:
		target_container = get_node(target_container_path).get_children()
	centroid = Centroid.new()
	centroid.global_position = Vector2(0, 0)
	IK_path_array = []
	ik_array = []
	find_roots(get_parent())
	var _idx := 0
	process_priority = 100 - ik_array[0]["Root"].get_path().get_name_count()
	for ik_dict in ik_array:
		var root_bone = ik_dict["Root"]
		initialize_bone(root_bone, _idx)
		get_joints(root_bone, _idx)
		initialize_rotations(ik_dict)
		_idx += 1
	initialized = true

func initialize_rotations(ik_dict):
	for i in ik_dict["Bones"].size()-1:
		var rotation = ik_dict["Bones"][i].get_angle_to(ik_dict["Bones"][i+1].global_position)
		print(rotation)
		ik_dict["Initial Bone Rotations"].append(rotation)

func get_joints(node, _idx):
	IK_path_array[_idx]["Bone Paths"].append(get_path_to(node))
	IK_path_array[_idx]["Joint Positions"].append(node.global_position)
	ik_array[_idx]["Bones"].append(node)
	ik_array[_idx]["Joints"].append(IKJoint.new(node.global_position))
	if node is IKEnd2D or node is IKSubbase2D:
		return
	for child in node.get_children():
		if child is IKBone2D or child is IKEnd2D or child is IKSubbase2D:
			get_joints(child, _idx)

func _get_configuration_warning():
	if not IK_path_array:
		return "IK not properly set! (check IK Path Array)"
	return ''

func find_roots(node):
	var _idx := 0
	for child in node.get_children():
		if child is IKRoot2D:
			IK_path_array.append({"Root Path" : get_path_to(child), "Target Path" : NodePath(""), "Bone Paths" : [], "Joint Positions" : []}) 
			ik_array.append({"Root" : child, "Target" : "", "Bones" : [], "Joints" : [], "Initial Bone Rotations" : []})
			child.ik_handler = self
			child.IK_handler_path = child.get_path_to(self)
			child.root_idx = _idx
			_idx += 1

func find_end(node):
	node.end_bone = find_end_recurse(node)
	if node.end_bone:
		return true
	return false

func find_end_recurse(node):
	for child in node.get_children():
		if child is IKBone2D:
			find_end_recurse(child)
		if child is IKEnd2D or IKSubbase2D:
			return node
	return null

func initialize_bone(bone, root_idx):
	if bone is IKEnd2D or bone is IKSubbase2D:
		return
	for child in bone.get_children():
		if child is IKBone2D or child is IKEnd2D or child is IKSubbase2D:
			bone.child_bone_path = bone.get_path_to(child)
			bone.child_bone = child
			bone.length = bone.global_position.distance_to(child.global_position)
			bone.IK_handler_path = bone.get_path_to(self)
			bone.ik_handler = self
			bone.root_idx = root_idx
			initialize_bone(child, root_idx)
		if child is IKEnd2D or child is IKSubbase2D:
			ik_array[root_idx]["Root"].end_bone = child
			ik_array[root_idx]["Root"].end_bone_path = ik_array[root_idx]["Root"].get_path_to(child)
			ik_array[root_idx]["Root"].ready = true
		if child is IKEnd2D:
			if target_container:
				var front = target_container.pop_front()
				IK_path_array[root_idx]["Target Path"] = get_path_to(front)
				ik_array[root_idx]["Target"] = front
		if child is IKSubbase2D:
			for child_child in child.get_children():
				if "centroid" in child_child :
					IK_path_array[root_idx]["Target Path"] = child_child.name + "'s Centroid"
					ik_array[root_idx]["Target"] = child_child.centroid

var stop = false

func _process(_delta):
	if Engine.editor_hint or not Engine.editor_hint:
		if ik_array and IK_on and initialized and not stop:
			calculate_ik()
			#stop = true

func calculate_ik():
	var itr := 0
	var prev_centroid_position = centroid.global_position
	while(itr < max_iterations):
		centroid.global_position = Vector2(0,0)
		var _idx := 0
		#forward reaching
		#set end position to target
		for ik_dict in ik_array:
			var end = ik_dict["Joints"][ik_dict["Joints"].size()-1]
			
			ik_dict["iRootPos"] = ik_dict["Joints"][0].global_position
			
			end.global_position = ik_dict["Target"].global_position
			
			for i in range(ik_dict["Bones"].size()-2, -1, -1):
				var rel_dist = ik_dict["Joints"][i].global_position.distance_to(ik_dict["Target"].global_position)
				
				var lambda = ik_dict["Bones"][i].length / rel_dist
				
				ik_dict["Joints"][i].global_position = (1 - lambda) * ik_dict["Joints"][i+1].global_position + lambda * ik_dict["Joints"][i].global_position
				
				ik_dict["Joints"][i].global_position.x = stepify(ik_dict["Joints"][i].global_position.x, 0.001)
				ik_dict["Joints"][i].global_position.y = stepify(ik_dict["Joints"][i].global_position.y, 0.001)
				
			centroid.global_position += ik_dict["Joints"][0].global_position
			_idx += 1
		centroid.global_position /= ik_array.size()
		
		#backward reaching
		#set root back to origin
		_idx = 0
		for ik_dict in ik_array:
			var end = ik_dict["Joints"][ik_dict["Joints"].size()-1]
			
			if get_parent() is Skeleton2D:
				ik_dict["Joints"][0].global_position = ik_dict["iRootPos"]
			elif ik_dict["Joints"][0].global_position != prev_centroid_position:
				ik_dict["Joints"][0].global_position = prev_centroid_position
			else:
				ik_dict["Joints"][0].global_position = centroid.global_position
			
			for i in ik_dict["Bones"].size()-1:
				var rel_dist = ik_dict["Joints"][i+1].global_position.distance_to(ik_dict["Joints"][i].global_position)
				var lambda = ik_dict["Bones"][i].length / rel_dist
				ik_dict["Joints"][i+1].global_position = (1 - lambda) * ik_dict["Joints"][i].global_position + lambda * ik_dict["Joints"][i+1].global_position
				
				ik_dict["Joints"][i].global_position.x = stepify(ik_dict["Joints"][i].global_position.x, 0.001)
				ik_dict["Joints"][i].global_position.y = stepify(ik_dict["Joints"][i].global_position.y, 0.001)
				
				ik_dict["Bones"][i].look_at(ik_dict["Joints"][i+1].global_position)
				ik_dict["Bones"][i].rotation -= ik_dict["Initial Bone Rotations"][i]
				ik_dict["Joints"][i].global_position = ik_dict["Bones"][i].global_position
				
			if ik_dict["Target"] is Centroid:
				ik_dict["Target"].global_position = end.global_position
			
			_idx += 1
		first_itr = false
		itr += 1

class IKJoint:
	var global_position : Vector2
	func _init(pos : Vector2):
		global_position = pos

class Centroid:
	var global_position : Vector2
