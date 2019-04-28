tool
extends EditorPlugin

func _enter_tree():
	# Initialization of the plugin goes here
	# Add the new type with a name, a parent type, a script and an icon
	add_custom_type("PhysicsLimb2D", "Node2D", preload("physics_limb2D.gd"), preload("limb_icon.png"))
	add_custom_type("PhysicsJoint2D", "Position2D", preload("physics_joint2D.gd"), preload("joint_icon.png"))
	add_custom_type("PhysicsBone2D", "Position2D", preload("physics_bone2D.gd"), preload("bone_icon.png"))

func _exit_tree():
	# Clean-up of the plugin goes here
	# Always remember to remove it from the engine when deactivated
	remove_custom_type("PhysicsJoint2D")