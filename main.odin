package main

import "core:fmt"
import "core:strings"
import sdl "vendor:sdl3"
import ttf "vendor:sdl3/ttf"

SCREEN_WIDTH :: 1280
SCREEN_HEIGHT :: 1024
BOARD_SIZE :: 800

Piece_Type :: enum {
	pion,
	tour,
	chevalier,
	fou,
	reine,
	roi,
}

Game_State :: struct {
	window:                        ^sdl.Window,
	renderer:                      ^sdl.Renderer,
	running:                       bool,
	list_grid:                     [8][8]^Grid_Tile,
	list_pieces:                   [dynamic]^Piece,
	map_possible_movements:        map[string]int,
	list_possible_movements_coord: [dynamic][2]int,
	texture_cache:                 Texture_Cache,
	white_player:                  ^Player,
	black_player:                  ^Player,
	white_player_rect:             sdl.FRect,
	white_player_texture:          ^sdl.Texture,
	black_player_texture:          ^sdl.Texture,
	black_player_rect:             sdl.FRect,
	white_turn_gui_rect:           sdl.FRect,
	black_turn_gui_rect:           sdl.FRect,
	white_turn_gui_texture:        ^sdl.Texture,
	black_turn_gui_texture:        ^sdl.Texture,
	white_kill_count_rect:         sdl.FRect,
	white_kill_count_texture:      ^sdl.Texture,
	black_kill_count_rect:         sdl.FRect,
	black_kill_count_texture:      ^sdl.Texture,
	mouse_coord:                   [2]f32,
	mouse_moved:                   bool,
	mouse_left_clicked:            bool,
	mouse_released:                bool,
	is_white_turn:                 bool,
	white_win:                     bool,
	black_win:                     bool,
	tile_size:                     int,
	font:                          ^ttf.Font,
	background:                    ^background_rect,
}

background_rect :: struct {
	left_part:  sdl.FRect,
	right_part: sdl.FRect,
}

Grid_Tile :: struct {
	tile:            sdl.FRect,
	hovered:         bool,
	selected:        bool,
	killed_possible: bool,
	move_possible:   bool,
}

Player :: struct {
	name:           string,
	is_white:       bool,
	piece_selected: ^Piece,
}

Piece :: struct {
	is_white: bool,
	type:     Piece_Type,
	is_dead:  bool,
	coord:    [2]int,
	rect:     sdl.FRect,
	hovered:  bool,
}

Texture_Cache :: struct {
	white: [Piece_Type]^sdl.Texture,
	black: [Piece_Type]^sdl.Texture,
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
		white_win     = false,
		black_win     = false,
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

	sdl.SetRenderDrawBlendMode(state.renderer, sdl.BLENDMODE_BLEND)

	init_grid(&state)
	init_pieces(&state)
	init_players(&state)
	init_textures(&state)
	init_background(&state)
	init_gui(&state)

	defer cleanup_textures(&state)
	defer cleanup_pieces(&state)
	defer cleanup_gui(&state)
	for state.running {
		handle_events(&state)
		update(&state)
		render(&state)
		if state.black_win || state.white_win {
			fmt.println("The game is over")
			if state.black_win {
				fmt.println("The black win")
			} else {
				fmt.println("The white win")
			}
			state.running = false
		}
	}
	fmt.println("Exiting the game now")
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
				unselect_all(state)
			}
		}
	}
}

unselect_all :: proc(state: ^Game_State) {
	state.list_possible_movements_coord = {}
	state.map_possible_movements = {}
	state.black_player.piece_selected = nil
	state.white_player.piece_selected = nil
	state.mouse_left_clicked = false
	init_grid(state)
}

update :: proc(state: ^Game_State) {
	if state.mouse_moved || state.mouse_left_clicked do select_piece(state)
}

render :: proc(state: ^Game_State) {
	sdl.SetRenderDrawColorFloat(state.renderer, 0.05, 0.05, 0.08, 1.0)
	sdl.RenderClear(state.renderer)
	draw_background(state)
	draw_grid(state)
	draw_pieces(state)
	display_gui(state)
	sdl.RenderPresent(state.renderer)
}

