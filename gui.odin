package main

import "core:fmt"
import "core:strings"
import sdl "vendor:sdl3"
import ttf "vendor:sdl3/ttf"

init_gui :: proc(state: ^Game_State) -> bool {
	if !ttf.Init() {
		fmt.println("Error initializing the font: ", sdl.GetError())
		return false
	}

	state.font = ttf.OpenFont("sources/Orange_kid.otf", 24)
	if state.font == nil {
		fmt.println("Failed to load the font ", sdl.GetError())
		return false
	}

	init_display_player_name(state)
	init_black_white_turn_gui(state)
	return true
}

cleanup_gui :: proc(state: ^Game_State) {
	if state.white_player_texture != nil do sdl.DestroyTexture(state.white_player_texture)
	if state.black_player_texture != nil do sdl.DestroyTexture(state.black_player_texture)
	if state.font != nil do ttf.CloseFont(state.font)
	ttf.Quit()
}

display_gui :: proc(state: ^Game_State) {
	display_players_name(state)
	display_player_turn(state)
}

display_players_name :: proc(state: ^Game_State) {
	if state.white_player_texture != nil {
		sdl.RenderTexture(
			state.renderer,
			state.white_player_texture,
			nil,
			&state.white_player_rect,
		)
	}
	if state.black_player_texture != nil {
		sdl.RenderTexture(
			state.renderer,
			state.black_player_texture,
			nil,
			&state.black_player_rect,
		)
	}
}

display_player_turn :: proc(state: ^Game_State) {
	if state.is_white_turn {
		sdl.RenderTexture(
			state.renderer,
			state.white_turn_gui_texture,
			nil,
			&state.white_turn_gui_rect,
		)
	} else {
		sdl.RenderTexture(
			state.renderer,
			state.black_turn_gui_texture,
			nil,
			&state.black_turn_gui_rect,
		)
	}
}

draw_text :: proc(state: ^Game_State, text: string, rect: sdl.FRect, color: sdl.Color) {
	if len(text) <= 0 do return
	c_string := strings.clone_to_cstring(text, context.temp_allocator)
	surface := ttf.RenderText_Blended(state.font, c_string, 0, color)
	if surface == nil do return
	defer sdl.DestroySurface(surface)
	texture := sdl.CreateTextureFromSurface(state.renderer, surface)
	if texture == nil do return
	defer sdl.DestroyTexture(texture)
	dst_rect := rect
	sdl.RenderTexture(state.renderer, texture, nil, &dst_rect)
}

init_black_white_turn_gui :: proc(state: ^Game_State) {
	state.white_turn_gui_rect.y = 10
	state.white_turn_gui_rect.w = 100
	state.white_turn_gui_rect.x = SCREEN_WIDTH / 2 + 20
	state.white_turn_gui_rect.h = 40
	color := sdl.Color{255, 255, 255, 255}
	c_string := strings.clone_to_cstring("WHITE", context.temp_allocator)
	surface := ttf.RenderText_Blended(state.font, c_string, 0, color)
	if surface == nil do return
	texture := sdl.CreateTextureFromSurface(state.renderer, surface)
	if texture == nil do return
	state.white_turn_gui_texture = texture

	state.black_turn_gui_rect.y = 10
	state.black_turn_gui_rect.w = 100
	state.black_turn_gui_rect.x = (SCREEN_WIDTH / 2 - state.black_turn_gui_rect.w) - 20
	state.black_turn_gui_rect.h = 40
	color = sdl.Color{0, 0, 0, 255}
	c_string = strings.clone_to_cstring("BLACK", context.temp_allocator)
	surface = ttf.RenderText_Blended(state.font, c_string, 0, color)
	if surface == nil do return
	texture = sdl.CreateTextureFromSurface(state.renderer, surface)
	if texture == nil do return
	state.black_turn_gui_texture = texture
}

init_display_player_name :: proc(state: ^Game_State) {
	state.white_player_rect.x = (SCREEN_WIDTH - BOARD_SIZE) / 2 + 10 + BOARD_SIZE
	state.white_player_rect.y = (SCREEN_HEIGHT - BOARD_SIZE) / 2
	state.white_player_rect.w = 150
	state.white_player_rect.h = 40
	color := sdl.Color{240, 240, 240, 200}
	if len(state.white_player.name) <= 0 {
		fmt.println("White name not found: ", sdl.GetError())
		return
	}
	c_string := strings.clone_to_cstring(state.white_player.name, context.temp_allocator)
	surface := ttf.RenderText_Blended(state.font, c_string, 0, color)
	if surface == nil do return
	texture := sdl.CreateTextureFromSurface(state.renderer, surface)
	if texture == nil do return
	state.white_player_texture = texture

	state.black_player_rect.x = 10
	state.black_player_rect.y = (SCREEN_HEIGHT - BOARD_SIZE) / 2
	state.black_player_rect.w = 150
	state.black_player_rect.h = 40
	color = sdl.Color{40, 40, 40, 200}

	if len(state.white_player.name) <= 0 {
		fmt.println("White name not found: ", sdl.GetError())
		return
	}
	c_string = strings.clone_to_cstring(state.black_player.name, context.temp_allocator)
	surface = ttf.RenderText_Blended(state.font, c_string, 0, color)
	if surface == nil do return
	texture = sdl.CreateTextureFromSurface(state.renderer, surface)
	if texture == nil do return
	state.black_player_texture = texture
}
