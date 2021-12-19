// --- Day 19: Beacon Scanner ---

using Lambda;

typedef Rotation = { x:Int, y:Int };
typedef Difference = Array<Int>;

class Beacon {
    public var x:Int;
    public var y:Int;
    public var z:Int;

    public function new(coords:Array<Int>) {
        this.x = coords[0];
        this.y = coords[1];
        this.z = coords[2];
    }

    public function difference(beacon:Beacon):Difference {
        return [this.x - beacon.x, this.y - beacon.y, this.z - beacon.z];
    }

    public function shiftBy(difference:Difference) {
       return new Beacon([this.x + difference[0], this.y + difference[1], this.z + difference[2]]);
    }

    // This helped: https://en.wikipedia.org/wiki/Rotation_matrix#In_three_dimensions
    // https://stackoverflow.com/questions/16452383/how-to-get-all-24-rotations-of-a-3-dimensional-array
    public function rotate(rotation:Rotation):Beacon {
        return rotateX(rotation.x).rotateY(rotation.y);
    }

    public function rotateX(x:Int):Beacon {
        var coords:Array<Int> = [];

        switch x {
            case 0: coords = [this.x, this.y, this.z];
            case 1: coords = [this.x, -this.y, -this.z];
            case 2: coords = [this.y, this.x, -this.z];
            case 3: coords = [this.y, -this.x, this.z];
            case 4: coords = [this.y, this.z, this.x];
            case 5: coords = [this.y, -this.z, -this.x];
        }
        return new Beacon(coords);
    }

    public function rotateY(y:Int):Beacon {
        var coords:Array<Int> = [];

        switch y {
            case 0: coords = [this.x, this.y, this.z];
            case 1: coords = [this.z, this.y, -this.x];
            case 2: coords = [-this.x, this.y, -this.z];
            case 3: coords = [-this.z, this.y, this.x];
        }
        return new Beacon(coords);
    }

    public function toString() {
        return [this.x, this.y, this.z].toString();
    }

    public function equal(beacon:Beacon):Bool {
        return this.x == beacon.x && this.y == beacon.y && this.z == beacon.z;
    }
}

class Scanner {
    public var id:Int;
    public var beacons:Array<Beacon>;
    public var rotation:Rotation;
    public var shift:Difference;

    public var size(get, never):Int;

    public function new(id:Int, beacons:Array<Beacon>, ?rotation:Rotation, ?shift:Difference) {
        this.id = id;
        this.beacons = beacons;
        this.rotation = rotation;
        if (shift != null)
            this.shift = shift;
        else
            this.shift = [0, 0, 0];

    }

    public function rotate(rotation:Rotation):Scanner {
        var beacons:Array<Beacon> = this.beacons.map(b -> b.rotate(rotation));
        return new Scanner(this.id, beacons, rotation);
    }

    public function shiftBy(difference:Difference):Scanner {
        var beacons:Array<Beacon> = this.beacons.map(b -> b.shiftBy(difference));
        return new Scanner(this.id, beacons, this.rotation, difference);
    }

    public function countCommonBeacons(scanner):Int {
        var map = new Map<String, Bool>();
        var count = 0;
        for (beacon in beacons) {
            map[beacon.toString()] = true;
        }

        var otherBeacons:Array<Dynamic> = scanner.beacons;
        for (beacon in otherBeacons) {
            if (map.exists(beacon.toString())) {
                count++;
            }
        }
        return count;
    }

    public function overlap(scanner: Scanner) {
        for (x in 0...6) {
            for (y in 0...4) {
                var rotated = overlapWithRotation(scanner, {x: x, y: y });
                if (rotated != null)
                    return rotated;
            }
        }
        return null;
    }

    public function overlapWithRotation(scanner: Scanner, rotation:Rotation):Scanner {
        var rotated:Scanner = rotate(rotation);
        for (beacon in scanner.beacons) {
            for (rotatedBeacon in rotated.beacons) {
                var difference:Difference = beacon.difference(rotatedBeacon);
                var moved:Scanner = rotated.shiftBy(difference);
                if (moved.countCommonBeacons(scanner) >= 12) {
                    return moved;
                }
            }
        }

        return null;
    }

    public function distanceFrom(scanner: Scanner):Int {
        var sum = function(num, total) return total += num;
        return [for (i in 0...3) this.shift[i] - scanner.shift[i]].map(i -> Std.int(Math.abs(i))).fold(sum, 0);
    }

    public function toString() {
        return 'Scanner ${this.id} (rotation: ${this.rotation}, shift: ${shift}): <' + beacons.toString() + ">";
    }

    private function get_size() {
        return this.beacons.length;
    }
}

class Day19 {
    static function input(fileName):Array<Scanner> {
        var content:Array<String> = sys.io.File.getContent(fileName).split("\n");
        var beacons:Array<Beacon> = [];
        var scanners:Array<Scanner> = [];
        var id:Int = 0;

        for (line in content) {
            if (line.length == 0) continue;
            if (line.indexOf("scanner") > 0) {
                if (beacons.length > 0) {
                    scanners.push(new Scanner(id, beacons));
                    beacons = [];
                    id++;
                }
            } else {
                var beacon:Beacon = new Beacon(line.split(",").map(i -> Std.parseInt(i)));
                beacons.push(beacon);
            }
        }
        scanners.push(new Scanner(id, beacons));

        return scanners;
    }

    static function positionAllScanners(scanners:Array<Scanner>):Array<Scanner> {
        var positioned:Array<Scanner> = [];
        // Use first scanner as reference and position the others relative to it
        positioned.push(scanners.shift());

        while (scanners.length > 0) {
            var candidate:Scanner = scanners.shift();
            var overlap:Scanner = null;

            for (ref in positioned) {
                overlap = candidate.overlap(ref);
                if (overlap != null)
                    break;
            }
            if (overlap != null) {
                positioned.push(overlap);
            } else {
                scanners.push(candidate);
            }
        }

        return positioned;
    }

    static function unique(beacons:Array<Beacon>):Array<Beacon> {
        var map = new Map<String, Bool>();
        var unique = new Array<Beacon>();
        for (beacon in beacons) {
            if (!map.exists(beacon.toString())) {
                unique.push(beacon);
                map[beacon.toString()] = true;
            }
        }
        return unique;
    }

    static function mergeAllScanners(scanners:Array<Scanner>):Array<Beacon> {
        var allBeacons:Array<Beacon> = [];
        for (scanner in scanners) {
            allBeacons = allBeacons.concat(scanner.beacons);
        }

        return unique(allBeacons);
    }

    static function allDistances(scanners:Array<Scanner>):Array<Int> {
        var distances:Array<Int> = [];
        for (i in 0...scanners.length-1)
            for (j in 1...scanners.length)
                distances.push(scanners[i].distanceFrom(scanners[j]));

        return distances;
    }

    static public function main():Void {
        var scanners = input("inputs/input19.txt");
        var positioned = positionAllScanners(scanners);

        // Part 1
        var allBeacons = mergeAllScanners(positioned);
        trace(unique(allBeacons).length);

        // Part 2
        var distances = allDistances(positioned);
        trace(distances.fold(Math.max, distances[0]));
    }
}

// haxe --run Day19.hx
// Day19.hx:240: 330
// Day19.hx:244: 9634
