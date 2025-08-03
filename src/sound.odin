package game

import rl "vendor:raylib"

sound_die: rl.Sound
sound_coin: rl.Sound
sound_everywhere: rl.Sound
sound_bombe: rl.Sound
sound_bombp: rl.Sound
sound_loop: rl.Sound
sound_cross1: rl.Sound
sound_cross2: rl.Sound
sound_cross3: rl.Sound
sound_cross4: rl.Sound
sound_en_die: rl.Sound
sound_gem: rl.Sound
sound_start: rl.Sound
sound_player_hit: rl.Sound

load_sound :: proc() {
	sound_die = rl.LoadSound("assets/die.ogg")
	sound_coin = rl.LoadSound("assets/coin.ogg")
	sound_everywhere = rl.LoadSound("assets/everywhere.ogg")
	sound_bombe = rl.LoadSound("assets/bombe.ogg")
	sound_bombp = rl.LoadSound("assets/bombp.ogg")
	sound_loop = rl.LoadSound("assets/loop.ogg")
	sound_cross1 = rl.LoadSound("assets/cross.wav")
	sound_cross2 = rl.LoadSound("assets/cross2.wav")
	sound_cross3 = rl.LoadSound("assets/cross3.wav")
	sound_cross4 = rl.LoadSound("assets/cross4.wav")
	sound_en_die = rl.LoadSound("assets/en_die.wav")
	sound_gem = rl.LoadSound("assets/gem.wav")
	sound_start = rl.LoadSound("assets/start.ogg")
	sound_player_hit = rl.LoadSound("assets/player_hit.wav")
}
