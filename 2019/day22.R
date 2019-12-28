# --- Day 22: Slam Shuffle ---

library(gmp) # GNU Multi-precision library bindings, necessary for Part 2

parse.rule <- function(line) {
  words = unlist(strsplit(line, " "))
  # [0] deal into new stack
  # [1] cut N cards
  # [2] deal with increment N
  if ( line == "deal into new stack" ) {
    c(0, 0)
  } else if ( words[1] == "cut" ) {
    c(1, as.integer(words[2]))
  } else {
    c(2, as.integer(words[4]))
  }
}

parse.rules <- function(filename) {
  lines = scan(filename, what = "character", sep = "\n")
  lapply(lines, parse.rule)
}

cards <- function(size) {
  c(0:(size-1))
}

shuffle.rule <- function(cards, rule) {
  # [0] deal into new stack
  # [1] cut N cards
  # [2] deal with increment N
  if ( rule[1] == 0 ) {
    rev(cards)
  } else if ( rule[1] == 1 ) {
    cut.cards(cards, rule[2])
  } else {
    deal.cards(cards, rule[2])
  }
}

cut.cards <- function(cards, n) {
  if ( n >= 0 ) {
    c(cards[(n+1):length(cards)], cards[0:n])
  } else {
    cut.cards(cards, length(cards) + n)
  }
}

deal.cards <- function(cards, increment) {
  n <- length(cards)
  dealt <- integer(n)
  i <- 0
  for ( card in cards ) {
    dealt[i + 1] <- card
    i <- (i + increment) %% n
  }
  dealt
}

shuffle <- function(cards, rules) {
  for ( rule in rules ) {
    cards <- shuffle.rule(cards, rule)
  }
  cards
}

modular_inverse <- function(b, m) {
  b = (b + m) %% m
  # We can assume b and m are coprime
  # Then the modular multiplicative inverse is b^(m-2) (mod m)
  powm(b, m - 2, m)
}

# Compute a/b (mod m)
# To find a/b (mod m) we first need to compute the modular multiplicative inverse of a (mod m)
# Then we compute a * (inverse of b) (mod m)
modular_division <- function(a, b, m) {
  a = (a + m) %% m
  (a * modular_inverse(b, m)) %% m
}

revshuffle.rule.individual <- function(deck_size, position, rule) {
  # Focus on what happens to a specific position on the deck
  # Since we aren't going to use vectors, we can work with 0-based vectors again
  # This function returns the position from the original deck we need to look at
  if ( rule[1] == 0 ) {
    # [0] deal into new stack
    # 0 1 2 3 4 5 6 7 8 9 -> 9 8 7 6 5 4 3 2 1 0
    # Card on position i becomes previous size - i - 1
    deck_size - position - 1
  } else if ( rule[1] == 1 ) {
    # [1] cut N cards
    # cut 3: 0 1 2 3 4 5 6 7 8 9 -> 3 4 5 6 7 8 9 0 1 2
    # Card on position i becomes previous (i + N) %% size
    # Add size to account for negative N
    (position + rule[2] + deck_size) %% deck_size
  } else {
    # [2] deal with increment N
    # deal 3: 0 1 2 3 4 5 6 7 8 9 -> 0 7 4 1 8 5 2 9 6 3
    # Card on position i becomes previous j such that (N * j) ≡ i (mod size)
    # For example, with 3 and 10 sized deck,
    # position 0 gets what there was in position 0 as 3 * 0 ≡ 0 (mod 10)
    # position 1 gets what there was in position 7 as 3 * 7 ≡ 1 (mod 10)
    # position 2 gets what there was in position 4 as 3 * 4 ≡ 2 (mod 10)
    # position 5 gets what there was in position 5 as 3 * 5 ≡ 5 (mod 10)
    # position 8 gets what there was in position 6 as 3 * 6 ≡ 8 (mod 10)
    # This means we need to resolve the linear congruence ax ≡ b (mod m),
    # where a = N, b = i and m = size. x is b/a (mod m). a and m need to be co-primes
    # and we know this is true for our input, so we can save the checks for that
    # Then we calculate i / N (mod size)
    modular_division(position, rule[2], deck_size)
  }
}

revshuffle.individual <- function(deck_size, position, rules) {
  for ( rule in rules ) {
    position <- revshuffle.rule.individual(deck_size, position, rule)
  }
  position
}

rules <- parse.rules("inputs/input22.txt")
# --- Part One ---
cards <- shuffle(cards(10007), rules)
print(which(2019 == cards) - 1)

# Read 100 items
# [1] 6831

# --- Part Two ---
# Apply individual shuffle to the 119315717514047 sized deck 101741582076661 times in a row

# We focus on the position asked and apply the individual rules in reverse order
# Applying the reverse rules once:
x = 2020
deck_size = 119315717514047
p = revshuffle.individual(119315717514047, x, rev(rules))
# Applying them twice
q = revshuffle.individual(119315717514047, p, rev(rules))
# Since all the reverse rules are linear, we have:
# p = ax + b (mod m) where m is the deck size
# q = ap + b (mod m) = a(ax + b) + b (mod m) = a^2x + ab + b
# Then: p - q = ax - ap (mod m) => (p - q) = a(x - p) (mod m) thus:
# a = (p - q)(modular_inverse(x - p, m))
a = ((p - q) * modular_inverse(x - p, deck_size)) %% deck_size
# b = p - ax (mod m)
b = (p - a*x) %% deck_size

# Applying the shuffle n times:
# a^n*x + a^(n-1)*b + a^(n-2)*b + ... + a^1*b + a^0*b
# a^(n-1)*b + a^(n-2)*b + ... + a^1*b + a^0*b = (a^(n-1) + a^(n-2) + ... + a^1 + a^0) * b
# That's the sum of a geometric series with r = a:
# (a^n - 1) / (a - 1)
# Thus our solution is: a^n*x + ((a^n - 1)/a-1)*b (mod m)
n = 101741582076661
a_n = powm(a, n, deck_size)
print(((a_n * x) + modular_division(a_n - 1, a - 1, deck_size) * b) %% deck_size)

# Big Integer ('bigz') :
# [1] 81781678911487
