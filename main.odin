package main

import "core:fmt"
import sdl "vendor:sdl3"

SCREEN_WIDTH :: 1280
SCREEN_HEIGHT :: 1024
BOARD_SIZE :: 800

Game_State :: struct {
	window:                        ^sdl.Window,
	renderer:                      ^sdl.Renderer,
	running:                       bool,
	list_grid:                     [8][8]sdl.FRect,
	list_pieces:                   [dynamic]^Piece,
	map_possible_movements:        map[string]int,
	list_possible_movements_coord: [dynamic]int,
	white_player:                  ^Player,
	black_player:                  ^Player,
	mouse_coord:                   [2]f32,
	mouse_moved:                   bool,
	mouse_left_clicked:            bool,
	mouse_released:                bool,
	is_white_turn:                 bool,
	tile_size:                     int,
}

Player :: struct {
	name:           string,
	is_white:       bool,
	piece_selected: ^Piece,
}

Piece :: struct {
	is_white: bool,
	type:     string,
	is_dead:  bool,
	coord:    [2]int,
	rect:     sdl.FRect,
	hovered:  bool,
}

main :: proc() {
	if !sdl.Init({.VIDEO}) {
		fmt.println("Initializing sdl video failed: ", sdl.GetError())
		return
	}
	defer sdl.Quit()

	state := Game_State {
		running       = true,
		is_white_turn = true,
	}

	state.window = sdl.CreateWindow("Chess", SCREEN_WIDTH, SCREEN_HEIGHT, {})
	if state.window == nil {
		fmt.println("Error creating the game window: ", sdl.GetError())
		return
	}
	defer sdl.DestroyWindow(state.window)

	state.renderer = sdl.CreateRenderer(state.window, nil)
	if state.renderer == nil {
		fmt.println("Error creating the sdl rendrere: ", sdl.GetError())
		return
	}
	defer sdl.DestroyRenderer(state.renderer)

	vsync_ok := sdl.SetRenderVSync(state.renderer, 1)
	if !vsync_ok {
		fmt.println("Vsync failed")
		sdl.SetHint(sdl.HINT_RENDER_VSYNC, "1")
	}

	init_grid(&state)
	init_pieces(&state)
	init_players(&state)

	defer cleanup_pieces(&state)
	for state.running {
		handle_events(&state)
		update(&state)
		render(&state)
	}
}

handle_events :: proc(state: ^Game_State) {
	state.mouse_moved = false
	state.mouse_left_clicked = false
	state.mouse_released = false
	event: sdl.Event
	for sdl.PollEvent(&event) {
		#partial switch event.type {
		case .QUIT:
			state.running = false
		case .KEY_DOWN:
			if event.key.scancode == .ESCAPE do state.running = false
		case .MOUSE_MOTION:
			state.mouse_coord[0] = event.motion.x
			state.mouse_coord[1] = event.motion.y
			state.mouse_moved = true
		case .MOUSE_BUTTON_DOWN:
			if event.button.button == sdl.BUTTON_LEFT {
				state.mouse_left_clicked = true
				select_piece(state)
				fmt.println("Left click at: ", event.button.x, event.button.y)
			} else if event.button.button == sdl.BUTTON_RIGHT {
				fmt.println("Right click at: ", event.button.x, event.button.y)
				state.white_player.piece_selected = nil
			}
		case .MOUSE_BUTTON_UP:
			if event.button.button == sdl.BUTTON_LEFT {
				fmt.println("Left click released at: ", event.button.x, event.button.y)
				state.mouse_released = true
			} else if event.button.button == sdl.BUTTON_RIGHT {
				fmt.println("Right click released at: ", event.button.x, event.button.y)
			}
		}
	}
}

update :: proc(state: ^Game_State) {
	if state.mouse_moved || state.mouse_left_clicked do select_piece(state)
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
	state.tile_size = BOARD_SIZE / 8
	for i := 0; i < 8; i += 1 {
		for j := 0; j < 8; j += 1 {
			state.list_grid[i][j] = sdl.FRect {
				x = f32(offset_x + j * state.tile_size),
				y = f32(offset_y + i * state.tile_size),
				w = f32(state.tile_size),
				h = f32(state.tile_size),
			}
		}
	}
}

init_players :: proc(state: ^Game_State) {
	p1 := new(Player)
	p1.is_white = true
	p1.name = "Romeo"

	p2 := new(Player)
	p2.is_white = false
	p2.name = "Juliette"

	state.white_player = p1
	state.black_player = p2
}

spawn_piece :: proc(state: ^Game_State, type: string, is_white: bool, row: int, col: int) {
	p := new(Piece)
	p.type = type
	p.is_white = is_white
	p.is_dead = false
	p.coord = [2]int{row, col}
	p.hovered = false
	tile := state.list_grid[row][col]
	margin_w := tile.w * 0.15
	margin_h := tile.h * 0.15
	p.rect = {
		x = tile.x + margin_w,
		y = tile.y + margin_h,
		w = tile.w - (margin_w * 2),
		h = tile.h - (margin_h * 2),
	}
	append(&state.list_pieces, p)
}

init_pieces :: proc(state: ^Game_State) {
	state.list_pieces = make([dynamic]^Piece, 0, 32)
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

@(private)
get_board_tile_at_mouse :: proc(state: ^Game_State) -> (row: int, col: int, valid: bool) {
	margin_x := (SCREEN_WIDTH - BOARD_SIZE) / 2
	margin_y := (SCREEN_HEIGHT - BOARD_SIZE) / 2
	board_mouse_x := int(state.mouse_coord[0]) - margin_x
	board_mouse_y := int(state.mouse_coord[1]) - margin_y
	col = board_mouse_x / state.tile_size
	row = board_mouse_y / state.tile_size

	if row >= 0 && row < 8 && col >= 0 && col < 8 {
		return row, col, true
	}
	return -1, -1, false
}

@(private)
select_piece :: proc(state: ^Game_State) {
	row, col, ok := get_board_tile_at_mouse(state)
	if !ok do return

	current_player := state.white_player if state.is_white_turn else state.black_player

	for pcs in state.list_pieces {
		pcs.hovered = false
		if pcs.coord[0] != row || pcs.coord[1] != col do continue
		pcs.hovered = true
		if !state.mouse_left_clicked do continue
		if state.is_white_turn && pcs.is_white {
			state.white_player.piece_selected = pcs
			fmt.println("Selected the piece: ", pcs)
			check_possible_movements(state)
			state.mouse_left_clicked = false
			return
		} else if !state.is_white_turn && !pcs.is_white {
			state.black_player.piece_selected = pcs
			fmt.println("Selected the piece: ", pcs)
			check_possible_movements(state)
			state.mouse_left_clicked = false
			return
		} else if state.is_white_turn != pcs.is_white {
			fmt.println("Case where one try to eat the other !!")
			// To DO
		}
	}

	if !state.mouse_left_clicked || current_player.piece_selected == nil do return
	fmt.println(
		"trying to move the piece: ",
		current_player.piece_selected,
		" to the destination: ",
		row,
		col,
	)
	if !move_piece(state, row, col) do return
	current_player.piece_selected.is_dead = true
	current_player.piece_selected = nil
	state.mouse_left_clicked = false
	state.is_white_turn = !state.is_white_turn
	cleanup_dead_pieces(state)
}
