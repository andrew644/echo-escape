package game

import "core:slice"
import rl "vendor:raylib"

gem_radius: f32 : 0.2
gem_max: int : 100

GemType :: enum {
	Red,
}

gems: [dynamic]Gem

Gem :: struct {
	pos:    rl.Vector3,
	radius: f32,
	type:   GemType,
	points: i32,
}

spawn_gem :: proc(pos: rl.Vector3, type: GemType) {
	g: Gem
	g.pos = pos
	g.type = type
	g.radius = gem_radius

	switch type {
	case .Red:
		g.points = 1
	}

	append(&gems, g)
}

remove_gems :: proc() {
	for len(gems) > gem_max {
		ordered_remove(&gems, 0)
	}
}

process_gems :: proc() {
	gems_to_remove := make(map[int]int, context.temp_allocator)

	for g, index in gems {
		collision := rl.CheckCollisionCircles(player.pos.xz, player_radius, g.pos.xz, g.radius)
		if collision {
			gems_to_remove[index] = index
			player.gems += g.points * get_gem_bonus()
		}
	}

	sorted_remove := make([dynamic]int, context.temp_allocator)
	for k, _ in gems_to_remove {
		append(&sorted_remove, k)
	}
	slice.reverse_sort(sorted_remove[:])
	for r in sorted_remove {
		unordered_remove(&gems, r)
	}
}

get_gem_bonus :: proc() -> i32 {
	switch upgrades[UpgradeType.Gem_Bonus] {
	case 0:
		return 1
	case 1:
		return 2
	case 2:
		return 3
	case 3:
		return 5
	}

	return 1
}