draw_pieces :: proc(state: ^Game_State) {
	for pcs in state.list_pieces {
		if pcs.is_dead do continue
		if pcs.coord[0] < 0 || pcs.coord[1] < 0 || pcs.coord[0] > 7 || pcs.coord[1] > 7 do continue

		tex: ^sdl.Texture
		if pcs.is_white {
			tex = state.texture_cache.white[pcs.type]
		} else {
			tex = state.texture_cache.black[pcs.type]
		}

		if tex != nil {
			sdl.RenderTexture(state.renderer, tex, nil, &pcs.rect)
		}
		if pcs.hovered {
			// to be implemented
			// colour change when piece is hovered
		}
	}
}

draw_grid :: proc(state: ^Game_State) {
	for i := 0; i < 8; i += 1 {
		for j := 0; j < 8; j += 1 {
			if (i + j) % 2 == 0 do sdl.SetRenderDrawColor(state.renderer, 240, 217, 181, 255)
			else do sdl.SetRenderDrawColor(state.renderer, 181, 136, 99, 255)
			sdl.RenderFillRect(state.renderer, &state.list_grid[i][j].tile)
			if state.list_grid[i][j].killed_possible {
				sdl.SetRenderDrawColor(state.renderer, 250, 10, 10, 80)
				sdl.RenderFillRect(state.renderer, &state.list_grid[i][j].tile)
			} else if state.list_grid[i][j].selected {
				sdl.SetRenderDrawColor(state.renderer, 10, 20, 240, 100)
				sdl.RenderFillRect(state.renderer, &state.list_grid[i][j].tile)
			} else if state.list_grid[i][j].move_possible {
				sdl.SetRenderDrawColor(state.renderer, 25, 240, 20, 70)
				sdl.RenderFillRect(state.renderer, &state.list_grid[i][j].tile)
			}
			if state.list_grid[i][j].hovered {
				sdl.SetRenderDrawColor(state.renderer, 40, 24, 40, 70)
				sdl.RenderFillRect(state.renderer, &state.list_grid[i][j].tile)
			}
		}
	}
}

draw_background :: proc(state: ^Game_State) {
	sdl.SetRenderDrawColor(state.renderer, 220, 220, 220, 255)
	sdl.RenderFillRect(state.renderer, &state.background.left_part)
	sdl.SetRenderDrawColor(state.renderer, 20, 20, 20, 120)
	sdl.RenderFillRect(state.renderer, &state.background.right_part)
}

init_background :: proc(state: ^Game_State) {
	left_part := sdl.FRect {
		x = 0,
		y = 0,
		w = SCREEN_WIDTH / 2,
		h = SCREEN_HEIGHT,
	}
	right_part := sdl.FRect {
		x = SCREEN_WIDTH / 2,
		y = 0,
		w = SCREEN_WIDTH / 2,
		h = SCREEN_HEIGHT,
	}
	p := new(background_rect)
	p.left_part = left_part
	p.right_part = right_part
	state.background = p
}

init_grid :: proc(state: ^Game_State) {
	offset_x := (SCREEN_WIDTH - BOARD_SIZE) / 2
	offset_y := (SCREEN_HEIGHT - BOARD_SIZE) / 2
	state.tile_size = BOARD_SIZE / 8
	for i := 0; i < 8; i += 1 {
		for j := 0; j < 8; j += 1 {
			g := new(Grid_Tile)
			g.tile = sdl.FRect {
				x = f32(offset_x + j * state.tile_size),
				y = f32(offset_y + i * state.tile_size),
				w = f32(state.tile_size),
				h = f32(state.tile_size),
			}
			g.hovered = false
			g.killed_possible = false
			g.selected = false
			g.move_possible = false
			state.list_grid[i][j] = g
		}
	}
}

init_players :: proc(state: ^Game_State) {
	p1 := new(Player)
	p1.is_white = true
	p1.name = "Les enfants"
	p2 := new(Player)
	p2.is_white = false
	p2.name = "Papa"
	state.white_player = p1
	state.black_player = p2
}

