tool
extends Node2D
class_name IK2D

export(bool) var IK_on := false
export(Array) var IK_path_array_array : Array
export(int) var max_iterations := 10
export(bool) var initialized = false
export(float) var threshold := 0.1
var reinitialize = true
var ik_array_array : Array
var primary_idx = 0

func _ready():
	if Engine.editor_hint or not Engine.editor_hint:
		initialize()

func initialize():
	primary_idx = 0
	IK_path_array_array = []
	IK_path_array_array.append([])
	ik_array_array = []
	ik_array_array.append([])
	setup_bones(get_parent(), primary_idx)
	initialize_rotations()
	setup_centroids()
	ik_array_array.sort_custom(IKContainerSorter, "sort_ascending")

func setup_bones(node, top_idx):
	initialize_roots(node, IK_path_array_array[top_idx], ik_array_array[top_idx])
	for sub_idx in ik_array_array[top_idx].size():
		var ik_path_dict = IK_path_array_array[top_idx][sub_idx]
		var ik_dict = ik_array_array[top_idx][sub_idx]
		var root_bone = ik_dict["Root"]
		initialize_bone(root_bone, ik_path_dict, ik_dict)
	initialized = true

func initialize_roots(node, IK_path_array, ik_array):
	var _idx := 0
	var centroid
	if node.get_child_count() > 0:
		centroid = Centroid.new()
		centroid.global_position = Vector2(0, 0)
	for child in node.get_children():
		if child is IKRoot2D:
			IK_path_array.append({"Root Path" : get_path_to(child), "Bone Paths" : [], "Joint Positions" : []}) 
			var target = null
			if child.target_path and not child.target_path is String:
				target = child.get_node(child.target_path)
			ik_array.append({"Root" : child, "Target" : target, "Bones" : [], "Joints" : [], "Initial Bone Rotations" : [], "Priority" : 1000 - child.get_path().get_name_count()})
			child.ik_handler = self
			child.IK_handler_path = child.get_path_to(self)
			child.centroid = centroid
			_idx += 1

func initialize_bone(bone, ik_path_dict, ik_dict):
	ik_path_dict["Bone Paths"].append(get_path_to(bone))
	ik_path_dict["Joint Positions"].append(bone.global_position)
	ik_dict["Bones"].append(bone)
	ik_dict["Joints"].append(IKJoint.new(bone.global_position))
	if bone is IKEnd2D:
		return
	if bone is IKSubbase2D:
		primary_idx += 1
		IK_path_array_array.append([])
		ik_array_array.append([])
		setup_bones(bone, primary_idx)
	else:
		for child in bone.get_children():
			if child is IKBone2D or child is IKEnd2D or child is IKSubbase2D:
				bone.child_bone_path = bone.get_path_to(child)
				bone.child_bone = child
				bone.length = bone.global_position.distance_to(child.global_position)
				bone.IK_handler_path = bone.get_path_to(self)
				bone.ik_handler = self
				initialize_bone(child, ik_path_dict, ik_dict)
			if child is IKEnd2D or child is IKSubbase2D:
				ik_dict["Root"].end_bone = child
				ik_dict["Root"].end_bone_path = ik_dict["Root"].get_path_to(child)

func setup_centroids():
	for ik_array in ik_array_array:
		for ik_dict in ik_array:
			if ik_dict["Root"].end_bone is IKSubbase2D:
				ik_dict["Root"].target_path = "Centroid"
				var target
				for child in ik_dict["Root"].end_bone.get_children():
					if child is IKRoot2D:
						target = child.centroid
				ik_dict["Target"] = target

func initialize_rotations():
	for ik_array in ik_array_array:
		for ik_dict in ik_array:
			for i in ik_dict["Bones"].size()-1:
				var rotation = ik_dict["Bones"][i].get_angle_to(ik_dict["Bones"][i+1].global_position)
				ik_dict["Initial Bone Rotations"].append(rotation)

func _get_configuration_warning():
	if not IK_path_array_array:
		return "IK not properly set! (check IK Path Array)"
	return ''

func _process(_delta):
	if Engine.editor_hint or not Engine.editor_hint:
		if ik_array_array and IK_on and initialized:
			reinitialize = true
			calculate_ik()
		if not IK_on and reinitialize:
			reinitialize = false
			for ik_array in ik_array_array:
				for ik_dict in ik_array:
					for bone in ik_dict["Bones"]:
						bone.rotation = 0
			initialize()

func calculate_ik():
	for ik_array in ik_array_array:
		var centroid = ik_array[0]["Root"].centroid
		var itr := 0
		var prev_centroid_position = centroid.global_position
		while(itr < max_iterations):
			centroid.global_position = Vector2(0,0)
			#forward reaching
			for ik_dict in ik_array:
				solve_forward(ik_dict)
				centroid.global_position += ik_dict["Joints"][0].global_position
			
			centroid.global_position /= ik_array.size()
			
			#backward reaching
			for ik_dict in ik_array:
				solve_backward(ik_dict, centroid, prev_centroid_position)
			itr += 1

func solve_forward(ik_dict):
	ik_dict["iRootPos"] = ik_dict["Joints"][0].global_position
	#if ik_dict["Root"].end_bone.global_position.distance_to(ik_dict["Target"].global_position):
	#	return
	var end = ik_dict["Joints"][ik_dict["Joints"].size()-1]
	
	end.global_position = ik_dict["Target"].global_position
	
	for i in range(ik_dict["Bones"].size()-2, -1, -1):
		var rel_dist = ik_dict["Joints"][i].global_position.distance_to(ik_dict["Target"].global_position)
		
		var lambda = ik_dict["Bones"][i].length / rel_dist
		
		ik_dict["Joints"][i].global_position = (1 - lambda) * ik_dict["Joints"][i+1].global_position + lambda * ik_dict["Joints"][i].global_position
		
		ik_dict["Joints"][i].global_position.x = stepify(ik_dict["Joints"][i].global_position.x, 0.001)
		ik_dict["Joints"][i].global_position.y = stepify(ik_dict["Joints"][i].global_position.y, 0.001)

func solve_backward(ik_dict, centroid, prev_centroid_position):
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
		if ik_dict["Bones"][i].constrained:
			if ik_dict["Bones"][i].rotation > ik_dict["Bones"][i].upper_constraint:
				ik_dict["Bones"][i].rotation = ik_dict["Bones"][i].upper_constraint
			if ik_dict["Bones"][i].rotation < ik_dict["Bones"][i].lower_constraint:
				ik_dict["Bones"][i].rotation = ik_dict["Bones"][i].lower_constraint 
		ik_dict["Joints"][i].global_position = ik_dict["Bones"][i].global_position
		
	if ik_dict["Target"] is Centroid:
		ik_dict["Target"].global_position = end.global_position

class IKJoint:
	var global_position : Vector2
	func _init(pos : Vector2):
		global_position = pos

class Centroid:
	var global_position : Vector2

class IKContainerSorter:
	static func sort_ascending(a, b):
		return a[0]["Priority"] < b[0]["Priority"]

