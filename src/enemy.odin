package game

import "core:math"
import "core:math/rand"
import "core:slice"
import rl "vendor:raylib"

max_enemies: i32 = 100
enemy_spawn_distance: f32 = 100
enemy_attack_cooldown: f32 = 1

spawn_timer: f32 = 0

cube_enemy_radius: f32 : 0.5

boss_alive: bool = false

EnemyType :: enum {
	Box,
	Big_Box,
	Cap,
	Boss,
}

Enemy :: struct {
	pos:             rl.Vector3,
	health:          i32,
	speed:           f32,
	radius:          f32,
	type:            EnemyType,
	attack_cooldown: f32,
	attack:          i32,
}

get_spawn_rate :: proc() -> f32 {
	switch level {
	case 1:
		return 1
	case 2:
		return .8
	case 3:
		return .5
	case 4:
		return .3
	case 5:
		return .2
	case 6:
		return .1
	case 7:
		return .1
	case 8:
		return .1
	case 9:
		return .1
	case 10:
		return .1
	}

	return 1
}

auto_spawn :: proc(delta_t: f32) {
	if spawn_timer > 0 {
		spawn_timer -= delta_t
		return
	}

	spawn_timer = get_spawn_rate()

	switch level {
	case 1:
		spawn_enemy(.Box)
	case 2:
		spawn_enemy(.Box)
	case 3:
		if player.gems % 2 == 0 {
			spawn_enemy(.Box)
		} else {
			spawn_enemy(.Big_Box)
		}
	case 4:
		if player.gems % 2 == 0 {
			spawn_enemy(.Box)
		} else {
			spawn_enemy(.Big_Box)
		}
	case 5:
		spawn_enemy(.Big_Box)
	case 6:
		spawn_enemy(.Big_Box)
	case 7:
		if player.gems % 2 == 0 {
			spawn_enemy(.Cap)
		} else {
			spawn_enemy(.Big_Box)
		}
	case 8:
		if player.gems % 2 == 0 {
			spawn_enemy(.Cap)
		} else {
			spawn_enemy(.Big_Box)
		}
	case 9:
		spawn_enemy(.Cap)
	case 10:
		spawn_enemy(.Cap)
	}
}

spawn_enemy :: proc(type: EnemyType) {
	spawn_enemy_r(type, enemy_spawn_distance)
}

spawn_enemy_r :: proc(type: EnemyType, distance_from_player: f32) {
	if i32(len(enemies)) >= max_enemies {
		return
	}

	radius: f32
	switch type {
	case .Box:
		radius = cube_enemy_radius
	case .Big_Box:
		radius = 1
	case .Cap:
		radius = 2
	case .Boss:
		radius = 7
	}
	attack: i32
	switch type {
	case .Box:
		attack = 10
	case .Big_Box:
		attack = 20
	case .Cap:
		attack = 30
	case .Boss:
		attack = 50
	}
	speed: f32
	switch type {
	case .Box:
		speed = 2.5
	case .Big_Box:
		speed = 3
	case .Cap:
		speed = 5
	case .Boss:
		speed = 6
	}
	health: i32
	switch type {
	case .Box:
		health = 10
	case .Big_Box:
		health = 20
	case .Cap:
		health = 50
	case .Boss:
		health = 300
	}
	e: Enemy
	e.health = health
	e.pos = random_point_circle(player.pos, distance_from_player)
	e.type = type
	e.speed = speed
	e.radius = radius
	e.attack_cooldown = 0
	e.attack = attack

	append(&enemies, e)
}

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
	for &e in enemies {
		if e.attack_cooldown > 0 {
			continue
		}

		collision := rl.CheckCollisionCircles(player_pos, player_radius, e.pos.xz, e.radius)
		if collision {
			player.health -= e.attack
			e.attack_cooldown = enemy_attack_cooldown
			rl.PlaySound(sound_player_hit)
		}
	}
}

remove_dead_enemies :: proc() {
	enemies_to_remove := make(map[int]int, context.temp_allocator)

	for e, index in enemies {
		//remove dead enemies
		if e.health <= 0 {
			enemies_to_remove[index] = index
			spawn_gem(e.pos, .Red)
			if e.type == .Boss {
				scene = .Win
			}

		}
		//remove enemies that are too far away
		if rl.Vector2Distance(e.pos.xz, player.pos.xz) > 200 {
			enemies_to_remove[index] = index
		}
	}


	sorted_remove := make([dynamic]int, context.temp_allocator)
	for k, _ in enemies_to_remove {
		append(&sorted_remove, k)
	}
	slice.reverse_sort(sorted_remove[:])
	for r in sorted_remove {
		unordered_remove(&enemies, r)
	}

	if len(enemies_to_remove) > 0 {
		rl.PlaySound(sound_en_die)
	}
}

spawn_boss :: proc() {
	debuf := upgrades[UpgradeType.Boss_Debuff]
	e: Enemy
	if debuf >= 1 {
		e.health = 300
	} else {
		e.health = 500
	}
	e.pos = random_point_circle(player.pos, enemy_spawn_distance)
	e.type = .Boss
	if debuf >= 2 {
		e.speed = 2.5
	} else {
		e.speed = 3.5
	}
	e.radius = 7
	e.attack_cooldown = 0
	if debuf >= 3 {
		e.attack = 30
	} else {
		e.attack = 100
	}

	boss_alive = true

	append(&enemies, e)
}
