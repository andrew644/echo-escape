package game

import "core:strconv"
import rl "vendor:raylib"

camera_pos_offset: rl.Vector3 : {0, 20, 9}
player_pos_start: rl.Vector3 : {0, 0, 0}
player_radius: f32 : 1

level: i32 = 1
time_per_level: f32 : 60
level_timer: f32 = time_per_level

perm_upgrade_timer: f32 = 0

die_timer: f32 = die_timer_max
die_timer_max: f32 = 4

game_width :: 1024
game_height :: 576

checked_tab: bool = false

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
	Die,
	Win,
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

	load_sound()


	init_upgrades()
	start_run()
}

start_run :: proc() {
	level = 1
	boss_alive = false
	clear(&enemies)
	clear(&gems)
	clear(&bullets)
	for _, i in perm_upgrades {
		upgrades[i] = perm_upgrades[i]
	}

	player.pos = player_pos_start
	set_player_pos(player_pos_start)

	player.health = 100
	player.gems = 0

	level_timer = time_per_level

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

	rl.PlaySound(sound_start)
}

update :: proc() {
	delta_t := rl.GetFrameTime()
	switch scene {
	case .Menu:
		draw(delta_t)
		if rl.IsKeyDown(.ENTER) {
			scene = .Game
		}
		if rl.IsKeyDown(.Z) {
			scene = .Joke
		}
	case .Game:
		draw(delta_t)
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
		check_die()
	case .Upgrade:
		draw(delta_t)
		if rl.IsKeyDown(.ONE) && has_money(0) {
			upgrade_selected(0)
		} else if rl.IsKeyDown(.TWO) && has_money(1) {
			upgrade_selected(1)
		} else if rl.IsKeyDown(.THREE) && has_money(2) {
			upgrade_selected(2)
		} else if rl.IsKeyDown(.ENTER) {
			scene = .Game
		}
	case .Perm_Upgrade:
		draw(delta_t)
		if rl.IsKeyDown(.ENTER) {
			start_run()
			scene = .Game
		}
		if perm_upgrade_timer > 0 {
			perm_upgrade_timer -= delta_t
		} else {
			if rl.IsKeyDown(.ONE) && has_money_perm(0) {
				upgrade_selected_perm(0)
			} else if rl.IsKeyDown(.TWO) && has_money_perm(1) {
				upgrade_selected_perm(1)
			} else if rl.IsKeyDown(.THREE) && has_money_perm(2) {
				upgrade_selected_perm(2)
			} else if rl.IsKeyDown(.FOUR) && has_money_perm(3) {
				upgrade_selected_perm(3)
			} else if rl.IsKeyDown(.FIVE) && has_money_perm(4) {
				upgrade_selected_perm(4)
			} else if rl.IsKeyDown(.SIX) && has_money_perm(5) {
				upgrade_selected_perm(5)
			} else if rl.IsKeyDown(.SEVEN) && has_money_perm(6) {
				upgrade_selected_perm(6)
			} else if rl.IsKeyDown(.EIGHT) && has_money_perm(7) {
				upgrade_selected_perm(7)
			} else if rl.IsKeyDown(.NINE) && has_money_perm(8) {
				upgrade_selected_perm(8)
			}
		}
	case .Joke:
		joke_timer -= delta_t
		if joke_timer <= 0 {
			scene = .Menu
			joke_timer = 1
		}
		draw(delta_t)
	case .Die:
		draw(delta_t)
		die_timer -= delta_t
		if die_timer <= 0 {
			scene = .Perm_Upgrade
		}
	case .Win:
		draw(delta_t)
	}

	free_all(context.temp_allocator)
}

upgrade_selected :: proc(i: i32) {
	upgrade: UpgradeType = upgrade_shuffle[i]
	upgrades[upgrade] += 1
	if upgrades[upgrade] > 3 {
		upgrades[upgrade] = 3
	}
	player.gems -= upgrade_cost[upgrade]
	rl.PlaySound(sound_coin)
	if upgrades[upgrade] >= 3 {
		remove_upgrade(upgrade)
	}
	scene = .Game
}

upgrade_selected_perm :: proc(i: i32) {
	upgrade: UpgradeType = UpgradeType(i)
	if perm_upgrades[upgrade] >= 3 {
		return
	}
	perm_upgrades[upgrade] += 1
	player.gems -= perm_upgrade_cost[upgrade]
	perm_upgrade_timer = 0.5
	rl.PlaySound(sound_coin)
}

