package game

import rl "vendor:raylib"

EnemyType :: enum {
	Box,
	Sphere,
}

Enemy :: struct {
	pos:    rl.Vector3,
	health: i32,
	speed:  f32,
	type:   EnemyType,
}

spawn_enemy :: proc(offset: rl.Vector3) {
	e: Enemy
	e.health = 10
	e.pos = player.pos + offset
	e.type = .Box
	e.speed = 5

	append(&enemies, e)
}

move_enemies :: proc(delta_t: f32) {

	for &e in enemies {
		to_player: rl.Vector3 = player.pos - e.pos
		to_player.y = 0

		if (rl.Vector3Length(to_player) > 0.1) {
			direction: rl.Vector3 = rl.Vector3Normalize(to_player)
			e.pos = e.pos + direction * e.speed * delta_t
		}
	}
}
