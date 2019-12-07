// --- Day 6: Universal Orbit Map ---

import Foundation

class InputReader {
    let fileName: String

    public init(fileName: String) {
        self.fileName = fileName
    }

    func readLines() -> [String] {
        do {
            let text = try String(contentsOfFile: fileName, encoding: String.Encoding.utf8)
            return text.components(separatedBy: CharacterSet.newlines).filter { $0 != "" }
        } catch {
            fatalError("Cannot load file \(fileName)")
        }
    }
}

class OrbitGraph {
    let graph: [String: String]
    lazy var undirectedGraph: [String: [String]] = {
        graph.reduce(into: [String: [String]]()) { dictionary, edge in
            if dictionary[edge.key] == nil {
                dictionary[edge.key] = []
            }
            if dictionary[edge.value] == nil {
                dictionary[edge.value] = []
            }

            dictionary[edge.key]!.append(edge.value)
            dictionary[edge.value]!.append(edge.key)
        }
    }()

    public init(orbits: [String]) {
        self.graph = orbits
            .map { $0.components(separatedBy: ")") }
            .reduce(into: [String: String]()) { dictionary, components in
                dictionary[components[1]] = components[0]
            }
    }

    public func countAllOrbits() -> Int {
        return graph.keys.map { countReachableNodes(from: $0) }.reduce(into: 0) { (total, count) in total += count }
    }

    public func countOrbitalTransfers(from: String, to: String) -> Int {
        // Dijkstra algorithm
        var nodes = Array(undirectedGraph.keys)
        var previous: [String: String] = [:]
        var distances = nodes.reduce(into: [String: Int]()) { dictionary, node in dictionary[node] = Int.max }

        distances[from] = 0

        while !nodes.isEmpty {
            if let candidate = nextCandidate(nodes: nodes, distances: distances) {
                nodes.remove(at: candidate.offset)
                for neighbour in undirectedGraph[candidate.element]! {
                    if nodes.contains(neighbour) && (distances[candidate.element]! < distances[neighbour]! - 1) {
                        distances[neighbour] = distances[candidate.element]! + 1
                        previous[neighbour] = candidate.element
                    }
                }
            }
        }

        return distances[to]!
    }

    private func nextCandidate(nodes: [String], distances: [String: Int]) -> (offset: Int, element: String)? {
        var min = Int.max
        var candidate: (Int, String)?
        for node in nodes.enumerated() {
            if distances[node.element]! < min {
                candidate = node
                min = distances[node.element]!
            }
        }

        return candidate
    }

    private func countReachableNodes(from: String) -> Int {
        var count = 0
        var node = graph[from]
        while node != nil {
            count += 1
            node = graph[node!]
        }

        return count
    }
}

let reader = InputReader(fileName: "inputs/input06.txt")
let graph = OrbitGraph(orbits: reader.readLines())
// --- Part one ---
print(graph.countAllOrbits())
// 145250

// --- Part Two ---
print(graph.countOrbitalTransfers(from: "YOU", to: "SAN") - 2)
// 274

