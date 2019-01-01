-- --- Day 3: Perfectly Spherical Houses in a Vacuum ---

import Data.List

instructions :: String -> IO String
instructions path = do
    contents <- readFile path
    return contents

houses :: String -> [(Int, Int)] -> [(Int, Int)]
houses "" list = list
houses (h:hs) list =
    let current = head list
    in houses hs ([(move h current)] ++ list)

everyOther :: String -> String
everyOther "" = ""
everyOther (h:hs) = h : everyOther (drop 1 hs)

roboHouses :: String -> [(Int, Int)] -> [(Int, Int)]
roboHouses (h:hs) list =
    let santaHouses = houses (everyOther (h:hs)) list
        roboSantaHouses = houses (everyOther hs) list
    in santaHouses ++ roboSantaHouses

move :: Char -> (Int, Int) -> (Int, Int)
move '<' (x, y) = (x - 1, y)
move '^' (x, y) = (x, y - 1)
move '>' (x, y) = (x + 1, y)
move 'v' (x, y) = (x, y + 1)

--How many houses receive at least one present?
countUniq :: [(Int, Int)] -> Int
countUniq houses = length (nub houses)

main :: IO ()
main = do
    s <- instructions "inputs/input03.txt"
    print $ countUniq (houses s [(0, 0)])
    print $ countUniq (roboHouses s [(0, 0)])
