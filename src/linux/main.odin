package game_linux

import "core:log"
import game ".."

main :: proc() {
	context.logger = log.create_console_logger()
	
	game.init()

	for game.should_run() {
		game.update()
	}

	game.shutdown()
}
