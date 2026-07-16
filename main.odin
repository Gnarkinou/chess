package main

import "core:fmt"
import sdl "vendor:sdl3"

SCREEN_WIDTH :: 1280
SCREEN_HEIGHT :: 1024
BOARD_SIZE :: 800

Game_State :: struct {
	window:      ^sdl.Window,
	renderer:    ^sdl.Renderer,
	running:     bool,
	list_grid:   [8][8]sdl.FRect,
	list_pieces: [dynamic]^piece,
}

piece :: struct {
	is_white: bool,
	type:     string,
	is_dead:  bool,
	coord:    [2]int,
	rect:     sdl.FRect,
}

main :: proc() {
	if !sdl.Init({.VIDEO}) {
		fmt.println("Initializing sdl video failed: ", sdl.GetError())
		return
	}
	defer sdl.Quit()

	state := Game_State {
		running = true,
	}

	state.window = sdl.CreateWindow("Chess", SCREEN_WIDTH, SCREEN_HEIGHT, {})
	if state.window == nil {
		fmt.println("Error creating the game window: ", sdl.GetError())
		return
	}
	defer sdl.DestroyWindow(state.window)

	sdl.SetHint(sdl.HINT_RENDER_VSYNC, "1")
	state.renderer = sdl.CreateRenderer(state.window, nil)
	if state.renderer == nil {
		fmt.println("Error creating the sdl rendrere: ", sdl.GetError())
		return
	}
	defer sdl.DestroyRenderer(state.renderer)

	init_grid(&state)
	defer cleanup_pieces(&state)

	init_pieces(&state)

	for state.running {
		handle_events(&state)
		update(&state)
		render(&state)
	}
}

handle_events :: proc(state: ^Game_State) {
	event: sdl.Event
	for sdl.PollEvent(&event) {
		#partial switch event.type {
		case .QUIT:
			state.running = false
		}
	}
}

update :: proc(state: ^Game_State) {

}

render :: proc(state: ^Game_State) {
	sdl.SetRenderDrawColorFloat(state.renderer, 0.05, 0.05, 0.08, 1.0)
	sdl.RenderClear(state.renderer)
	draw_grid(state)
	draw_pieces(state)
	sdl.RenderPresent(state.renderer)
}

draw_pieces :: proc(state: ^Game_State) {
	for pcs in state.list_pieces {
		if pcs.coord[0] < 0 || pcs.coord[1] < 0 || pcs.coord[0] > 7 || pcs.coord[1] > 7 do continue // safety net
		if pcs.is_white do sdl.SetRenderDrawColor(state.renderer, 245, 245, 240, 255)
		else do sdl.SetRenderDrawColor(state.renderer, 45, 45, 48, 255)
		sdl.RenderFillRect(state.renderer, &pcs.rect)
		/*switch pcs.type {
		case "peon":
			sdl.RenderFillRect(state.renderer, &pcs.rect)

		}*/
	}
}

draw_grid :: proc(state: ^Game_State) {
	for i := 0; i < 8; i += 1 {
		for j := 0; j < 8; j += 1 {
			if (i + j) % 2 == 0 do sdl.SetRenderDrawColor(state.renderer, 240, 217, 181, 255)
			else do sdl.SetRenderDrawColor(state.renderer, 181, 136, 99, 255)
			sdl.RenderFillRect(state.renderer, &state.list_grid[i][j])
		}
	}
}

init_grid :: proc(state: ^Game_State) {
	offset_x := (SCREEN_WIDTH - BOARD_SIZE) / 2
	offset_y := (SCREEN_HEIGHT - BOARD_SIZE) / 2
	tile_size := BOARD_SIZE / 8
	for i := 0; i < 8; i += 1 {
		for j := 0; j < 8; j += 1 {
			state.list_grid[i][j] = sdl.FRect {
				x = f32(offset_x + j * tile_size),
				y = f32(offset_y + i * tile_size),
				w = f32(tile_size),
				h = f32(tile_size),
			}
		}
	}
}

init_pieces :: proc(state: ^Game_State) {
	state.list_pieces = make([dynamic]^piece, 0, 32)
	back_row_types: [8]string = {
		"tour",
		"chevalier",
		"fou",
		"reine",
		"roi",
		"fou",
		"chevalier",
		"tour",
	}

	spawn_piece :: proc(state: ^Game_State, type: string, is_white: bool, row: int, col: int) {
		p := new(piece)
		p.type = type
		p.is_white = is_white
		p.is_dead = false
		p.coord = [2]int{row, col}
		tile := state.list_grid[row][col]
		margin_w := tile.w * 0.15
		margin_h := tile.h * 0.15
		p.rect = {
			x = tile.x + margin_w,
			y = tile.h + margin_h,
			w = tile.w - (margin_w * 2),
			h = tile.h - (margin_h * 2),
		}
		append(&state.list_pieces, p)
	}

	for col := 0; col < 8; col += 1 {
		spawn_piece(state, type = back_row_types[col], is_white = false, row = 0, col = col)
		spawn_piece(state, type = back_row_types[col], is_white = true, row = 7, col = col)
		spawn_piece(state, type = "peon", is_white = false, row = 1, col = col)
		spawn_piece(state, type = "peon", is_white = true, row = 6, col = col)
	}
}

cleanup_dead_pieces :: proc(state: ^Game_State) {
	for i := len(state.list_pieces) - 1; i >= 0; i -= 1 {
		p := state.list_pieces[i]
		if p.is_dead {
			free(p)
			ordered_remove(&state.list_pieces, i)
		}
	}
}

cleanup_pieces :: proc(state: ^Game_State) {
	for p in state.list_pieces {
		free(p)
	}
	delete(state.list_pieces)
}
