package game

import "core:strconv"
import "core:strings"
import rl "vendor:raylib"

log_int :: proc(i: i32) {
	buf: [32]byte
	str := strconv.itoa(buf[:], int(i))
	rl.TraceLog(rl.TraceLogLevel.INFO, strings.clone_to_cstring(str))
}
