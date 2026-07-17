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
	state.list_possible_movements_chevalier = {}
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
				append(&state.list_possible_movements_chevalier, tuple)
			}
			if max_up >= 2 && max_right >= 1 {
				tuple :=
					state.white_player.piece_selected.coord.y +
					1 +
					10 * (state.white_player.piece_selected.coord.x - 2)
				append(&state.list_possible_movements_chevalier, tuple)
			}
			if max_left >= 2 && max_up >= 1 {
				tuple :=
					state.white_player.piece_selected.coord.y -
					2 +
					10 * (state.white_player.piece_selected.coord.x - 1)
				append(&state.list_possible_movements_chevalier, tuple)
			}
			if max_left >= 1 && max_up >= 2 {
				tuple :=
					state.white_player.piece_selected.coord.y -
					1 +
					10 * (state.white_player.piece_selected.coord.x - 2)
				append(&state.list_possible_movements_chevalier, tuple)

			}
			if max_right >= 2 && max_down >= 1 {
				tuple :=
					state.white_player.piece_selected.coord.y +
					2 +
					10 * (state.white_player.piece_selected.coord.x + 1)
				append(&state.list_possible_movements_chevalier, tuple)
			}
			if max_down >= 2 && max_right >= 1 {
				tuple :=
					state.white_player.piece_selected.coord.y +
					1 +
					10 * (state.white_player.piece_selected.coord.x + 2)
				append(&state.list_possible_movements_chevalier, tuple)
			}
			if max_left >= 2 && max_down >= 1 {
				tuple :=
					state.white_player.piece_selected.coord.y -
					2 +
					10 * (state.white_player.piece_selected.coord.x + 1)
				append(&state.list_possible_movements_chevalier, tuple)
			}
			if max_left >= 1 && max_down >= 2 {
				tuple :=
					state.white_player.piece_selected.coord.y -
					1 +
					10 * (state.white_player.piece_selected.coord.x + 2)
				append(&state.list_possible_movements_chevalier, tuple)
			}
			fmt.println("Le chevalier peut aller sur: ", state.list_possible_movements_chevalier)
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
				append(&state.list_possible_movements_chevalier, tuple)
			}
			if max_up >= 2 && max_right >= 1 {
				tuple :=
					state.black_player.piece_selected.coord.y +
					1 +
					10 * (state.black_player.piece_selected.coord.x - 2)
				append(&state.list_possible_movements_chevalier, tuple)
			}
			if max_left >= 2 && max_up >= 1 {
				tuple :=
					state.black_player.piece_selected.coord.y -
					2 +
					10 * (state.black_player.piece_selected.coord.x - 1)
				append(&state.list_possible_movements_chevalier, tuple)
			}
			if max_left >= 1 && max_up >= 2 {
				tuple :=
					state.black_player.piece_selected.coord.y -
					1 +
					10 * (state.black_player.piece_selected.coord.x - 2)
				append(&state.list_possible_movements_chevalier, tuple)

			}
			if max_right >= 2 && max_down >= 1 {
				tuple :=
					state.black_player.piece_selected.coord.y +
					2 +
					10 * (state.black_player.piece_selected.coord.x + 1)
				append(&state.list_possible_movements_chevalier, tuple)
			}
			if max_down >= 2 && max_right >= 1 {
				tuple :=
					state.black_player.piece_selected.coord.y +
					1 +
					10 * (state.black_player.piece_selected.coord.x + 2)
				append(&state.list_possible_movements_chevalier, tuple)
			}
			if max_left >= 2 && max_down >= 1 {
				tuple :=
					state.black_player.piece_selected.coord.y -
					2 +
					10 * (state.black_player.piece_selected.coord.x + 1)
				append(&state.list_possible_movements_chevalier, tuple)
			}
			if max_left >= 1 && max_down >= 2 {
				tuple :=
					state.black_player.piece_selected.coord.y -
					1 +
					10 * (state.black_player.piece_selected.coord.x + 2)
				append(&state.list_possible_movements_chevalier, tuple)
			}
			fmt.println("Le chevalier peut aller sur: ", state.list_possible_movements_chevalier)
		}
	}
	fmt.println(state.map_possible_movements)
}

check_collision_pieces :: proc(state: ^Game_State) {
	if len(state.map_possible_movements) == 0 do return
}
