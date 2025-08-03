package game

import "core:math/rand"
import "core:slice"
import rl "vendor:raylib"

dot_radius: f32 : 0.2
dot_speed: f32 : 10

dot_cooldown_max: f32 = 1
dot_cooldown: f32 = dot_cooldown_max
dot_direction: i32 = 0
dot_lifetime: f32 : 4
dot_damage: i32 : 10

BulletType :: enum {
	Dot,
}

bullets: [dynamic]Bullet

Bullet :: struct {
	pos:      rl.Vector3,
	speed:    rl.Vector3,
	radius:   f32,
	lifetime: f32,
	damage:   i32,
	type:     BulletType,
}

get_cross_upgrade :: proc() -> f32 {
	switch upgrades[UpgradeType.Cross_Gun] {
	case 0:
		return 0
	case 1:
		return 0
	case 2:
		return 0.5
	case 3:
		return 0.8
	}

	return 0.8
}

process_bullets :: proc(delta_t: f32) {
	bullets_to_remove := make(map[int]int, context.temp_allocator)
	dot_cooldown -= delta_t

	//spawn bullets
	if dot_cooldown <= 0 {
		dot_cooldown = dot_cooldown_max - get_cross_upgrade()

		spawn_dot()
	}

	process_everywhere(delta_t)
	process_loopgun(delta_t)
	process_bomb(delta_t)

	//remove old bullets
	for &b, index in bullets {
		b.lifetime -= delta_t
		if b.lifetime <= 0 {
			bullets_to_remove[index] = index
		}
	}

	//check enemy collision with bullets
	for &e in enemies {
		for b, index in bullets {
			collision := rl.CheckCollisionCircles(e.pos.xz, e.radius, b.pos.xz, b.radius)
			if collision {
				bullets_to_remove[index] = index
				e.health -= b.damage
			}

		}
	}

	//move bullets
	for &b in bullets {
		b.pos += b.speed * delta_t
	}

	//remove bullets
	sorted_remove := make([dynamic]int, context.temp_allocator)
	for k, _ in bullets_to_remove {
		append(&sorted_remove, k)
	}
	slice.reverse_sort(sorted_remove[:])
	for r in sorted_remove {
		unordered_remove(&bullets, r)
	}
}

@(private = "file")
spawn_dot :: proc() {
	dir := dot_direction % 4
	dot_direction_vec: rl.Vector3
	switch dir {
	case 0:
		dot_direction_vec = rl.Vector3({1, 0, 0})
	case 1:
		dot_direction_vec = rl.Vector3({0, 0, 1})
	case 2:
		dot_direction_vec = rl.Vector3({-1, 0, 0})
	case 3:
		dot_direction_vec = rl.Vector3({0, 0, -1})
		// run this semi often
		remove_gems()
	}

	r_sound := rand.int31() % 4
	switch r_sound {
	case 0:
		rl.PlaySound(sound_cross1)
	case 1:
		rl.PlaySound(sound_cross2)
	case 2:
		rl.PlaySound(sound_cross3)
	case 3:
		rl.PlaySound(sound_cross4)
	}
	dot_direction += 1

	b: Bullet
	b.radius = dot_radius
	b.speed = dot_direction_vec * dot_speed
	b.pos = player.pos
	b.lifetime = dot_lifetime
	b.damage = dot_damage
	b.type = .Dot

	append(&bullets, b)

}
