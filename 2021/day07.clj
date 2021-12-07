; --- Day 7: The Treachery of Whales ---

(require '[clojure.string :as str])

(defn int-range [start end]
  (map int (range start end)))

(defn find-min-fuel [fuel-fn crabs]
  (->>
    (int-range 0 (apply max crabs))
    (map #(fuel-fn crabs %))
    (apply min)))

(defn distances [crabs position]
  (map #(Math/abs (- % position)) crabs))

(defn fuel-constant [crabs position]
  (->>
    (distances crabs position)
    (reduce +)))

(defn fuel-linear [crabs position]
  (->>
    (distances crabs position)
    (map #(int-range 1 (+ % 1)))
    (map #(reduce + %))
    (reduce +)))

(map #(map int (range 1 (+ % 1))) distances)

(defn crab-positions [string]
  (->>
   (clojure.string/split string #",")
   (map #(Integer/parseInt %))))

(def crabs
  (->>
    (slurp "inputs/input07.txt")
    str/trim
    crab-positions))

(->> crabs (find-min-fuel fuel-constant) println)
(->> crabs (find-min-fuel fuel-linear) println)

; user=> (load-file "day07.clj")
; 356179
; 99788435
; nil
