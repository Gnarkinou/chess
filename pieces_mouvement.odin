#+feature dynamic-literals
package main

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

EAT = Cases spéciales ou le piont peut manger ? => A voir pour le péon
*/

check_possible_movements :: proc(state: ^Game_State) {
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
			fmt.println("checking for peon movements....")
			fmt.println(state.white_player.piece_selected.coord)
			if state.white_player.piece_selected.coord.x <= 0 do return
			if state.white_player.piece_selected.coord.x == 6 {
				state.map_possible_movements = {
					"UP" = 2,
				}
			} else {
				state.map_possible_movements = {
					"UP" = 1,
				}
			}
		case "fou":
			fmt.println("checking for fou movements....")
			state.map_possible_movements = {
				"UPRIGHT"   = min(max_right, max_up),
				"UPLEFT"    = min(max_left, max_up),
				"DOWNLEFT"  = min(max_left, max_down),
				"DOWNRIGHT" = min(max_right, max_down),
			}
		case "tour":
			fmt.println("checking for tour movements....")
			state.map_possible_movements = {
				"RIGHT" = max_right,
				"LEFT"  = max_left,
				"UP"    = max_up,
				"DOWN"  = max_down,
			}
		case "reine":
			fmt.println("checking for reine movements....")
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
			fmt.println("checking for roi movements....")
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
			fmt.println("checking for chevalier movements....")
			if max_right >= 2 && max_up >= 1 {
				tuple :=
					state.white_player.piece_selected.coord.y +
					2 +
					10 * (state.white_player.piece_selected.coord.x - 1)
				append(&state.list_possible_movements_coord, tuple)
			}
			if max_up >= 2 && max_right >= 1 {
				tuple :=
					state.white_player.piece_selected.coord.y +
					1 +
					10 * (state.white_player.piece_selected.coord.x - 2)
				append(&state.list_possible_movements_coord, tuple)
			}
			if max_left >= 2 && max_up >= 1 {
				tuple :=
					state.white_player.piece_selected.coord.y -
					2 +
					10 * (state.white_player.piece_selected.coord.x - 1)
				append(&state.list_possible_movements_coord, tuple)
			}
			if max_left >= 1 && max_up >= 2 {
				tuple :=
					state.white_player.piece_selected.coord.y -
					1 +
					10 * (state.white_player.piece_selected.coord.x - 2)
				append(&state.list_possible_movements_coord, tuple)

			}
			if max_right >= 2 && max_down >= 1 {
				tuple :=
					state.white_player.piece_selected.coord.y +
					2 +
					10 * (state.white_player.piece_selected.coord.x + 1)
				append(&state.list_possible_movements_coord, tuple)
			}
			if max_down >= 2 && max_right >= 1 {
				tuple :=
					state.white_player.piece_selected.coord.y +
					1 +
					10 * (state.white_player.piece_selected.coord.x + 2)
				append(&state.list_possible_movements_coord, tuple)
			}
			if max_left >= 2 && max_down >= 1 {
				tuple :=
					state.white_player.piece_selected.coord.y -
					2 +
					10 * (state.white_player.piece_selected.coord.x + 1)
				append(&state.list_possible_movements_coord, tuple)
			}
			if max_left >= 1 && max_down >= 2 {
				tuple :=
					state.white_player.piece_selected.coord.y -
					1 +
					10 * (state.white_player.piece_selected.coord.x + 2)
				append(&state.list_possible_movements_coord, tuple)
			}
			fmt.println("Le chevalier peut aller sur: ", state.list_possible_movements_coord)
		}
	} else {
		max_right := 7 - state.black_player.piece_selected.coord.y
		max_left := state.black_player.piece_selected.coord.y
		max_up := state.black_player.piece_selected.coord.x
		max_down := 7 - state.black_player.piece_selected.coord.x

		switch state.black_player.piece_selected.type {
		case "peon":
			fmt.println("checking for peon movements....")
			fmt.println(state.black_player.piece_selected.coord)
			if state.black_player.piece_selected.coord.x <= 0 do return
			if state.black_player.piece_selected.coord.x == 6 {
				state.map_possible_movements = {
					"DOWN" = 2,
				}
			} else {
				state.map_possible_movements = {
					"DOWN" = 1,
				}
			}
		case "fou":
			fmt.println("checking for fou movements....")
			state.map_possible_movements = {
				"UPRIGHT"   = min(max_right, max_up),
				"UPLEFT"    = min(max_left, max_up),
				"DOWNLEFT"  = min(max_left, max_down),
				"DOWNRIGHT" = min(max_right, max_down),
			}
		case "tour":
			fmt.println("checking for tour movements....")
			state.map_possible_movements = {
				"RIGHT" = max_right,
				"LEFT"  = max_left,
				"UP"    = max_up,
				"DOWN"  = max_down,
			}
		case "reine":
			fmt.println("checking for reine movements....")
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
			fmt.println("checking for roi movements....")
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
			fmt.println("checking for chevalier movements....")
			if max_right >= 2 && max_up >= 1 {
				tuple :=
					state.black_player.piece_selected.coord.y +
					2 +
					10 * (state.black_player.piece_selected.coord.x - 1)
				append(&state.list_possible_movements_coord, tuple)
			}
			if max_up >= 2 && max_right >= 1 {
				tuple :=
					state.black_player.piece_selected.coord.y +
					1 +
					10 * (state.black_player.piece_selected.coord.x - 2)
				append(&state.list_possible_movements_coord, tuple)
			}
			if max_left >= 2 && max_up >= 1 {
				tuple :=
					state.black_player.piece_selected.coord.y -
					2 +
					10 * (state.black_player.piece_selected.coord.x - 1)
				append(&state.list_possible_movements_coord, tuple)
			}
			if max_left >= 1 && max_up >= 2 {
				tuple :=
					state.black_player.piece_selected.coord.y -
					1 +
					10 * (state.black_player.piece_selected.coord.x - 2)
				append(&state.list_possible_movements_coord, tuple)
			}
			if max_right >= 2 && max_down >= 1 {
				tuple :=
					state.black_player.piece_selected.coord.y +
					2 +
					10 * (state.black_player.piece_selected.coord.x + 1)
				append(&state.list_possible_movements_coord, tuple)
			}
			if max_down >= 2 && max_right >= 1 {
				tuple :=
					state.black_player.piece_selected.coord.y +
					1 +
					10 * (state.black_player.piece_selected.coord.x + 2)
				append(&state.list_possible_movements_coord, tuple)
			}
			if max_left >= 2 && max_down >= 1 {
				tuple :=
					state.black_player.piece_selected.coord.y -
					2 +
					10 * (state.black_player.piece_selected.coord.x + 1)
				append(&state.list_possible_movements_coord, tuple)
			}
			if max_left >= 1 && max_down >= 2 {
				tuple :=
					state.black_player.piece_selected.coord.y -
					1 +
					10 * (state.black_player.piece_selected.coord.x + 2)
				append(&state.list_possible_movements_coord, tuple)
			}
			fmt.println("Le chevalier peut aller sur: ", state.list_possible_movements_coord)
		}
	}
	fmt.println(state.map_possible_movements)
	check_collision_pieces(state)
}

