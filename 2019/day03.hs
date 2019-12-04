-- --- Day 3: Crossed Wires ---

import Data.List
import Data.List.Split
import Data.Maybe

wires :: String -> [[String]]
wires contents = map (splitOn ",") (lines contents)

coords :: [String] -> [(Int, Int)] -> [(Int, Int)]
coords [] list = list
coords (h:hs) list =
    let current = head list
        c = head h
        n = read (tail h) :: Int
    in coords hs ((move c n current) ++ list)

crosses :: [(Int, Int)] -> [(Int, Int)] -> [(Int, Int)]
crosses list1 list2 = delete (0, 0) (intersect list1 list2)

move :: Char -> Int -> (Int, Int) -> [(Int, Int)]
move 'L' n (x, y) = reverse (map (\i -> (x - i, y)) [1..n])
move 'U' n (x, y) = reverse (map (\i -> (x, y - i)) [1..n])
move 'R' n (x, y) = reverse (map (\i -> (x + i, y)) [1..n])
move 'D' n (x, y) = reverse (map (\i -> (x, y + i)) [1..n])

distances :: [(Int, Int)] -> [Int]
distances list = map distance list

distance :: (Int, Int) -> Int
distance (x, y) = (abs x) + (abs y)

closestDistance :: [[String]] -> Int
closestDistance [wire1, wire2] =
    let coords1 = coords wire1 [(0, 0)]
        coords2 = coords wire2 [(0, 0)]
        candidates = crosses coords1 coords2
    in foldr1 min (distances candidates)

-- --- Part Two ---
delay :: (Int, Int) -> [(Int, Int)] -> Int
delay point coords = fromMaybe (-1) (elemIndex point coords)

combinedDelays :: [(Int, Int)] -> [(Int, Int)] -> [(Int, Int)] -> [Int]
combinedDelays list coords1 coords2 = map (\point -> (delay point coords1) + (delay point coords2)) list

minCombinedDelay :: [[String]] -> Int
minCombinedDelay [wire1, wire2] =
    let coords1 = coords wire1 [(0, 0)]
        coords2 = coords wire2 [(0, 0)]
        candidates = crosses coords1 coords2
    in foldr1 min (combinedDelays candidates (reverse coords1) (reverse coords2))

----
main :: IO ()
main = do
    contents <- readFile "inputs/input03.txt"
    --print $ (closestDistance (wires contents))
    print $ (minCombinedDelay (wires contents))
