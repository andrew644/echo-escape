package game

import rl "vendor:raylib"

shader: rl.Shader

load_shader :: proc() {
	shader = rl.LoadShaderFromMemory(vshader_src, fshader_src)

	light_dir := rl.Vector3{-1, -1, -1}
	rl.SetShaderValue(
		shader,
		rl.GetShaderLocation(shader, "lightDir"),
		&light_dir,
		rl.ShaderUniformDataType.VEC3,
	)

	light_color := rl.Vector3{1, 128, 1}
	rl.SetShaderValue(
		shader,
		rl.GetShaderLocation(shader, "lightColor"),
		&light_color,
		rl.ShaderUniformDataType.VEC3,
	)

	obj_color := rl.Vector3{1, 0.5, 0.3}
	rl.SetShaderValue(
		shader,
		rl.GetShaderLocation(shader, "objectColor"),
		&obj_color,
		rl.ShaderUniformDataType.VEC3,
	)
}
