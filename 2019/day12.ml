(* --- Day 12: The N-Body Problem --- *)

type moon = {
  position: int * int * int;
  velocity: int * int * int;
}

module StringMap = Map.Make(String)

let print { position=(x, y, z); velocity=(u, v, w) } =
  Printf.printf "Position = <x=%d, y=%d, z=%d>, Velocity=<x=%d, y=%d, z=%d>\n" x y z u v w

let rec gcd u v =
  if v <> 0 then (gcd v (u mod v))
  else (abs u)

let lcm m n =
  match m, n with
  | 0, _ | _, 0 -> 0
  | m, n -> abs (m * n) / (gcd m n)

let velocity_from_gravity v x1 x2 =
  if x1 > x2 then v - 1 else (if x1 < x2 then v + 1 else v)

let apply_gravity { position=(x1, y1, z1); velocity=(u1, v1, w1) } { position=(x2, y2, z2); velocity=_ } =
  { position=(x1, y1, z1); velocity=((velocity_from_gravity u1 x1 x2), (velocity_from_gravity v1 y1 y2), (velocity_from_gravity w1 z1 z2)) }

let rec calculate_velocity moon moons =
  match moons with
  | [] -> moon
  | m::ms -> calculate_velocity (apply_gravity moon m) ms

let step_velocity moons =
  List.map (fun moon -> calculate_velocity moon (List.filter (fun m -> m != moon) moons)) moons

let calculate_position { position=(x, y, z); velocity=(u, v, w) } =
  { position=(x+u, y+v, z+w); velocity=(u, v, w) }

let step_position moons = List.map calculate_position moons

let potential_energy { position=(x, y, z); velocity=_ } = (abs x) + (abs y) + (abs z)
let kinetic_energy { position=_; velocity=(u, v, w) } = (abs u) + (abs v) + (abs w)
let energy moon = (potential_energy moon) * (kinetic_energy moon)

let rec system_energy moons = List.fold_left ( + ) 0 (List.map energy moons)

let rec simulate moons steps =
  match steps with
  | 0 -> moons
  | _ -> simulate (step_position (step_velocity moons)) (steps - 1)

let axis_pos { position=(x, y, z); velocity=(u, v, w) } axis =
  match axis with
  | 0 -> Printf.sprintf "%d %d" x u
  | 1 -> Printf.sprintf "%d %d" y v
  | 2 -> Printf.sprintf "%d %d" z w
  | _ -> ""

let rec axis_state moons axis =
  match moons with
  | [] -> ""
  | m::ms -> String.concat (axis_pos m axis) ["|"; (axis_state ms axis)]

let rec period_for_axis moons states axis period : int =
  let state = (axis_state moons axis) in
  if (StringMap.mem state states) then
    period
  else
    let simulated_moons = simulate moons 1 in
    (period_for_axis simulated_moons (StringMap.add state true states) axis (period + 1))

let system_period moons =
  lcm (period_for_axis moons StringMap.empty 0 0) (lcm (period_for_axis moons StringMap.empty 1 0) (period_for_axis moons StringMap.empty 2 0))

(* Input:
  <x=-7, y=-8, z=9>
  <x=-12, y=-3, z=-4>
  <x=6, y=-17, z=-9>
  <x=4, y=-10, z=-6> *)
let () =
  let initial_positions = [ (-7, -8, 9); (-12, -3, -4); (6, -17, -9); (4, -10, -6) ] in
  let moons = List.map (fun t -> { position=t; velocity=(0,0,0) }) initial_positions in
  (* --- Part One --- *)
  let simulated_moons = (simulate moons 1000) in
  List.iter print moons;
  Printf.printf "Total energy=%d\n" (system_energy simulated_moons)
  Printf.printf "System period=%d\n" (system_period moons);

(* --- Part One --- *)
(* Total energy=12773 *)

(* --- Part Two --- *)
(* System period=306798770391636 *)
