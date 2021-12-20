// --- Day 20: Trench Map ---

import "io" for File

class Image {
  construct new(image, algorithm) {
    _image = image
    _n = image.count
    _m = image[0].count
    _algorithm = algorithm
    _padding = 3
  }

  pad(filling) {
    for (i in 0..._n) {
      _image[i] = List.filled(_padding, filling) + _image[i] + List.filled(_padding, filling)
    }
    _m = _m + _padding*2

    for (i in 1.._padding) {
      _image.insert(0, List.filled(_m, filling))
      _image.insert(-1, List.filled(_m, filling))
    }

    _n = _n + _padding*2
  }

  unpad() {
    _image.removeAt(0)
    _image.removeAt(-1)

    _n = _n - 2
    for (i in 0..._n) {
      _image[i] = _image[i][1..._m-1]
    }
    _m = _m - 2
  }

  enhance() {
    var enhanced = []
    for (i in 1.._n) {
      enhanced.insert(0, List.filled(_m, 0))
    }

    for (i in 1..._n - 1) {
      for (j in 1..._m - 1) {
        var index = indexForAlgorithm(i, j)
        enhanced[i][j] = _algorithm[index]
      }
    }
    _image = enhanced
  }

  enhance(times) {
    var filling = 0

    for (i in 1..times) {
      // Calculate how to change the pixels in the infinite part. They start all being 0, so they'll
      // switch to whatever the algorithm indicates for all 0s (0). If that's 1, then on the next
      // application, they'd switch to whatever the algorithm indicates for all 1s (511). However, if
      // the algorithm changes all 0s by 0, they'll stay as 0 in every enhancement.
      if (_algorithm[0] == 1) filling = i % 2 == 0 ? _algorithm[0] : _algorithm[-1]

      pad(filling)
      enhance()
      unpad()
    }
  }

  indexForAlgorithm(i, j) {
    var index = 0
    var p = 8
    for (r in [-1, 0, 1]) {
      for (s in [-1, 0, 1]) {
        index = index + _image[i+r][j+s] * 2.pow(p)
        p = p - 1
      }
    }
    return index
  }

  countLit() {
    return _image.map {|row| row.count {|x| x == 1} }.reduce{|x, a| x + a}
  }

  print() {
    System.print("Image(%(_n)x%(_m)):")
    for (row in _image) {
      var str = ""
      for (c in row) str = str + (c == 1 ? "#" : ".")
      System.print(str)
    }
  }
}

var convertToBin = Fn.new { |line|
  var bin = []
  for (c in line) {
    c == "#" ? bin.add(1) : bin.add(0)
  }
  return bin
}

var parse = Fn.new { |filename|
  var input = File.read(filename).split("\n")
  var algorithm = convertToBin.call(input.removeAt(0))
  var image = []
  for (line in input) {
    if (line.count == 0) {
      continue
    }
    image.add(convertToBin.call(line))
  }

  return Image.new(image, algorithm)
}


var img = parse.call("inputs/input20.txt")
// Part 1
img.enhance(2)
System.print(img.countLit())

// Part 1
img.enhance(50 - 2)
System.print(img.countLit())

// wren_cli day20.wren
// 5391
// 16383
