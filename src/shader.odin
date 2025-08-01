package game

import rl "vendor:raylib"

shader: rl.Shader

load_shader :: proc() {
	shader = rl.LoadShaderFromMemory(vshader_src, fshader_src)
	shader.locs[rl.ShaderLocationIndex.VECTOR_VIEW] = rl.GetShaderLocation(shader, "viewPos")

	ambient_loc := rl.GetShaderLocation(shader, "ambient")
	color := rl.Vector4({0.1, 0.1, 0.1, 0.1})
	rl.SetShaderValue(shader, ambient_loc, &color, rl.ShaderUniformDataType.VEC4)

	create_light(.Directional, rl.Vector3({100, 100, 100}), rl.Vector3(0), rl.WHITE, shader)
	//create_light(.Point, rl.Vector3({100, 100, 100}), rl.Vector3(0), rl.WHITE, shader)
}
