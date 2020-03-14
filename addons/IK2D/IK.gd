extends Skeleton2D

var classType = preload("./IKBone2D.gd");
export(NodePath) var rootPath;
var chains = [];
var root;

func _ready():
	root = get_node(rootPath);
	get_sub_bases(root);

func _process(delta):
	root.origin = root.global_position;
	root.joints[0].global_position = root.origin;
	var centroid = Vector2(0,0);
	for i in chains.size():
		chains[i].backward();
		centroid += chains[i].joints[0].global_position;
	centroid = centroid / chains.size();
	
	root.target.global_position = centroid;
	root.solve();
	
	for i in chains.size():
		chains[i].origin = root.joints[root.nJoints-1].global_position;
		chains[i].forward();

func get_sub_bases(node):
	if(node is classType):
		if(node.type == Enums.JointType.SUBBASE):
			chains.append(node);
		if(node.get_child_count()>0):
			for child in node.get_children():
				get_sub_bases(child);