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
	VOXEL_PALETTE
	TARGETING
	MODULES
}

enum PlayerActions { 
	CHANGE_TYPE,
	PICK,
	PLACE,
	SELECT, 
	DELETE, 
	CANCEL
}
