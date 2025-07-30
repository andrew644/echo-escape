package game

import rl "vendor:raylib"
import "core:c"

run: bool

init :: proc() {
	run = true
	rl.SetConfigFlags({.WINDOW_RESIZABLE, .VSYNC_HINT})
	rl.InitWindow(1000, 1000, "Game")
	rl.SetTargetFPS(60)
}

update :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground({33, 33, 200, 255})
	rl.DrawText("Hello from Odin!", 10, 100, 20, rl.RAYWHITE)
	rl.DrawFPS(10, 10)
	rl.EndDrawing()

	free_all(context.temp_allocator)
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
