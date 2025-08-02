package game


everywhere_cooldown_max: f32 = 5
everywhere_cooldown: f32 = everywhere_cooldown_max

process_everywhere :: proc(delta_t: f32) {
	if upgrades[UpgradeType.Everywhere_Gun] <= 0 {
		return
	}

	everywhere_cooldown -= delta_t
	if everywhere_cooldown <= 0 {
		everywhere_cooldown = everywhere_cooldown_max

		for &e in enemies {
			e.health -= get_everywhere_damage()
		}
	}
}

get_everywhere_damage :: proc() -> i32 {
	switch upgrades[UpgradeType.Everywhere_Gun] {
	case 0:
		return 0
	case 1:
		return 1
	case 2:
		return 5
	case 3:
		return 10
	}

	return 1
}
