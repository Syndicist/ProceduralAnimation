extends Skeleton2D

export(Array,NodePath) var chainPaths;
export(NodePath) var rootPath;
var chains = [];
var root;

func _ready():
	for c in chainPaths:
		var n = get_node(c);
		chains.append(n);
	root = get_node(rootPath);

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