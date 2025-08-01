package game

import "core:strconv"
import rl "vendor:raylib"

camera_pos_offset: rl.Vector3 : {0, 20, 9}
player_pos_start: rl.Vector3 : {0, 0, 0}
player_radius: f32 : 1

level: i32 = 1
time_per_level: f32 : 60
level_timer: f32 = time_per_level

game_width :: 1024
game_height :: 576

run: bool
camera: rl.Camera
player: Player
scene: Scene = .Menu

joke_timer: f32 = 1

Scene :: enum {
	Menu,
	Game,
	Upgrade,
	Perm_Upgrade,
	Joke,
}

enemies: [dynamic]Enemy

Player :: struct {
	pos:    rl.Vector3,
	health: i32,
	gems:   i32,
}

init :: proc() {
	run = true
	rl.SetConfigFlags({.VSYNC_HINT, .MSAA_4X_HINT})
	rl.InitWindow(game_width, game_height, "Echo Escape")
	rl.InitAudioDevice()
	rl.SetTargetFPS(60)

	camera.up = {0, 1, 0}
	camera.fovy = 90
	camera.projection = rl.CameraProjection.PERSPECTIVE

	load_shader()

	init_upgrades()
	start_run()
}

start_run :: proc() {
	for &u, i in upgrades {
		u = perm_upgrades[i]
	}

	player.pos = player_pos_start
	set_player_pos(player_pos_start)

	player.health = 100
	player.gems = 0

	spawn_enemy_r(.Box, 30)
	spawn_enemy_r(.Box, 20)
	spawn_enemy_r(.Box, 40)
	spawn_enemy_r(.Box, 50)
	spawn_enemy_r(.Box, 70)
	spawn_enemy_r(.Box, 70)
	spawn_enemy_r(.Box, 70)
	spawn_enemy(.Box)
	spawn_enemy(.Box)
	spawn_enemy(.Box)
	spawn_enemy(.Box)
	spawn_enemy(.Box)
	spawn_enemy(.Box)
	spawn_enemy(.Box)
	spawn_enemy(.Box)
	spawn_enemy(.Box)
	spawn_enemy(.Box)
	spawn_enemy(.Box)
	spawn_enemy(.Box)
	spawn_enemy(.Box)

}

update :: proc() {
	delta_t := rl.GetFrameTime()
	switch scene {
	case .Menu:
		draw()
		if rl.IsKeyDown(.ENTER) {
			scene = .Game
		}
		if rl.IsKeyDown(.Z) {
			scene = .Joke
		}
	case .Game:
		draw()
		controls(delta_t)
		move_enemies(delta_t)
		enemy_player_collision()
		attack_cooldown_enemies(delta_t)
		process_bullets(delta_t)
		process_gems()
		regen_player(delta_t)
		remove_dead_enemies()
		auto_spawn(delta_t)
		process_level_timer(delta_t)
	case .Upgrade:
		draw()
		if rl.IsKeyDown(.ONE) {
			upgrade_selected(0)
		} else if rl.IsKeyDown(.TWO) {
			upgrade_selected(1)
		} else if rl.IsKeyDown(.THREE) {
			upgrade_selected(2)
		}
	case .Perm_Upgrade:
		draw()
	case .Joke:
		joke_timer -= delta_t
		if joke_timer <= 0 {
			scene = .Menu
			joke_timer = 1
		}
		draw()
	}

	free_all(context.temp_allocator)
}

upgrade_selected :: proc(i: i32) {
	upgrade: UpgradeType = upgrade_shuffle[i]
	upgrades[upgrade] += 1
	scene = .Game
}

draw :: proc() {
	rl.BeginDrawing()
	{
		switch scene {
		case .Menu:
			draw_menu()
		case .Game:
			draw_game()
			if rl.IsKeyDown(.TAB) {
				draw_upgrade_menu()
			}
		case .Upgrade:
			draw_game()
			draw_upgrade()
			if rl.IsKeyDown(.TAB) {
				draw_upgrade_menu()
			}
		case .Perm_Upgrade:
		case .Joke:
			draw_menu()
			rl.DrawRectangle(150, 200, 700, 200, rl.BLACK)
			rl.DrawText("deal with it", 200, 250, 110, rl.RED)
		}
	}
	rl.EndDrawing()
}

