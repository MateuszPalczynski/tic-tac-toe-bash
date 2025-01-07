#!/bin/bash

# Inicjalizacja pustej planszy
board=( "." "." "." "." "." "." "." "." "." )
turn=0  # Numer tury

# Funkcja rysująca planszę
draw_board() {
  echo " ${board[0]} | ${board[1]} | ${board[2]}"
  echo "---+---+---"
  echo " ${board[3]} | ${board[4]} | ${board[5]}"
  echo "---+---+---"
  echo " ${board[6]} | ${board[7]} | ${board[8]}"
}

# Funkcja sprawdzająca, czy ktoś wygrał
check_winner() {
  local lines=(
    "0 1 2" "3 4 5" "6 7 8" # Poziome
    "0 3 6" "1 4 7" "2 5 8" # Pionowe
    "0 4 8" "2 4 6"         # Przekątne
  )
  
  for line in "${lines[@]}"; do
    set -- $line
    if [ "${board[$1]}" != "." ] && [ "${board[$1]}" == "${board[$2]}" ] && [ "${board[$1]}" == "${board[$3]}" ]; then
      echo "Gracz ${board[$1]} wygrywa!"
      exit
    fi
  done
}

# Funkcja sprawdzająca, czy plansza jest pełna
check_draw() {
  for i in "${board[@]}"; do
    if [ "$i" == "." ]; then
      return
    fi
  done
  echo "Remis!"
  exit
}

# Funkcja do zapisywania gry
save_game() {
  echo "${board[@]}" > "./savegame.txt"
  echo "$turn" >> "./savegame.txt"
  echo "Gra zapisana!"
}

# Funkcja do wczytywania gry
load_game() {
  if [ -f "./savegame.txt" ]; then
    read -a board < "./savegame.txt"       # Odczytuje stan planszy
    read turn < <(tail -n 1 "./savegame.txt") # Odczytuje numer tury
    echo "Gra wczytana!"
  else
    echo "Brak zapisanego stanu gry."
  fi
}

# Funkcja do obsługi tury gracza
player_turn() {
  local player=$1
  local valid_move=false
  while [ $valid_move == false ]; do
    echo "Gracz $player, wybierz pozycję (1-9) lub wpisz 'save' aby zapisać grę:"
    read -r position

    if [ "$position" == "save" ]; then
      save_game
      continue
    elif [ "$position" -ge 1 ] && [ "$position" -le 9 ] && [ "${board[$((position - 1))]}" == "." ]; then
      board[$((position - 1))]=$player
      valid_move=true
    else
      echo "Nieprawidłowy ruch, spróbuj ponownie."
    fi
  done
}

# Funkcja do obsługi tury komputera
computer_turn() {
  local player=$1
  local position
  while true; do
    position=$((RANDOM % 9))
    if [ "${board[$position]}" == "." ]; then
      board[$position]=$player
      echo "Komputer wybrał pozycję $((position + 1))."
      break
    fi
  done
}

# Wybór trybu gry
echo "Wybierz tryb gry:"
echo "1) Dwóch graczy"
echo "2) Gra z komputerem"
read -r mode

# Czy chcesz wczytać zapisany stan gry?
echo "Czy chcesz wczytać zapisany stan gry? (t/n)"
read -r load
if [ "$load" == "t" ]; then
  load_game
fi

# Rozgrywka
while true; do
  draw_board
  if [ $((turn % 2)) -eq 0 ]; then
    player_turn "X"
  else
    if [ "$mode" -eq 2 ]; then
      computer_turn "O"
    else
      player_turn "O"
    fi
  fi

  check_winner
  check_draw

  ((turn++))
done
