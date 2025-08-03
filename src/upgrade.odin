package game

import "core:math/rand"
import rl "vendor:raylib"

upgrades: [total_upgrades]i32
perm_upgrades: [total_upgrades]i32
perm_upgrade_cost: [total_upgrades]i32
upgrade_cost: [total_upgrades]i32

upgrade_shuffle: [dynamic]UpgradeType

total_upgrades :: 9
UpgradeType :: enum i32 {
	Move_Speed = 0,
	Health_Regen,
	Max_Health,
	Cross_Gun,
	Loop_Gun,
	Bomb_Gun,
	Everywhere_Gun,
	Gem_Bonus,
	Boss_Debuff,
}

init_upgrades :: proc() {
	perm_upgrades[UpgradeType.Cross_Gun] = 1
	for u in UpgradeType {
		append(&upgrade_shuffle, u)
	}

	//put inital upgrades here
	upgrade_shuffle[0] = .Cross_Gun
	upgrade_shuffle[3] = .Move_Speed
	upgrade_shuffle[2] = .Bomb_Gun
	upgrade_shuffle[5] = .Max_Health


	perm_upgrade_cost[UpgradeType.Move_Speed] = 70
	perm_upgrade_cost[UpgradeType.Health_Regen] = 20
	perm_upgrade_cost[UpgradeType.Max_Health] = 30
	perm_upgrade_cost[UpgradeType.Cross_Gun] = 50
	perm_upgrade_cost[UpgradeType.Loop_Gun] = 60
	perm_upgrade_cost[UpgradeType.Bomb_Gun] = 100
	perm_upgrade_cost[UpgradeType.Everywhere_Gun] = 40
	perm_upgrade_cost[UpgradeType.Gem_Bonus] = 90
	perm_upgrade_cost[UpgradeType.Boss_Debuff] = 200

	upgrade_cost[UpgradeType.Move_Speed] = 20
	upgrade_cost[UpgradeType.Health_Regen] = 3
	upgrade_cost[UpgradeType.Max_Health] = 5
	upgrade_cost[UpgradeType.Cross_Gun] = 10
	upgrade_cost[UpgradeType.Loop_Gun] = 20
	upgrade_cost[UpgradeType.Bomb_Gun] = 40
	upgrade_cost[UpgradeType.Everywhere_Gun] = 20
	upgrade_cost[UpgradeType.Gem_Bonus] = 40
	upgrade_cost[UpgradeType.Boss_Debuff] = 100
}

get_upgrade_name :: proc(upgrade: UpgradeType) -> cstring {
	switch upgrade {
	case .Move_Speed:
		return "Move Speed"
	case .Health_Regen:
		return "Health Regeneration"
	case .Max_Health:
		return "Max Health"
	case .Cross_Gun:
		return "Cross Gun"
	case .Loop_Gun:
		return "Loop Gun"
	case .Bomb_Gun:
		return "Bomb Gun"
	case .Everywhere_Gun:
		return "Everywhere Gun"
	case .Gem_Bonus:
		return "Gem Bonus"
	case .Boss_Debuff:
		return "Boss Debuff"
	}

	return ""
}

generate_upgrade :: proc() {
	rand.shuffle(upgrade_shuffle[:])
}

remove_upgrade :: proc(remove: UpgradeType) {
	if len(upgrade_shuffle) <= 3 {
		return
		//TODO
	}
	for u, index in upgrade_shuffle {
		if u == remove {
			unordered_remove(&upgrade_shuffle, index)
			return
		}
	}
}

has_money :: proc(i: i32) -> bool {
	return player.gems >= upgrade_cost[upgrade_shuffle[i]]
}

money_color :: proc(i: i32) -> rl.Color {
	if has_money(i) {
		return rl.GREEN
	} else {
		return rl.GRAY
	}
}

has_money_perm :: proc(i: i32) -> bool {
	return player.gems >= perm_upgrade_cost[i]
}

money_color_perm :: proc(i: i32) -> rl.Color {
	if has_money_perm(i) {
		return rl.GREEN
	} else {
		return rl.GRAY
	}
}
