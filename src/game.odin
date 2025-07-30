package game

import "core:c"
import rl "vendor:raylib"

move_speed: f32 : 5
camera_pos_offset: rl.Vector3 : {0, 20, 11}
player_pos_start: rl.Vector3 : {0, 0, 0}

run: bool
camera: rl.Camera
player: Player


enemies: [dynamic]Enemy

Player :: struct {
	pos:    rl.Vector3,
	health: i32,
}

init :: proc() {
	run = true
	rl.SetConfigFlags({.WINDOW_RESIZABLE, .VSYNC_HINT, .MSAA_4X_HINT})
	rl.InitWindow(1000, 1000, "Game")
	rl.InitAudioDevice()
	rl.SetTargetFPS(60)

	player.pos = player_pos_start
	player.health = 100

	set_player_pos(player_pos_start)
	camera.up = {0, 1, 0}
	camera.fovy = 90
	camera.projection = rl.CameraProjection.PERSPECTIVE

	spawn_enemy(rl.Vector3({0, 0, 10}))
	spawn_enemy(rl.Vector3({5, 0, 10}))
}

update :: proc() {
	delta_t := rl.GetFrameTime()
	draw()
	controls(delta_t)
	move_enemies(delta_t)

	free_all(context.temp_allocator)
}

draw :: proc() {
	rl.BeginDrawing()
	{
		rl.ClearBackground({33, 33, 200, 255})

		rl.BeginMode3D(camera)
		{
			rl.DrawGrid(70, 10)
			rl.DrawPlane(rl.Vector3(0), {10, 10}, rl.WHITE)
			rl.DrawCapsule(player.pos, player.pos + rl.Vector3({0, 3, 0}), 1, 10, 10, rl.BLACK)

			for e in enemies {
				rl.DrawCube(e.pos, 1, 1, 1, rl.GRAY)
			}
		}
		rl.EndMode3D()

		rl.DrawFPS(10, 10)
	}
	rl.EndDrawing()
}

controls :: proc(delta_t: f32) {
	new_pos := player.pos
	direction: rl.Vector3 = rl.Vector3(0)
	if rl.IsKeyDown(.W) {
		direction.z -= 1
	}
	if rl.IsKeyDown(.A) {
		direction.x -= 1
	}
	if rl.IsKeyDown(.S) {
		direction.z += 1
	}
	if rl.IsKeyDown(.D) {
		direction.x += 1
	}

	if rl.Vector3Length(direction) > 0 {
		direction = rl.Vector3Normalize(direction)
	}

	new_pos.x += direction.x * move_speed * delta_t
	new_pos.z += direction.z * move_speed * delta_t
	set_player_pos(new_pos)
}

set_player_pos :: proc(pos: rl.Vector3) {
	camera.position = camera_pos_offset + pos
	camera.target = pos
	player.pos = pos
}

parent_window_size_changed :: proc(width, height: int) {
	rl.SetWindowSize(c.int(width), c.int(height))
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
