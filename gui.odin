package main

import "core:fmt"
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
	return true
}

cleanup_gui :: proc(state: ^Game_State) {
	if state.font != nil do ttf.CloseFont(state.font)
	ttf.Quit()
}

update_gui :: proc(state: ^Game_State) {
	display_players_name(state)
}

display_players_name :: proc(state: ^Game_State) {

}
