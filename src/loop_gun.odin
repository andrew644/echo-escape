package game

import rl "vendor:raylib"

loopgun_cooldown_max: f32 = 3
loopgun_cooldown: f32 = loopgun_cooldown_max

loopgun_thickness: f32 : 2
loopgun_damage: i32 : 10
loopgun_radius_1: f32 : 10
loopgun_radius_2: f32 : 15
loopgun_radius_3: f32 : 17

loopgun_show_cooldown_max: f32 = 0.15
loopgun_show_cooldown: f32 = 0

process_loopgun :: proc(delta_t: f32) {
	if upgrades[UpgradeType.Loop_Gun] <= 0 {
		return
	}

	loopgun_cooldown -= delta_t
	if loopgun_cooldown <= 0 {
		rl.PlaySound(sound_loop)
		loopgun_cooldown = loopgun_cooldown_max
		if loopgun_show_cooldown <= 0 {
			loopgun_show_cooldown = loopgun_show_cooldown_max
		}

		rings := loopgun_rings()
		for &e in enemies {
			if rings >= 1 {
				if rl.CheckCollisionCircles(e.pos.xz, e.radius, player.pos.xz, loopgun_radius_1) &&
				   !rl.CheckCollisionCircles(
						   e.pos.xz,
						   e.radius,
						   player.pos.xz,
						   loopgun_radius_1 - loopgun_thickness,
					   ) {
					e.health -= loopgun_damage
				}
			}
			if rings >= 2 {
				if rl.CheckCollisionCircles(e.pos.xz, e.radius, player.pos.xz, loopgun_radius_2) &&
				   !rl.CheckCollisionCircles(
						   e.pos.xz,
						   e.radius,
						   player.pos.xz,
						   loopgun_radius_2 - loopgun_thickness,
					   ) {
					e.health -= loopgun_damage
				}
			}
			if rings >= 3 {
				if rl.CheckCollisionCircles(e.pos.xz, e.radius, player.pos.xz, loopgun_radius_3) &&
				   !rl.CheckCollisionCircles(
						   e.pos.xz,
						   e.radius,
						   player.pos.xz,
						   loopgun_radius_3 - loopgun_thickness,
					   ) {
					e.health -= loopgun_damage
				}
			}
		}
	}
}

loopgun_rings :: proc() -> i32 {
	switch upgrades[UpgradeType.Loop_Gun] {
	case 0:
		return 0
	case 1:
		return 1
	case 2:
		return 2
	case 3:
		return 3
	}

	return 3
}
