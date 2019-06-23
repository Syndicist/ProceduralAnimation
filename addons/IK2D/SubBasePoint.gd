extends Bone2D

export(int) var length = 0;
export(int) var type = TYPE.SUBBP;
enum TYPE {ROOT, JOINT, SUBBP, SUBBC, END}