package game

import rl "vendor:raylib"

MAX_LIGHTS :: 4

Light_Type :: enum i32 {
	Directional = 0,
	Point,
}

Light :: struct {
	type:            Light_Type,
	enabled:         bool,
	position:        rl.Vector3,
	target:          rl.Vector3,
	color:           rl.Color,
	attenuation:     f32,

	// Shader locations
	enabled_loc:     i32,
	type_loc:        i32,
	position_loc:    i32,
	target_loc:      i32,
	color_loc:       i32,
	attenuation_loc: i32,
}

lights_count: int = 0

//----------------------------------------------------------------------------------
// Module Functions
//----------------------------------------------------------------------------------

// Create a light and get shader locations
create_light :: proc(
	type: Light_Type,
	position: rl.Vector3,
	target: rl.Vector3,
	color: rl.Color,
	shader: rl.Shader,
) -> Light {
	light := Light{}

	if lights_count < MAX_LIGHTS {
		light.enabled = true
		light.type = type
		light.position = position
		light.target = target
		light.color = color

		// Shader uniform locations for this light index
		light.enabled_loc = rl.GetShaderLocation(
			shader,
			rl.TextFormat("lights[%d].enabled", lights_count),
		)
		light.type_loc = rl.GetShaderLocation(
			shader,
			rl.TextFormat("lights[%d].type", lights_count),
		)
		light.position_loc = rl.GetShaderLocation(
			shader,
			rl.TextFormat("lights[%d].position", lights_count),
		)
		light.target_loc = rl.GetShaderLocation(
			shader,
			rl.TextFormat("lights[%d].target", lights_count),
		)
		light.color_loc = rl.GetShaderLocation(
			shader,
			rl.TextFormat("lights[%d].color", lights_count),
		)
		// Optional attenuation
		light.attenuation_loc = rl.GetShaderLocation(
			shader,
			rl.TextFormat("lights[%d].attenuation", lights_count),
		)

		update_light_values(shader, light)

		lights_count += 1
	}

	return light
}

@(private = "file")
update_light_values :: proc(shader: rl.Shader, light: Light) {
	enabled: i32 = i32(light.enabled)
	rl.SetShaderValue(shader, light.enabled_loc, &enabled, rl.ShaderUniformDataType.INT)
	light_type: i32 = i32(light.type)
	rl.SetShaderValue(shader, light.type_loc, &light_type, rl.ShaderUniformDataType.INT)

	position := [3]f32{light.position.x, light.position.y, light.position.z}
	rl.SetShaderValue(shader, light.position_loc, &position, rl.ShaderUniformDataType.VEC3)

	target := [3]f32{light.target.x, light.target.y, light.target.z}
	rl.SetShaderValue(shader, light.target_loc, &target, rl.ShaderUniformDataType.VEC3)

	color := [4]f32 {
		f32(light.color.r) / 255.0,
		f32(light.color.g) / 255.0,
		f32(light.color.b) / 255.0,
		f32(light.color.a) / 255.0,
	}
	rl.SetShaderValue(shader, light.color_loc, &color, rl.ShaderUniformDataType.VEC4)

	attenuation: f32 = light.attenuation
	rl.SetShaderValue(shader, light.attenuation_loc, &attenuation, rl.ShaderUniformDataType.FLOAT)
}
