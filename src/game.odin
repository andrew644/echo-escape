package game

import "core:strconv"
import rl "vendor:raylib"

camera_pos_offset: rl.Vector3 : {0, 20, 9}
player_pos_start: rl.Vector3 : {0, 0, 0}
player_radius: f32 : 1
player_move_speed: f32 : 5

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
}

init :: proc() {
	run = true
	rl.SetConfigFlags({.VSYNC_HINT, .MSAA_4X_HINT})
	rl.InitWindow(game_width, game_height, "Game")
	rl.InitAudioDevice()
	rl.SetTargetFPS(60)

	player.pos = player_pos_start
	player.health = 100

	set_player_pos(player_pos_start)
	camera.up = {0, 1, 0}
	camera.fovy = 90
	camera.projection = rl.CameraProjection.PERSPECTIVE

	spawn_enemy_r(.Box, 30)
	spawn_enemy_r(.Box, 20)
	spawn_enemy_r(.Box, 40)
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
		remove_dead_enemies()
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
			rl.ClearBackground({33, 33, 200, 255})

			rl.BeginMode3D(camera)
			{
				rl.DrawGrid(70, 10)
				rl.DrawPlane(rl.Vector3(0), {10, 10}, rl.WHITE)
				rl.DrawCapsule(
					player.pos,
					player.pos + rl.Vector3({0, 3, 0}),
					player_radius,
					10,
					10,
					rl.BLACK,
				)

				for e in enemies {
					rl.DrawCube(e.pos, 1, 1, 1, rl.GRAY)
				}
				for b in bullets {
					rl.DrawSphere(b.pos, b.radius, rl.RED)
				}
			}
			rl.EndMode3D()

			rl.DrawFPS(900, 10)
			buf: [32]u8
			strconv.itoa(buf[:], int(player.health))
			rl.DrawText("Health:", 10, 10, 50, rl.GREEN)
			rl.DrawText(cstring(raw_data(buf[:])), 200, 10, 50, rl.GREEN)
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