draw :: proc(delta_t: f32) {
	rl.BeginDrawing()
	{
		switch scene {
		case .Menu:
			draw_menu()
		case .Game:
			draw_game(delta_t)
			if rl.IsKeyDown(.TAB) {
				checked_tab = true
				draw_upgrade_menu()
			}
		case .Upgrade:
			draw_game(delta_t)
			draw_upgrade()
			if rl.IsKeyDown(.TAB) {
				draw_upgrade_menu()
			}
		case .Perm_Upgrade:
			draw_perm_upgrade_menu()
		case .Joke:
			draw_menu()
			rl.DrawRectangle(150, 200, 700, 200, rl.BLACK)
			rl.DrawText("deal with it", 200, 250, 110, rl.RED)
		case .Die:
			rl.ClearBackground(rl.BLACK)
			rl.DrawText("Looping Back...", (game_width / 2) - 300, 10, 90, rl.GREEN)
		case .Win:
			rl.ClearBackground(rl.BLACK)
			rl.DrawText("Loop Escaped!", (game_width / 2) - 330, 100, 90, rl.GREEN)
			rl.DrawText("Thanks for playing", (game_width / 2) - 350, 310, 70, rl.GREEN)
		}
	}
	rl.EndDrawing()
}

draw_perm_upgrade_menu :: proc() {
	rl.ClearBackground(rl.BLACK)
	rl.DrawText("Permanent Upgrade Time!", 270, 20, 40, rl.GREEN)
	rl.DrawText("Press 1, 2, 3, ... 9 to upgrade", 70, 90, 20, rl.GREEN)
	rl.DrawRectangle(60, 120, 494, 340, rl.DARKGREEN)

	for u, i in UpgradeType {
		draw_perm_upgrade(u, i32(140 + (i * 30)))
	}

	buf_gem: [32]u8
	strconv.itoa(buf_gem[:], int(player.gems))
	rl.DrawText("Ð:", 10, 20, 40, rl.GREEN)
	rl.DrawText(cstring(raw_data(buf_gem[:])), 55, 20, 40, rl.GREEN)

	rl.DrawText("No Money? Press Enter to skip!", 260, 470, 30, rl.GREEN)
}

draw_perm_upgrade :: proc(u: UpgradeType, y: i32) {
	buf: [32]u8
	rl.DrawText(get_upgrade_name(u), 195, y, 20, rl.BLACK)
	strconv.itoa(buf[:], int(u) + 1)
	rl.DrawText(cstring(raw_data(buf[:])), 170, y, 20, rl.BLACK)

	strconv.itoa(buf[:], int(perm_upgrade_cost[u]))
	rl.DrawText("Ð", 70, y, 20, money_color_perm(i32(u)))
	rl.DrawText(cstring(raw_data(buf[:])), 87, y, 20, money_color_perm(i32(u)))
	rl.DrawText(upgrade_level_text(perm_upgrades[u]), 440, y, 20, rl.GREEN)
}

upgrade_level_text :: proc(i: i32) -> cstring {

	switch i {
	case 0:
		return "0/3"
	case 1:
		return "1/3"
	case 2:
		return "2/3"
	case 3:
		return "3/3"
	}

	return ""
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
	rl.DrawText("Can you survive the time loop?", (game_width / 2) - 200, 100, 30, rl.GREEN)
	rl.DrawText("Start Game", (game_width / 2) - 260, 240, 90, rl.GREEN)
	rl.DrawText("(Press Enter)", (game_width / 2) - 100, 330, 30, rl.GREEN)
	rl.DrawText("For better user interface press z", 20, 530, 20, rl.GREEN)
	rl.DrawText("An Andrew Shearer Game", 750, 530, 20, rl.GREEN)
}

