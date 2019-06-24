extends Bone2D

export(Array,int) var length = [0];
export(int) var type = TYPE.END;
enum TYPE {ROOT, JOINT, SUBBP, SUBBC, END}