check_collision_pieces :: proc(state: ^Game_State) {
	if len(state.map_possible_movements) == 0 do return
	current_player := state.white_player if state.is_white_turn else state.black_player
	exit_up: {
		fmt.println("testing going up")
		if state.map_possible_movements["UP"] <= 0 do break exit_up
		fmt.println("caclulting up direction")
		for i := 1; i < state.map_possible_movements["UP"]; i += 1 {
			for pcs in state.list_pieces {
				if pcs.coord[0] == current_player.piece_selected.coord[0] &&
				   pcs.coord[i] == current_player.piece_selected.coord[1] + i {
					if current_player.is_white == pcs.is_white {
						break exit_up
					} else {
						tuple :=
							current_player.piece_selected.coord.y +
							10 * (current_player.piece_selected.coord.x - i)
						append(&state.list_possible_movements_coord, tuple)
						break exit_up
					}
				} else {
					tuple :=
						current_player.piece_selected.coord.y +
						10 * (current_player.piece_selected.coord.x - i)
					append(&state.list_possible_movements_coord, tuple)
				}
			}
		}
	}

	exit_down: {
		fmt.println("testing going down")
		if state.map_possible_movements["DOWN"] <= 0 do break exit_down
		fmt.println("caclulting down direction")
		for i := 1; i < state.map_possible_movements["DOWN"]; i += 1 {
			for pcs in state.list_pieces {
				if pcs.coord[0] == current_player.piece_selected.coord[0] &&
				   pcs.coord[i] == current_player.piece_selected.coord[1] + i {
					if current_player.is_white == pcs.is_white {
						break exit_down
					} else {
						tuple :=
							current_player.piece_selected.coord.y +
							10 * (current_player.piece_selected.coord.x + i)
						append(&state.list_possible_movements_coord, tuple)
						break exit_down
					}
				} else {
					tuple :=
						current_player.piece_selected.coord.y +
						10 * (current_player.piece_selected.coord.x + i)
					append(&state.list_possible_movements_coord, tuple)
				}
			}
		}
	}

	exit_upright: {
		fmt.println("testing going up right")
		if state.map_possible_movements["UPRIGHT"] <= 0 do break exit_upright
		fmt.println("caclulting up right direction")
		for i := 1; i < state.map_possible_movements["UPRIGHT"]; i += 1 {
			collision_friend: bool = false
			collision: bool = false
			for pcs in state.list_pieces {
				if pcs.coord[0] == current_player.piece_selected.coord[0] + i &&
				   pcs.coord[i] == current_player.piece_selected.coord[1] - i {
					if current_player.is_white == pcs.is_white {
						collision_friend = true
						break exit_upright
					} else {
						collision = true
					}
				}
				if !collision {
					tuple :=
						current_player.piece_selected.coord.y +
						i +
						10 * (current_player.piece_selected.coord.x - i)
					append(&state.list_possible_movements_coord, tuple)
				}
				if collision_friend || collision_friend {
					break exit_upright
				}
			}
		}
	}

	exit_upleft: {
		fmt.println("testing going up left")
		if state.map_possible_movements["UPLEFT"] <= 0 do break exit_upleft
		fmt.println("caclulting up left direction")
		for i := 1; i < state.map_possible_movements["UPLEFT"]; i += 1 {
			for pcs in state.list_pieces {
				if pcs.coord[0] == current_player.piece_selected.coord[0] + i &&
				   pcs.coord[i] == current_player.piece_selected.coord[1] + i {
					if current_player.is_white == pcs.is_white {
						break exit_upleft
					} else {
						tuple :=
							current_player.piece_selected.coord.y +
							i +
							10 * (current_player.piece_selected.coord.x + i)
						append(&state.list_possible_movements_coord, tuple)
						break exit_upleft
					}
				} else {
					tuple :=
						current_player.piece_selected.coord.y +
						10 * (current_player.piece_selected.coord.x + i)
					append(&state.list_possible_movements_coord, tuple)
				}
			}
		}
	}

	exit_downright: {
		fmt.println("testing going down right")
		if state.map_possible_movements["DOWNRIGHT"] <= 0 do break exit_downright
		fmt.println("caclulting down right direction")
		for i := 1; i < state.map_possible_movements["DOWNRIGHT"]; i += 1 {
			for pcs in state.list_pieces {
				if pcs.coord[0] == current_player.piece_selected.coord[0] + i &&
				   pcs.coord[i] == current_player.piece_selected.coord[1] + i {
					if current_player.is_white == pcs.is_white {
						break exit_downright
					} else {
						tuple :=
							current_player.piece_selected.coord.y +
							i +
							10 * (current_player.piece_selected.coord.x + i)
						append(&state.list_possible_movements_coord, tuple)
						break exit_downright
					}
				} else {
					tuple :=
						current_player.piece_selected.coord.y +
						10 * (current_player.piece_selected.coord.x + i)
					append(&state.list_possible_movements_coord, tuple)
				}
			}
		}
	}

	exit_downleft: {
		fmt.println("testing going down left")
		if state.map_possible_movements["DOWNLEFT"] <= 0 do break exit_downleft
		fmt.println("caclulting down left direction")
		for i := 1; i < state.map_possible_movements["DOWNLEFT"]; i += 1 {
			for pcs in state.list_pieces {
				if pcs.coord[0] == current_player.piece_selected.coord[0] - i &&
				   pcs.coord[i] == current_player.piece_selected.coord[1] {
					if current_player.is_white == pcs.is_white {
						break exit_downleft
					} else {
						tuple :=
							current_player.piece_selected.coord.y +
							i +
							10 * (current_player.piece_selected.coord.x - i)
						append(&state.list_possible_movements_coord, tuple)
						break exit_downleft
					}
				} else {
					tuple :=
						current_player.piece_selected.coord.y +
						10 * (current_player.piece_selected.coord.x - i)
					append(&state.list_possible_movements_coord, tuple)
				}
			}
		}
	}

	exit_left: {
		fmt.println("testing going left")
		if state.map_possible_movements["LEFT"] <= 0 do break exit_left
		fmt.println("caclulting left direction")
		for i := 1; i < state.map_possible_movements["LEFT"]; i += 1 {
			for pcs in state.list_pieces {
				if pcs.coord[0] == current_player.piece_selected.coord[0] - i &&
				   pcs.coord[i] == current_player.piece_selected.coord[1] {
					if current_player.is_white == pcs.is_white {
						break exit_left
					} else {
						tuple :=
							current_player.piece_selected.coord.y -
							i +
							10 * (current_player.piece_selected.coord.x)
						append(&state.list_possible_movements_coord, tuple)
						break exit_left
					}
				} else {
					tuple :=
						current_player.piece_selected.coord.y -
						i +
						10 * (current_player.piece_selected.coord.x)
					append(&state.list_possible_movements_coord, tuple)
				}
			}
		}
	}

	exit_right: {
		fmt.println("testing going right")
		if state.map_possible_movements["RIGHT"] <= 0 do break exit_right
		fmt.println("caclulting right direction")
		for i := 1; i < state.map_possible_movements["RIGHT"]; i += 1 {
			for pcs in state.list_pieces {
				if pcs.coord[0] == current_player.piece_selected.coord[0] + i &&
				   pcs.coord[i] == current_player.piece_selected.coord[1] {
					if current_player.is_white == pcs.is_white {
						break exit_right
					} else {
						tuple :=
							current_player.piece_selected.coord.y +
							i +
							10 * (current_player.piece_selected.coord.x)
						append(&state.list_possible_movements_coord, tuple)
						break exit_right
					}
				} else {
					tuple :=
						current_player.piece_selected.coord.y +
						i +
						10 * (current_player.piece_selected.coord.x)
					append(&state.list_possible_movements_coord, tuple)
				}
			}
		}
	}
	fmt.println(state.list_possible_movements_coord[:])
}

move_piece :: proc(state: ^Game_State, row: int, col: int) -> (ok: bool) {
	player := state.white_player if state.is_white_turn else state.black_player
	if player == nil || player.piece_selected == nil do return false
	spawn_piece(
		state,
		type = player.piece_selected.type,
		is_white = player.piece_selected.is_white,
		row = row,
		col = col,
	)
	return true
}
