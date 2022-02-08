extends Node

enum PlayerState { 
	PICK, 
	PLACE, 
	EDIT
}

enum StateType { 
	TURRET, 
	ATTACH, 
	PATH,
	VOXEL,
	TARGETING
	MODULES
	MODULES_PICK
}

enum PlayerActions { 
	CHANGE_TYPE,
	PICK,
	PLACE,
	SELECT, 
	DELETE, 
	CANCEL,
	EDIT
}
