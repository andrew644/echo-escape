package game

import "core:c"
import rl "vendor:raylib"

move_speed: f32 : 5
camera_pos_offset: rl.Vector3 : {0, 20, 11}
player_pos_start: rl.Vector3 : {0, 0, 0}

run: bool
camera: rl.Camera
player: Player

Player :: struct {
	pos: rl.Vector3,
}

init :: proc() {
	run = true
	rl.SetConfigFlags({.WINDOW_RESIZABLE, .VSYNC_HINT, .MSAA_4X_HINT})
	rl.InitWindow(1000, 1000, "Game")
	rl.InitAudioDevice()
	rl.SetTargetFPS(60)

	player.pos = player_pos_start

	set_player_pos(player_pos_start)
	camera.up = {0, 1, 0}
	camera.fovy = 90
	camera.projection = rl.CameraProjection.PERSPECTIVE

}

update :: proc() {
	rl.BeginDrawing()
	{
		rl.ClearBackground({33, 33, 200, 255})

		rl.BeginMode3D(camera)
		{
			rl.DrawGrid(70, 10)
			rl.DrawPlane(rl.Vector3(0), {10, 10}, rl.WHITE)
			rl.DrawCube(player.pos + rl.Vector3({0, 1, 0}), 2, 2, 2, rl.GRAY)
		}
		rl.EndMode3D()

		rl.DrawFPS(10, 10)
	}
	rl.EndDrawing()

	delta_t := rl.GetFrameTime()
	new_pos := player.pos
	if rl.IsKeyDown(.W) {
		new_pos.z -= move_speed * delta_t
	} else if rl.IsKeyDown(.S) {
		new_pos.z += move_speed * delta_t
	}
	if rl.IsKeyDown(.A) {
		new_pos.x -= move_speed * delta_t
	} else if rl.IsKeyDown(.D) {
		new_pos.x += move_speed * delta_t
	}
	set_player_pos(new_pos)

	free_all(context.temp_allocator)
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
