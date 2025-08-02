package game

player_regen_timer: f32 = 5
player_regen_timer_max: f32 : 5

get_max_health :: proc() -> i32 {
	switch upgrades[UpgradeType.Max_Health] {
	case 0:
		return 100
	case 1:
		return 150
	case 2:
		return 200
	case 3:
		return 300
	}

	return 100
}

get_regen :: proc() -> i32 {
	switch upgrades[UpgradeType.Health_Regen] {
	case 0:
		return 1
	case 1:
		return 3
	case 2:
		return 6
	case 3:
		return 20
	}

	return 1
}

get_player_move_speed :: proc() -> f32 {
	switch upgrades[UpgradeType.Move_Speed] {
	case 0:
		return 5
	case 1:
		return 6
	case 2:
		return 7
	case 3:
		return 8
	}

	return 5
}

regen_player :: proc(delta_t: f32) {
	if player_regen_timer > 0 {
		player_regen_timer -= delta_t
		return
	}

	player_regen_timer = player_regen_timer_max
	player.health += get_regen()
	if player.health > get_max_health() {
		player.health = get_max_health()
	}
}
