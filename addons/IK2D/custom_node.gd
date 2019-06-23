tool
extends EditorPlugin

func _enter_tree():
	# Initialization of the plugin goes here
	# Add the new type with a name, a parent type, a script and an icon
	add_custom_type("IKRoot2D", "Bone2D", preload("Root.gd"), preload("limb_icon.png"))
	add_custom_type("IKSub-BasePos2D", "Bone2D", preload("Joint.gd"), preload("joint_icon.png"))
	add_custom_type("IKSub-BaseChain2D", "Bone2D", preload("Chain.gd"), preload("joint_icon.png"))
	add_custom_type("IKJoint2D", "Bone2D", preload("Joint.gd"), preload("bone_icon.png"))
	add_custom_type("IKEnd2D", "Bone2D", preload("End.gd"), preload("bone_icon.png"))
	add_custom_type("IK2D", "Skeleton2D", preload("IK.gd"), preload("bone_icon.png"))
	add_custom_type("IKMouseTarget2D", "Area2D", preload("MouseTarget.gd"), preload("bone_icon.png"))

func _exit_tree():
	# Clean-up of the plugin goes here
	# Always remember to remove it from the engine when deactivated
	remove_custom_type("PhysicsJoint2D")