draw_upgrade_menu :: proc() {
	buf: [32]u8
	rl.DrawRectangle(50, 50, 300, 230, rl.BLACK)
	rl.DrawText(get_upgrade_name(.Move_Speed), 80, 60, 20, rl.GREEN)
	strconv.itoa(buf[:], int(upgrades[0]))
	rl.DrawText(cstring(raw_data(buf[:])), 60, 60, 20, rl.GREEN)

	rl.DrawText(get_upgrade_name(.Health_Regen), 80, 80, 20, rl.GREEN)
	strconv.itoa(buf[:], int(upgrades[1]))
	rl.DrawText(cstring(raw_data(buf[:])), 60, 80, 20, rl.GREEN)

	rl.DrawText(get_upgrade_name(.Max_Health), 80, 100, 20, rl.GREEN)
	strconv.itoa(buf[:], int(upgrades[2]))
	rl.DrawText(cstring(raw_data(buf[:])), 60, 100, 20, rl.GREEN)

	rl.DrawText(get_upgrade_name(.Cross_Gun), 80, 120, 20, rl.GREEN)
	strconv.itoa(buf[:], int(upgrades[3]))
	rl.DrawText(cstring(raw_data(buf[:])), 60, 120, 20, rl.GREEN)

	rl.DrawText(get_upgrade_name(.Loop_Gun), 80, 140, 20, rl.GREEN)
	strconv.itoa(buf[:], int(upgrades[4]))
	rl.DrawText(cstring(raw_data(buf[:])), 60, 140, 20, rl.GREEN)

	rl.DrawText(get_upgrade_name(.Bomb_Gun), 80, 160, 20, rl.GREEN)
	strconv.itoa(buf[:], int(upgrades[5]))
	rl.DrawText(cstring(raw_data(buf[:])), 60, 160, 20, rl.GREEN)

	rl.DrawText(get_upgrade_name(.Everywhere_Gun), 80, 180, 20, rl.GREEN)
	strconv.itoa(buf[:], int(upgrades[6]))
	rl.DrawText(cstring(raw_data(buf[:])), 60, 180, 20, rl.GREEN)

	rl.DrawText(get_upgrade_name(.Gem_Bonus), 80, 200, 20, rl.GREEN)
	strconv.itoa(buf[:], int(upgrades[7]))
	rl.DrawText(cstring(raw_data(buf[:])), 60, 200, 20, rl.GREEN)

	rl.DrawText(get_upgrade_name(.Boss_Debuff), 80, 220, 20, rl.GREEN)
	strconv.itoa(buf[:], int(upgrades[8]))
	rl.DrawText(cstring(raw_data(buf[:])), 60, 220, 20, rl.GREEN)
}

draw_menu :: proc() {
	rl.ClearBackground({25, 25, 20, 255})
	rl.DrawText("Echo Escape", (game_width / 2) - 300, 10, 90, rl.GREEN)
	rl.DrawText("Start Game", (game_width / 2) - 300, 140, 90, rl.GREEN)
	rl.DrawText("(Press Enter)", (game_width / 2) - 200, 230, 30, rl.GREEN)
	rl.DrawText("For better user interface press z", 20, 530, 20, rl.GREEN)
	rl.DrawText("An Andrew Shearer Game", 750, 530, 20, rl.GREEN)
}

