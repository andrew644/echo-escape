package game

import "core:strconv"
import rl "vendor:raylib"

camera_pos_offset: rl.Vector3 : {0, 20, 9}
player_pos_start: rl.Vector3 : {0, 0, 0}
player_radius: f32 : 1
player_move_speed: f32 : 5

level: i32 = 1
time_per_level: f32 : 60
level_timer: f32 = time_per_level

game_width :: 1024
game_height :: 576

run: bool
camera: rl.Camera
player: Player
scene: Scene = .Game

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

	perm_upgrades[UpgradeType.Cross_Gun] = 1
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
		remove_dead_enemies()
		auto_spawn(delta_t)
		process_level_timer(delta_t)
	case .Upgrade:
	case .Perm_Upgrade:
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

draw :: proc() {
	rl.BeginDrawing()
	{
		switch scene {
		case .Menu:
			draw_menu()
		case .Game:
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
		case .Upgrade:
		case .Perm_Upgrade:
		case .Joke:
			draw_menu()
			rl.DrawRectangle(150, 200, 700, 200, rl.BLACK)
			rl.DrawText("deal with it", 200, 250, 110, rl.RED)
		}
	}
	rl.EndDrawing()
}

draw_menu :: proc() {
	rl.ClearBackground({25, 25, 20, 255})
	rl.DrawText("Echo Escape", (game_width / 2) - 300, 10, 90, rl.GREEN)
	rl.DrawText("Start Game", (game_width / 2) - 300, 140, 90, rl.GREEN)
	rl.DrawText("(Press Enter)", (game_width / 2) - 200, 230, 30, rl.GREEN)
	rl.DrawText("For better user interface press z", 20, 530, 20, rl.GREEN)
	rl.DrawText("An Andrew Shearer Game", 750, 530, 20, rl.GREEN)
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

	new_pos.x += direction.x * player_move_speed * delta_t
	new_pos.z += direction.z * player_move_speed * delta_t
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
	level_timer = time_per_level
}
