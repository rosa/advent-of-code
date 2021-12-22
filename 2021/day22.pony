// --- Day 22: Reactor Reboot ---

use "files"
use "collections"

primitive On
primitive Off

type Status is (On | Off)

class RebootStep
  let action: Status
  let x: (I64, I64)
  let y: (I64, I64)
  let z: (I64, I64)

  new parse(instruction: String) ? =>
    let pieces: Array[String] = instruction.split(" ,=")
    action = if pieces(0)? == "on" then On else Off end
    x = parse_range(pieces(2)?)?
    y = parse_range(pieces(4)?)?
    z = parse_range(pieces(6)?)?

  new init(action': Status, x': (I64, I64), y': (I64, I64), z': (I64, I64)) =>
    action = action'
    x = x'
    y = y'
    z = z'

  fun size(): I64 =>
    (x._2 - x._1) * (y._2 - y._1) * (z._2 - z._1)

  // This combines the ranges, subtracting other from this
  fun sub(other: RebootStep): Array[RebootStep] =>
    if disjoint(other) then [RebootStep.init(action, x, y, z)] else
      let steps: Array[RebootStep] = []
      for rx in subtract_ranges(x, other.x).values() do
        steps.push(RebootStep.init(action, rx, y, z))
      end

      let ix = intersect_ranges(x, other.x)
      for ry in subtract_ranges(y, other.y).values() do
        steps.push(RebootStep.init(action, ix, ry, z))
      end

      let iy = intersect_ranges(y, other.y)
      for rz in subtract_ranges(z, other.z).values() do
        steps.push(RebootStep.init(action, ix, iy, rz))
      end

      steps
    end

  fun range_normalised(coord: String): Range[USize] =>
    match coord
    | "x" => normalise_range(x._1, x._2)
    | "y" => normalise_range(y._1, y._2)
    | "z" => normalise_range(z._1, z._2)
    else
      Range(0, 0)
    end

  fun disjoint(other: RebootStep): Bool =>
    (x._1 > other.x._2) or (x._2 < other.x._1) or
    (y._1 > other.y._2) or (y._2 < other.y._1) or
    (z._1 > other.z._2) or (z._2 < other.z._1)


  fun tag parse_range(range: String): (I64, I64) ? =>
    let pieces: Array[String] = range.split_by("..")
    (pieces(0)?.i64()?, pieces(1)?.i64()? + 1)

  fun tag normalise_range(a1: I64, a2: I64): Range[USize] =>
    let b1 = (a1 + 50).max(0)
    let b2 = (a2 + 50).min(101)
    if b2 >= b1 then Range(b1.usize(), b2.usize()) else Range(0, 0) end

  fun tag subtract_ranges(a: (I64, I64), b: (I64, I64)): Array[(I64, I64)] =>
    if (b._1 <= a._1) and (b._2 >= a._2) then []
    elseif (b._1 <= a._1) and (b._2 < a._2) then [(b._2, a._2)]
    elseif (b._1 > a._1) and (b._2 >= a._2) then [(a._1, b._1)]
    else [(a._1, b._1); (b._2, a._2)]
    end

  fun tag intersect_ranges(a: (I64, I64), b: (I64, I64)): (I64, I64) =>
    if (b._1 <= a._1) and (b._2 >= a._2) then a
    elseif (b._1 <= a._1) and (b._2 < a._2) then (a._1, b._2)
    elseif (b._1 > a._1) and (b._2 >= a._2) then (b._1, a._2)
    else b
    end

class ReactorCore
  let steps: List[RebootStep]

  new create() =>
    steps = List[RebootStep]()

  fun initialize(): USize =>
    let init_region: Map[String, Bool] = Map[String, Bool](101 * 3)

    for step in steps.values() do
      for x in step.range_normalised("x") do
        for y in step.range_normalised("y") do
          for z in step.range_normalised("z") do
            let key: String = x.string() + "," + y.string() + "," + z.string()
            init_region.insert(key, step.action is On)
          end
        end
      end
    end

    var count: USize = 0
    for v in init_region.values() do
      if v is true then count = count + 1 end
    end
    count

  fun ref register(step: RebootStep) =>
    steps.push(step)

  fun ref complete_reboot(): I64 =>
    var final_sequence: List[RebootStep] = List[RebootStep]()

    for step in steps.values() do
      let subtracted: List[RebootStep] = List[RebootStep]()
      for current in final_sequence.values() do
        for result in (current.sub(step)).values() do
          subtracted.push(result)
        end
      end
      final_sequence = subtracted
      if step.action is On then final_sequence.push(step) end
    end

    var total: I64 = 0
    for v in final_sequence.values() do
      total = total + v.size()
    end

    total


actor Main
  new create(env: Env) =>
    try
      let path = FilePath(env.root as AmbientAuth, "inputs/input22.txt")
      match OpenFile(path)
        | let file: File =>
          let reactor = ReactorCore.create()
          for line in file.lines() do
            let step = RebootStep.parse(line.string())?
            reactor.register(step)
          end
          env.out.print(reactor.initialize().string())
          env.out.print(reactor.complete_reboot().string())
      end
    end

// ponyc -b day22
// ./day22
// 547648
// 1206644425246111
