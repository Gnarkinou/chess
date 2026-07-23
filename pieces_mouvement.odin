#+feature dynamic-literals
package main

import "core:c"
import "core:fmt"

/*
The state.map_possible_movements:
UP = Nombre de case que le piont peut aller en haut
DOWN = Nomber de case que le piont peut aller en bas
RIGHT = Nombre de case que le piont peut aller à droite
LEFT = Nombre de case que le piont peut aller à gauche
UPRIGHT = Nombre de cases que le piont peut faire en diagonale droite haute
UPLEFT = Nombre de cases que le piont peut faire en diagonale gauche haute
DOWNLEFT = Nombre de cases que le piont peut faire en diagonale gauche basse
DOWNRIGHT = Nombre de cases que le piont peut faire en diagonale droite basse
*/

check_possible_movements :: proc(state: ^Game_State) {
	init_grid(state)
	state.map_possible_movements = {}
	state.list_possible_movements_coord = {}
	if state.is_white_turn && state.white_player.piece_selected == nil do return
	if !state.is_white_turn && state.black_player.piece_selected == nil do return

	if state.is_white_turn {
		max_right := 7 - state.white_player.piece_selected.coord.y
		max_left := state.white_player.piece_selected.coord.y
		max_up := state.white_player.piece_selected.coord.x
		max_down := 7 - state.white_player.piece_selected.coord.x

		switch state.white_player.piece_selected.type {
		case "peon":
			if state.white_player.piece_selected.coord.x <= 0 do return
			if state.white_player.piece_selected.coord.x == 6 {
				state.map_possible_movements = {
					"UP"      = 2,
					"UPRIGHT" = 1,
					"UPLEFT"  = 1,
				}
			} else {
				state.map_possible_movements = {
					"UP"      = 1,
					"UPRIGHT" = 1,
					"UPLEFT"  = 1,
				}
			}
		case "fou":
			state.map_possible_movements = {
				"UPRIGHT"   = min(max_right, max_up),
				"UPLEFT"    = min(max_left, max_up),
				"DOWNLEFT"  = min(max_left, max_down),
				"DOWNRIGHT" = min(max_right, max_down),
			}
		case "tour":
			state.map_possible_movements = {
				"RIGHT" = max_right,
				"LEFT"  = max_left,
				"UP"    = max_up,
				"DOWN"  = max_down,
			}
		case "reine":
			state.map_possible_movements = {
				"UPRIGHT"   = min(max_right, max_up),
				"UPLEFT"    = min(max_left, max_up),
				"DOWNLEFT"  = min(max_left, max_down),
				"DOWNRIGHT" = min(max_right, max_down),
				"RIGHT"     = max_right,
				"LEFT"      = max_left,
				"UP"        = max_up,
				"DOWN"      = max_down,
			}
		case "roi":
			state.map_possible_movements = {
				"UPRIGHT"   = min(1, max_right, max_up),
				"UPLEFT"    = min(1, max_left, max_up),
				"DOWNLEFT"  = min(1, max_left, max_down),
				"DOWNRIGHT" = min(1, max_right, max_down),
				"RIGHT"     = min(1, max_right),
				"LEFT"      = min(1, max_left),
				"UP"        = min(1, max_up),
				"DOWN"      = min(1, max_down),
			}
		case "chevalier":
			if max_right >= 2 && max_up >= 1 {
				append(
					&state.list_possible_movements_coord,
					[2]int {
						state.white_player.piece_selected.coord.x - 1,
						state.white_player.piece_selected.coord.y + 2,
					},
				)
			}
			if max_up >= 2 && max_right >= 1 {
				append(
					&state.list_possible_movements_coord,
					[2]int {
						state.white_player.piece_selected.coord.x - 2,
						state.white_player.piece_selected.coord.y + 1,
					},
				)
			}
			if max_left >= 2 && max_up >= 1 {
				append(
					&state.list_possible_movements_coord,
					[2]int {
						state.white_player.piece_selected.coord.x - 1,
						state.white_player.piece_selected.coord.y - 2,
					},
				)
			}
			if max_left >= 1 && max_up >= 2 {
				append(
					&state.list_possible_movements_coord,
					[2]int {
						state.white_player.piece_selected.coord.x - 2,
						state.white_player.piece_selected.coord.y - 1,
					},
				)
			}
			if max_right >= 2 && max_down >= 1 {
				append(
					&state.list_possible_movements_coord,
					[2]int {
						state.white_player.piece_selected.coord.x + 1,
						state.white_player.piece_selected.coord.y + 2,
					},
				)
			}
			if max_down >= 2 && max_right >= 1 {
				append(
					&state.list_possible_movements_coord,
					[2]int {
						state.white_player.piece_selected.coord.x + 2,
						state.white_player.piece_selected.coord.y + 1,
					},
				)
			}
			if max_left >= 2 && max_down >= 1 {
				append(
					&state.list_possible_movements_coord,
					[2]int {
						state.white_player.piece_selected.coord.x + 1,
						state.white_player.piece_selected.coord.y - 2,
					},
				)
			}
			if max_left >= 1 && max_down >= 2 {
				append(
					&state.list_possible_movements_coord,
					[2]int {
						state.white_player.piece_selected.coord.x + 2,
						state.white_player.piece_selected.coord.y - 1,
					},
				)

			}
		}
	} else {
		max_right := 7 - state.black_player.piece_selected.coord.y
		max_left := state.black_player.piece_selected.coord.y
		max_up := state.black_player.piece_selected.coord.x
		max_down := 7 - state.black_player.piece_selected.coord.x

		switch state.black_player.piece_selected.type {
		case "peon":
			if state.black_player.piece_selected.coord.x < 0 do return
			if state.black_player.piece_selected.coord.x == 1 {
				state.map_possible_movements = {
					"DOWN"      = 2,
					"DOWNRIGHT" = 1,
					"DOWNLEFT"  = 1,
				}
			} else {
				state.map_possible_movements = {
					"DOWN"      = 1,
					"DOWNRIGHT" = 1,
					"DOWNLEFT"  = 1,
				}
			}
		case "fou":
			state.map_possible_movements = {
				"UPRIGHT"   = min(max_right, max_up),
				"UPLEFT"    = min(max_left, max_up),
				"DOWNLEFT"  = min(max_left, max_down),
				"DOWNRIGHT" = min(max_right, max_down),
			}
		case "tour":
			state.map_possible_movements = {
				"RIGHT" = max_right,
				"LEFT"  = max_left,
				"UP"    = max_up,
				"DOWN"  = max_down,
			}
		case "reine":
			state.map_possible_movements = {
				"UPRIGHT"   = min(max_right, max_up),
				"UPLEFT"    = min(max_left, max_up),
				"DOWNLEFT"  = min(max_left, max_down),
				"DOWNRIGHT" = min(max_right, max_down),
				"RIGHT"     = max_right,
				"LEFT"      = max_left,
				"UP"        = max_up,
				"DOWN"      = max_down,
			}
		case "roi":
			state.map_possible_movements = {
				"UPRIGHT"   = min(1, max_right, max_up),
				"UPLEFT"    = min(1, max_left, max_up),
				"DOWNLEFT"  = min(1, max_left, max_down),
				"DOWNRIGHT" = min(1, max_right, max_down),
				"RIGHT"     = min(1, max_right),
				"LEFT"      = min(1, max_left),
				"UP"        = min(1, max_up),
				"DOWN"      = min(1, max_down),
			}
		case "chevalier":
			if max_right >= 2 && max_up >= 1 {
				append(
					&state.list_possible_movements_coord,
					[2]int {
						state.black_player.piece_selected.coord.x - 1,
						state.black_player.piece_selected.coord.y + 2,
					},
				)
			}
			if max_up >= 2 && max_right >= 1 {
				append(
					&state.list_possible_movements_coord,
					[2]int {
						state.black_player.piece_selected.coord.x - 2,
						state.black_player.piece_selected.coord.y + 1,
					},
				)
			}
			if max_left >= 2 && max_up >= 1 {
				append(
					&state.list_possible_movements_coord,
					[2]int {
						state.black_player.piece_selected.coord.x - 1,
						state.black_player.piece_selected.coord.y - 2,
					},
				)
			}
			if max_left >= 1 && max_up >= 2 {
				append(
					&state.list_possible_movements_coord,
					[2]int {
						state.black_player.piece_selected.coord.x - 2,
						state.black_player.piece_selected.coord.y - 1,
					},
				)
			}
			if max_right >= 2 && max_down >= 1 {
				append(
					&state.list_possible_movements_coord,
					[2]int {
						state.black_player.piece_selected.coord.x + 1,
						state.black_player.piece_selected.coord.y + 2,
					},
				)
			}
			if max_down >= 2 && max_right >= 1 {
				append(
					&state.list_possible_movements_coord,
					[2]int {
						state.black_player.piece_selected.coord.x + 2,
						state.black_player.piece_selected.coord.y + 1,
					},
				)
			}
			if max_left >= 2 && max_down >= 1 {
				append(
					&state.list_possible_movements_coord,
					[2]int {
						state.black_player.piece_selected.coord.x + 1,
						state.black_player.piece_selected.coord.y - 2,
					},
				)
			}
			if max_left >= 1 && max_down >= 2 {
				append(
					&state.list_possible_movements_coord,
					[2]int {
						state.black_player.piece_selected.coord.x + 2,
						state.black_player.piece_selected.coord.y - 1,
					},
				)
			}
		}
	}
	fmt.println(state.map_possible_movements)
	check_collision_pieces(state)
}

