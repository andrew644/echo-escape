package game

import "core:math"
import "core:math/rand"
import rl "vendor:raylib"

max_enemies: i32 = 100
enemy_spawn_distance: f32 = 100
enemy_attack_cooldown: f32 = 1
enemy_attack_damage: i32 = 10

cube_enemy_radius: f32 : 1
sphere_enemy_radius: f32 : 1

EnemyType :: enum {
	Box,
	Sphere,
}

Enemy :: struct {
	pos:             rl.Vector3,
	health:          i32,
	speed:           f32,
	type:            EnemyType,
	attack_cooldown: f32,
}

spawn_enemy :: proc(type: EnemyType) {
	spawn_enemy_r(type, enemy_spawn_distance)
}

spawn_enemy_r :: proc(type: EnemyType, radius: f32) {
	if i32(len(enemies)) >= max_enemies {
		return
	}

	e: Enemy
	e.health = 10
	e.pos = random_point_circle(player.pos, radius)
	e.type = type
	e.speed = 2.5
	e.attack_cooldown = 0

	append(&enemies, e)
}

@(private = "file")
random_point_circle :: proc(center: rl.Vector3, radius: f32) -> rl.Vector3 {
	angle := rand.float32_range(0, 2 * math.PI)
	return rl.Vector3(
		{center.x + math.cos(angle) * radius, center.y, center.z + math.sin(angle) * radius},
	)
}

move_enemies :: proc(delta_t: f32) {

	for &e in enemies {
		to_player: rl.Vector3 = player.pos - e.pos
		to_player.y = 0

		if (rl.Vector3Length(to_player) > 0.1) {
			direction: rl.Vector3 = rl.Vector3Normalize(to_player)
			e.pos += direction * e.speed * delta_t
		}
	}
}

attack_cooldown_enemies :: proc(delta_t: f32) {
	for &e in enemies {
		if e.attack_cooldown > 0 {
			e.attack_cooldown -= delta_t
		}
	}
}

enemy_player_collision :: proc() {
	player_pos: rl.Vector2 = player.pos.xz
	enemy_radius: f32
	for &e in enemies {
		if e.attack_cooldown > 0 {
			continue
		}

		switch e.type {
		case .Box:
			enemy_radius = cube_enemy_radius
		case .Sphere:
			enemy_radius = sphere_enemy_radius
		}
		collision := rl.CheckCollisionCircles(player_pos, player_radius, e.pos.xz, enemy_radius)
		if collision {
			player.health -= enemy_attack_damage
			e.attack_cooldown = enemy_attack_cooldown
		}
	}
}
