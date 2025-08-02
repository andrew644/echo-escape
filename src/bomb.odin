package game

import rl "vendor:raylib"

bomb_cooldown_max: f32 = 4
bomb_cooldown: f32 = bomb_cooldown_max

bomb_explode_cooldown_max: f32 = 3
bomb_explode_cooldown: f32 = bomb_explode_cooldown_max

bomb_pos: rl.Vector3
bomb_out: bool = false

bomb_radius: f32 : 1
bomb_explode_radius: f32 : 3

process_bomb :: proc(delta_t: f32) {
	if upgrades[UpgradeType.Bomb_Gun] <= 0 {
		return
	}

	bomb_cooldown -= delta_t
	if bomb_cooldown <= 0 {
		bomb_cooldown = bomb_cooldown_max

		bomb_out = true
		bomb_pos = player.pos + rl.Vector3({0.5, 0, 0})
	}

	if bomb_out {
		bomb_explode_cooldown -= delta_t
		if bomb_explode_cooldown <= 0 {
			bomb_out = false
			bomb_explode_cooldown = bomb_explode_cooldown_max

			b: Bullet
			b.radius = bomb_explode_radius
			b.speed = rl.Vector3(0)
			b.pos = bomb_pos
			b.lifetime = 0.1
			b.damage = get_bomb_damage()
			b.type = .Dot
			append(&bullets, b)
		}
	}
}

get_bomb_damage :: proc() -> i32 {
	switch upgrades[UpgradeType.Bomb_Gun] {
	case 0:
		return 0
	case 1:
		return 40
	case 2:
		return 80
	case 3:
		return 120
	}

	return 0
}
