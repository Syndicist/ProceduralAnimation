tool
extends Skeleton2D

var classType = preload("./IKBone2D.gd");
var chainRoots_SubBases_SubChains = [];
var chainRoots = [];
var curRoot = -1;
var curBase = -1;
var root;

func _ready():
	if not Engine.editor_hint:
		find_root(self);
		compile_roots(root);

func find_root(node):
	if(node is classType):
		if(node.type == Enums.JointType.ROOT):
			root = node;
			return true;
	for child in node.get_children():
		return find_root(child);
	return false;

func _get_configuration_warning():
	if(!find_root(self)):
		return "Can't find Root"
	return ''

func _process(delta):
	if not Engine.editor_hint:
		execute(delta);


func execute(delta):
	for iRoot in chainRoots_SubBases_SubChains.size():
		for iSubbase in chainRoots_SubBases_SubChains[iRoot].size():
			calculate_centroid(chainRoots[iRoot],iRoot,iSubbase);

func calculate_centroid(node,iRoot,iSubbase):
	node.origin = node.global_position;
	node.joints[0].global_position = node.origin;
	var centroid = Vector2(0,0);
	var chains = chainRoots_SubBases_SubChains[iRoot][iSubbase];
	for i in chains.size():
		chains[i].backward();
		centroid += chains[i].joints[0].global_position;
	centroid = centroid / chains.size();
	
	node.target.global_position = centroid;
	node.solve();
	
	for i in chains.size():
		chains[i].origin = node.joints[node.nJoints-1].global_position;
		chains[i].forward();

func compile_roots(node):
	if(node is classType):
		if(node.type == Enums.JointType.ROOT || node.type == Enums.JointType.SUBBASECHAIN):
			chainRoots_SubBases_SubChains.append([]);
			chainRoots.append(node);
			curRoot+=1;
			compile_bases(node);
			if(chainRoots_SubBases_SubChains[curRoot].size() == 0):
				chainRoots_SubBases_SubChains.pop_back();
				chainRoots.pop_back();
				curRoot -= 1;
			curBase = -1;
		for child in node.get_children():
			compile_roots(child);

func compile_bases(node):
	if(node is classType):
		if(node.type == Enums.JointType.SUBBASE):
			chainRoots_SubBases_SubChains[curRoot].append([]);
			curBase+=1;
			for child in node.get_children():
				if(child.type == Enums.JointType.SUBBASECHAIN):
					chainRoots_SubBases_SubChains[curRoot][curBase].append(child);
		else:
			for child in node.get_children():
				compile_bases(child);