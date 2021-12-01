#!/bin/bash
# --- Day 1: Sonar Sweep ---

increases_count=0
window_increases_count=0
previous=""
window=()

while IFS= read -r line
do
  if ! [[ -z "$previous" ]] && (($previous < $line))
  then
    ((increases_count++))
  fi
  previous=$line

  if ((${#window[@]} == 3))
  then
    if (($line > ${window[0]}))
    then
      ((window_increases_count++))
    fi

    window=( "${window[@]:1}" )
  fi
  window+=( "$line" )

done < "$1"

echo "$increases_count"
echo "$window_increases_count"

# --- Part Two ---
# 199  A      
# 200  A B    
# 208  A B C  
# 210    B C D
# 200  E   C D
# 207  E F   D
# 240  E F G  
# 269    F G H
# 260      G H
# 263        H

# This can be simplified as:
# 199  A1      
# 200  A2 B1    
# 208  A3 B2 C1  
# 210     B3 C2 D1
# 200  E1    C3 D2
# 207  E2 F1    D3
# 240  E3 F2 G1  
# 269     F3 G2 H1
# 260        G3 H2
# 263           H3

# A1 + A2 + A3 < B1 + B2 + B3 <=> A1 + A2 + A3 - B1 - B2 - B3 < 0 <=> A1 - B3 < 0 <=> B3 - A1 > 0
# So, for each line, if (value at line in position + 3 - value at line > 0)

# ./day01.sh inputs/input01.txt
# 1475
# 1516