spawn_piece :: proc(state: ^Game_State, type: Piece_Type, is_white: bool, row: int, col: int) {
	p := new(Piece)
	p.type = type
	p.is_white = is_white
	p.is_dead = false
	p.coord = [2]int{row, col}
	p.hovered = false
	tile := state.list_grid[row][col].tile
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
	back_row: [8]Piece_Type = {.tour, .chevalier, .fou, .reine, .roi, .fou, .chevalier, .tour}

	for col := 0; col < 8; col += 1 {
		spawn_piece(state, type = back_row[col], is_white = false, row = 0, col = col)
		spawn_piece(state, type = back_row[col], is_white = true, row = 7, col = col)
		spawn_piece(state, type = .pion, is_white = false, row = 1, col = col)
		spawn_piece(state, type = .pion, is_white = true, row = 6, col = col)
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
	init_kill_counts(state)
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
	if margin_x > int(state.mouse_coord[0]) || margin_y > int(state.mouse_coord[1]) do return -1, -1, false
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

	// I am looking for a better way to do this
	// maybe merge it with another loop somewhere in the draw procedures ?
	// This is sureley not the most efficient way to proceede
	for i := 0; i < 8; i += 1 {
		for j := 0; j < 8; j += 1 {
			state.list_grid[i][j].hovered = false
		}
	}

	state.list_grid[row][col].hovered = true
	current_player := state.white_player if state.is_white_turn else state.black_player

	for pcs in state.list_pieces {
		pcs.hovered = false
		if pcs.coord[0] != row || pcs.coord[1] != col {
			continue
		}
		if pcs == current_player.piece_selected && state.mouse_left_clicked {
			unselect_all(state)
			return
		}
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
	if !move_piece(state, row, col) {
		return
	}
	current_player.piece_selected.is_dead = true
	current_player.piece_selected = nil
	state.mouse_left_clicked = false
	state.is_white_turn = !state.is_white_turn
	init_grid(state)
	cleanup_dead_pieces(state)
}

check_victory_condition :: proc(state: ^Game_State) {
	fmt.println("checking the victory condition")
	for pcs in &state.list_pieces {
		if pcs.type == .roi && pcs.is_white && pcs.is_dead {
			state.black_win = true
			fmt.println("detecting win for black")
		}
		if pcs.type == .roi && !pcs.is_white && pcs.is_dead {
			state.white_win = true
			fmt.println("detecting win for white")
		}
	}
}

load_piece_texture :: proc(renderer: ^sdl.Renderer, path: string) -> ^sdl.Texture {
	if renderer == nil {
		fmt.println("Error, renderer is nil, cannot load texture ", path)
		return nil
	}
	c_path := strings.clone_to_cstring(path, context.temp_allocator)
	surface := sdl.LoadSurface(c_path)
	if surface == nil {
		fmt.println("Loading surface failed", sdl.GetError())
		return nil
	}
	defer sdl.DestroySurface(surface)

	details := sdl.GetPixelFormatDetails(surface.format)
	red_key := sdl.MapRGB(details, nil, 255, 0, 0)
	if !sdl.SetSurfaceColorKey(surface, true, red_key) {
		fmt.println("Failed to set surface color key: ", sdl.GetError())
	}

	texture := sdl.CreateTextureFromSurface(renderer, surface)
	if texture == nil {
		fmt.println("Failed to create the texture", sdl.GetError())
		return nil
	}
	sdl.SetTextureBlendMode(texture, {.BLEND})
	return texture
}

init_textures :: proc(state: ^Game_State) {
	if state.renderer == nil {
		fmt.println("Ah that is not good, renderer is nil")
		return
	}
	white_filenames := [Piece_Type]string {
		.pion      = "sources/Whites/Peon_Blanc.png",
		.tour      = "sources/Whites/Tour_Blanche.png",
		.chevalier = "sources/Whites/Chevalier_Blanc.png",
		.fou       = "sources/Whites/Fou_Blanc.png",
		.reine     = "sources/Whites/Reine_Blanche.png",
		.roi       = "sources/Whites/Roi_Blanc.png",
	}
	black_filenames := [Piece_Type]string {
		.pion      = "sources/Blacks/Peon_Noir.png",
		.tour      = "sources/Blacks/Tour_Noir.png",
		.chevalier = "sources/Blacks/Chevalier_Noir.png",
		.fou       = "sources/Blacks/Fou_Noir.png",
		.reine     = "sources/Blacks/Reine_Noire.png",
		.roi       = "sources/Blacks/Roi_Noir.png",
	}

	for type in Piece_Type {
		state.texture_cache.white[type] = load_piece_texture(state.renderer, white_filenames[type])
		state.texture_cache.black[type] = load_piece_texture(state.renderer, black_filenames[type])
	}
}

cleanup_textures :: proc(state: ^Game_State) {
	for type in Piece_Type {
		if state.texture_cache.white[type] != nil do sdl.DestroyTexture(state.texture_cache.white[type])
		if state.texture_cache.black[type] != nil do sdl.DestroyTexture(state.texture_cache.black[type])
	}
}