check_collision_pieces :: proc(state: ^Game_State) {
	current_player := state.white_player if state.is_white_turn else state.black_player
	if len(state.map_possible_movements) == 0 && current_player.piece_selected.type != "chevalier" do return
	state.list_grid[current_player.piece_selected.coord.x][current_player.piece_selected.coord.y].selected =
		true

	if current_player.piece_selected.type == "chevalier" {
		#reverse for moves, i in state.list_possible_movements_coord {
			collision := false
			collision_friendly := false
			for pcs in state.list_pieces {
				if pcs.coord != moves do continue
				if pcs.is_white == current_player.is_white {
					collision_friendly = true
				}
				collision = true
			}
			if collision_friendly {
				unordered_remove(&state.list_possible_movements_coord, i)
				continue
			}
			if collision {
				state.list_grid[moves.x][moves.y].killed_possible = true
			} else {
				state.list_grid[moves.x][moves.y].move_possible = true
			}
		}
		return
	}
	exit_up: {
		if val, ok := state.map_possible_movements["UP"]; !ok || val <= 0 do break exit_up
		collision := false
		for i := 1; i <= state.map_possible_movements["UP"]; i += 1 {
			for pcs in state.list_pieces {
				if pcs.coord[0] == current_player.piece_selected.coord[0] - i &&
				   pcs.coord[1] == current_player.piece_selected.coord[1] {
					fmt.println("Collision happening", pcs.coord)
					if current_player.is_white == pcs.is_white {
						break exit_up
					} else {
						collision = true
					}
				}
			}
			if current_player.piece_selected.type == "peon" && current_player.is_white && collision do break exit_up
			append(
				&state.list_possible_movements_coord,
				[2]int {
					current_player.piece_selected.coord.x - i,
					current_player.piece_selected.coord.y,
				},
			)
			x := current_player.piece_selected.coord.x - i
			y := current_player.piece_selected.coord.y
			state.list_grid[x][y].move_possible = true

			if collision {
				state.list_grid[x][y].killed_possible = true
				break exit_up
			}
		}
	}

	exit_down: {
		if val, ok := state.map_possible_movements["DOWN"]; !ok || val <= 0 do break exit_down
		collision := false
		for i := 1; i <= state.map_possible_movements["DOWN"]; i += 1 {
			for pcs in state.list_pieces {
				if pcs.coord[0] == current_player.piece_selected.coord[0] + i &&
				   pcs.coord[1] == current_player.piece_selected.coord[1] {
					if current_player.is_white == pcs.is_white {
						break exit_down
					} else {
						collision = true
					}
				}
			}
			if current_player.piece_selected.type == "peon" && !current_player.is_white && collision do break exit_down
			append(
				&state.list_possible_movements_coord,
				[2]int {
					current_player.piece_selected.coord.x + i,
					current_player.piece_selected.coord.y,
				},
			)
			x := current_player.piece_selected.coord.x + i
			y := current_player.piece_selected.coord.y
			state.list_grid[x][y].move_possible = true

			if collision {
				state.list_grid[x][y].killed_possible = true
				break exit_down
			}
		}
	}

	exit_upright: {
		if val, ok := state.map_possible_movements["UPRIGHT"]; !ok || val <= 0 do break exit_upright
		for i := 1; i <= state.map_possible_movements["UPRIGHT"]; i += 1 {
			collision: bool = false
			for pcs in state.list_pieces {
				if pcs.coord[0] == current_player.piece_selected.coord[0] - i &&
				   pcs.coord[1] == current_player.piece_selected.coord[1] + i {
					if current_player.is_white == pcs.is_white {
						break exit_upright
					} else {
						collision = true
					}
				}
			}
			if current_player.piece_selected.type == "peon" && current_player.is_white && !collision do break exit_upright
			append(
				&state.list_possible_movements_coord,
				[2]int {
					current_player.piece_selected.coord.x - i,
					current_player.piece_selected.coord.y + i,
				},
			)
			x := current_player.piece_selected.coord.x - i
			y := current_player.piece_selected.coord.y + i
			state.list_grid[x][y].move_possible = true

			if collision {
				state.list_grid[x][y].killed_possible = true
				break exit_upright
			}
		}
	}

	exit_upleft: {
		if val, ok := state.map_possible_movements["UPLEFT"]; !ok || val <= 0 do break exit_upleft
		collision := false
		for i := 1; i <= state.map_possible_movements["UPLEFT"]; i += 1 {
			for pcs in state.list_pieces {
				if pcs.coord[0] == current_player.piece_selected.coord[0] - i &&
				   pcs.coord[1] == current_player.piece_selected.coord[1] - i {
					if current_player.is_white == pcs.is_white {
						break exit_upleft
					} else {
						collision = true
					}
				}
			}
			if current_player.piece_selected.type == "peon" && current_player.is_white && !collision do break exit_upleft
			append(
				&state.list_possible_movements_coord,
				[2]int {
					current_player.piece_selected.coord.x - i,
					current_player.piece_selected.coord.y - i,
				},
			)
			x := current_player.piece_selected.coord.x - i
			y := current_player.piece_selected.coord.y - i
			state.list_grid[x][y].move_possible = true

			if collision {
				state.list_grid[x][y].killed_possible = true
				break exit_upleft
			}
		}
	}

	exit_downright: {
		if val, ok := state.map_possible_movements["DOWNRIGHT"]; !ok || val <= 0 do break exit_downright
		collision := false
		for i := 1; i <= state.map_possible_movements["DOWNRIGHT"]; i += 1 {
			for pcs in state.list_pieces {
				if pcs.coord[0] == current_player.piece_selected.coord[0] + i &&
				   pcs.coord[1] == current_player.piece_selected.coord[1] + i {
					if current_player.is_white == pcs.is_white {
						break exit_downright
					} else {
						collision = true
					}
				}
			}
			if current_player.piece_selected.type == "peon" && !current_player.is_white && !collision do break exit_downright
			append(
				&state.list_possible_movements_coord,
				[2]int {
					current_player.piece_selected.coord.x + i,
					current_player.piece_selected.coord.y + i,
				},
			)
			x := current_player.piece_selected.coord.x + i
			y := current_player.piece_selected.coord.y + i
			state.list_grid[x][y].move_possible = true

			if collision {
				state.list_grid[x][y].killed_possible = true
				break exit_downright
			}
		}
	}

	exit_downleft: {
		if val, ok := state.map_possible_movements["DOWNLEFT"]; !ok || val <= 0 do break exit_downleft
		collision := false
		for i := 1; i <= state.map_possible_movements["DOWNLEFT"]; i += 1 {
			for pcs in state.list_pieces {
				if pcs.coord[0] == current_player.piece_selected.coord[0] + i &&
				   pcs.coord[1] == current_player.piece_selected.coord[1] - i {
					if current_player.is_white == pcs.is_white {
						break exit_downleft
					} else {
						collision = true
					}
				}
			}
			if current_player.piece_selected.type == "peon" && !current_player.is_white && !collision do break exit_downleft
			append(
				&state.list_possible_movements_coord,
				[2]int {
					current_player.piece_selected.coord.x + i,
					current_player.piece_selected.coord.y - i,
				},
			)
			x := current_player.piece_selected.coord.x + i
			y := current_player.piece_selected.coord.y - i
			state.list_grid[x][y].move_possible = true

			if collision {
				state.list_grid[x][y].killed_possible = true
				break exit_downleft
			}
		}
	}

	exit_left: {
		if val, ok := state.map_possible_movements["LEFT"]; !ok || val <= 0 do break exit_left
		collision := false
		for i := 1; i <= state.map_possible_movements["LEFT"]; i += 1 {
			for pcs in state.list_pieces {
				if pcs.coord[0] == current_player.piece_selected.coord[0] &&
				   pcs.coord[1] == current_player.piece_selected.coord[1] - i {
					if current_player.is_white == pcs.is_white {
						break exit_left
					} else {
						collision = true
					}
				}
			}
			append(
				&state.list_possible_movements_coord,
				[2]int {
					current_player.piece_selected.coord.x,
					current_player.piece_selected.coord.y - i,
				},
			)
			x := current_player.piece_selected.coord.x
			y := current_player.piece_selected.coord.y - i
			state.list_grid[x][y].move_possible = true

			if collision {
				state.list_grid[x][y].killed_possible = true
				break exit_left
			}
		}
	}

	exit_right: {
		if val, ok := state.map_possible_movements["RIGHT"]; !ok || val <= 0 do break exit_right
		collision := false
		for i := 1; i <= state.map_possible_movements["RIGHT"]; i += 1 {
			for pcs in state.list_pieces {
				if pcs.coord[0] == current_player.piece_selected.coord[0] &&
				   pcs.coord[1] == current_player.piece_selected.coord[1] + i {
					if current_player.is_white == pcs.is_white {
						break exit_right
					} else {
						collision = true
					}
				}
			}
			append(
				&state.list_possible_movements_coord,
				[2]int {
					current_player.piece_selected.coord.x,
					current_player.piece_selected.coord.y + i,
				},
			)
			x := current_player.piece_selected.coord.x
			y := current_player.piece_selected.coord.y + i
			state.list_grid[x][y].move_possible = true

			if collision {
				state.list_grid[x][y].killed_possible = true
				break exit_right
			}
		}
	}
	fmt.println("The list of possible movements is: ", state.list_possible_movements_coord)
}

move_piece :: proc(state: ^Game_State, row: int, col: int) -> (ok: bool) {
	player := state.white_player if state.is_white_turn else state.black_player
	if player == nil || player.piece_selected == nil do return false
	tuple: [2]int = {row, col}
	is_possible: bool = false

	for coords in &state.list_possible_movements_coord {
		if tuple == coords do is_possible = true
	}
	if !is_possible do return false

	for pcs in &state.list_pieces {
		if pcs.coord == tuple && pcs.is_white != player.piece_selected.is_white {
			pcs.is_dead = true
			fmt.println("Killing the pcs: ", pcs)
			check_victory_condition(state)
			cleanup_dead_pieces(state)
		}
	}

	spawn_piece(
		state,
		type = player.piece_selected.type,
		is_white = player.piece_selected.is_white,
		row = row,
		col = col,
	)
	return true
}
