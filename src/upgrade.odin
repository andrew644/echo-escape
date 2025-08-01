package game

import "core:math/rand"

upgrades: [total_upgrades]i32
perm_upgrades: [total_upgrades]i32

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
	generate_upgrade()
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