draw_game :: proc(delta_t: f32) {
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
				switch e.type {
				case .Box:
					rl.DrawCube(e.pos, 1, 1, 1, rl.GRAY)
				case .Big_Box:
					rl.DrawCube(e.pos, 2, 2, 2, rl.GRAY)
				case .Cap:
					rl.DrawCapsule(e.pos, e.pos + rl.Vector3({0, 4, 0}), e.radius, 10, 10, rl.GRAY)
				case .Boss:
					rl.DrawCapsule(e.pos, e.pos + rl.Vector3({0, 8, 0}), e.radius, 20, 20, rl.GRAY)
				}
			}
			for b in bullets {
				rl.DrawSphere(b.pos, b.radius, rl.LIGHTGRAY)
			}
			for g in gems {
				rl.DrawSphere(g.pos, g.radius, rl.RED)
			}
			if bomb_out {
				rl.DrawSphere(bomb_pos, bomb_radius, rl.GRAY)
			}
			if loopgun_show_cooldown > 0 {
				loopgun_show_cooldown -= delta_t
				rings := loopgun_rings()
				if rings >= 1 {

					rl.DrawCylinderWires(
						player.pos,
						loopgun_radius_1,
						loopgun_radius_1,
						3,
						15,
						rl.WHITE,
					)
				}
				if rings >= 2 {

					rl.DrawCylinderWires(
						player.pos,
						loopgun_radius_2,
						loopgun_radius_2,
						3,
						20,
						rl.WHITE,
					)
				}
				if rings >= 3 {

					rl.DrawCylinderWires(
						player.pos,
						loopgun_radius_3,
						loopgun_radius_3,
						3,
						30,
						rl.WHITE,
					)
				}
			}
			if everywhere_on_cooldown > 0 {
				everywhere_on_cooldown -= delta_t
				everywhere_size += 130 * delta_t
				rl.DrawSphereWires(player.pos, everywhere_size, 10, 10, rl.WHITE)
			}
		}
		rl.EndShaderMode()
	}
	rl.EndMode3D()

	buf: [32]u8
	strconv.itoa(buf[:], int(player.health))
	rl.DrawText("Health:", 10, 10, 40, rl.GREEN)
	rl.DrawText(cstring(raw_data(buf[:])), 170, 10, 40, rl.GREEN)
	buf_gem: [32]u8
	strconv.itoa(buf_gem[:], int(player.gems))
	rl.DrawText("Ð:", 10, 50, 40, rl.GREEN)
	rl.DrawText(cstring(raw_data(buf_gem[:])), 55, 50, 40, rl.GREEN)
	if level == 2 && checked_tab == false {
		rl.DrawText("Press Tab to check upgrade status", 10, game_height - 30, 15, rl.GREEN)
	}
}

draw_upgrade :: proc() {
	buf: [32]u8
	buf2: [32]u8
	buf3: [32]u8
	rl.DrawRectangle(50, 100, game_width - 100, game_height - 150, rl.BLACK)
	rl.DrawText("Upgrade Time", 370, 120, 40, rl.GREEN)
	rl.DrawText("Press '1'", 70, 190, 20, rl.GREEN)
	rl.DrawText("Press '2'", 374, 190, 20, rl.GREEN)
	rl.DrawText("Press '3'", 678, 190, 20, rl.GREEN)
	rl.DrawRectangle(60, 220, 294, 200, rl.DARKGREEN)
	rl.DrawRectangle(364, 220, 294, 200, rl.DARKGREEN)
	rl.DrawRectangle(668, 220, 294, 200, rl.DARKGREEN)
	rl.DrawText(get_upgrade_name(upgrade_shuffle[0]), 70, 300, 20, rl.BLACK)
	rl.DrawText(get_upgrade_name(upgrade_shuffle[1]), 374, 300, 20, rl.BLACK)
	rl.DrawText(get_upgrade_name(upgrade_shuffle[2]), 678, 300, 20, rl.BLACK)

	strconv.itoa(buf[:], int(upgrade_cost[upgrade_shuffle[0]]))
	rl.DrawText("Ð", 70, 330, 20, money_color(0))
	rl.DrawText(cstring(raw_data(buf[:])), 87, 330, 20, money_color(0))

	strconv.itoa(buf2[:], int(upgrade_cost[upgrade_shuffle[1]]))
	rl.DrawText(cstring(raw_data(buf2[:])), 391, 330, 20, money_color(1))
	rl.DrawText("Ð", 374, 330, 20, money_color(1))

	strconv.itoa(buf3[:], int(upgrade_cost[upgrade_shuffle[2]]))
	rl.DrawText(cstring(raw_data(buf3[:])), 695, 330, 20, money_color(2))
	rl.DrawText("Ð", 678, 330, 20, money_color(2))

	rl.DrawText("No Money? Press Enter to skip!", 260, 470, 30, rl.GREEN)
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
	pos := pos
	if pos.x > 350 {
		pos.x = 350
	} else if pos.x < -350 {
		pos.x = -350
	}
	if pos.z > 350 {
		pos.z = 350
	} else if pos.z < -350 {
		pos.z = -350
	}
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
	if level >= 10 {
		return
	}
	if level_timer > 0 {
		level_timer -= delta_t
		return
	}

	level += 1
	if level == 10 {
		spawn_boss()
	}
	scene = .Upgrade
	if level > 2 {
		generate_upgrade()
	}
	level_timer = time_per_level
}