draw_game :: proc() {
	/*
	camera_pos := camera.position
	rl.SetShaderValue(
		shader,
		shader.locs[rl.ShaderLocationIndex.VECTOR_VIEW],
		&camera_pos,
		rl.ShaderUniformDataType.VEC3,
	)
	*/

	rl.ClearBackground({33, 33, 200, 255})

	rl.BeginMode3D(camera)
	{
		rl.BeginShaderMode(shader)
		{
			rl.DrawGrid(70, 10)
			rl.DrawPlane(rl.Vector3({0, -0.1, 0}), {1000, 1000}, rl.BLACK)
			rl.DrawCapsule(
				player.pos,
				player.pos + rl.Vector3({0, 3, 0}),
				player_radius,
				10,
				10,
				rl.DARKGRAY,
			)

			for e in enemies {
				rl.DrawCube(e.pos, 1, 1, 1, rl.GRAY)
			}
			for b in bullets {
				rl.DrawSphere(b.pos, b.radius, rl.LIGHTGRAY)
			}
			for g in gems {
				rl.DrawSphere(g.pos, g.radius, rl.RED)
			}
		}
		rl.EndShaderMode()
	}
	rl.EndMode3D()

	rl.DrawFPS(900, 10)
	buf: [32]u8
	strconv.itoa(buf[:], int(player.health))
	rl.DrawText("Health:", 10, 10, 40, rl.GREEN)
	rl.DrawText(cstring(raw_data(buf[:])), 170, 10, 40, rl.GREEN)
	buf_gem: [32]u8
	strconv.itoa(buf_gem[:], int(player.gems))
	rl.DrawText("Ð:", 10, 50, 40, rl.GREEN)
	rl.DrawText(cstring(raw_data(buf_gem[:])), 55, 50, 40, rl.GREEN)
}

draw_upgrade :: proc() {
	rl.DrawRectangle(50, 50, game_width - 100, game_height - 100, rl.BLACK)
	rl.DrawText("Upgrade Time", 380, 70, 40, rl.GREEN)
	rl.DrawText("Press '1'", 70, 190, 20, rl.GREEN)
	rl.DrawText("Press '2'", 374, 190, 20, rl.GREEN)
	rl.DrawText("Press '3'", 678, 190, 20, rl.GREEN)
	rl.DrawRectangle(60, 220, 294, 200, rl.DARKGREEN)
	rl.DrawRectangle(364, 220, 294, 200, rl.DARKGREEN)
	rl.DrawRectangle(668, 220, 294, 200, rl.DARKGREEN)
	rl.DrawText(get_upgrade_name(upgrade_shuffle[0]), 70, 300, 20, rl.BLACK)
	rl.DrawText(get_upgrade_name(upgrade_shuffle[1]), 374, 300, 20, rl.BLACK)
	rl.DrawText(get_upgrade_name(upgrade_shuffle[2]), 678, 300, 20, rl.BLACK)
}

controls :: proc(delta_t: f32) {
	new_pos := player.pos
	direction: rl.Vector3 = rl.Vector3(0)
	if rl.IsKeyDown(.W) || rl.IsKeyDown(.UP) {
		direction.z -= 1
	}
	if rl.IsKeyDown(.A) || rl.IsKeyDown(.LEFT) {
		direction.x -= 1
	}
	if rl.IsKeyDown(.S) || rl.IsKeyDown(.DOWN) {
		direction.z += 1
	}
	if rl.IsKeyDown(.D) || rl.IsKeyDown(.RIGHT) {
		direction.x += 1
	}

	if rl.Vector3Length(direction) > 0 {
		direction = rl.Vector3Normalize(direction)
	}

	new_pos.x += direction.x * get_player_move_speed() * delta_t
	new_pos.z += direction.z * get_player_move_speed() * delta_t
	set_player_pos(new_pos)
}

set_player_pos :: proc(pos: rl.Vector3) {
	camera.position = camera_pos_offset + pos
	camera.target = pos
	player.pos = pos
}

parent_window_size_changed :: proc(width, height: int) {
	//rl.SetWindowSize(c.int(width), c.int(height))
}

shutdown :: proc() {
	rl.UnloadShader(shader)
	rl.CloseWindow()
}

should_run :: proc() -> bool {
	when ODIN_OS != .JS {
		if rl.WindowShouldClose() {
			run = false
		}
	}

	return run
}

process_level_timer :: proc(delta_t: f32) {
	if level_timer > 0 {
		level_timer -= delta_t
		return
	}

	level += 1
	scene = .Upgrade
	generate_upgrade()
	level_timer = time_per_level
}
