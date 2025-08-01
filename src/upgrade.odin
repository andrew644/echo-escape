package game

/*
import "core:math"
import "core:math/rand"
import rl "vendor:raylib"
*/

upgrades: [UpgradeType.Total_Upgrades]i32
perm_upgrades: [UpgradeType.Total_Upgrades]i32

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
	Total_Upgrades,
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
	case .Total_Upgrades:
		return "error"
	}

	return ""
}
