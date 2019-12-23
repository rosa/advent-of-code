Module: day16
Synopsis: Day 16: Flawed Frequency Transmission
Author: rosa

define function character-to-integer
  (character :: <character>)
  as(<integer>, character) - as(<integer>, '0');
end function character-to-integer;

define function vector-to-integer
  (input :: <vector>)
  string-to-integer(join(map(method (x) integer-to-string(x) end, input), ""))
end function vector-to-integer;

define function parse
  (sequence :: <string>)
  let parsed = make(<vector>, size: sequence.size);
  for (i from 0 below sequence.size)
    parsed[i] := character-to-integer(sequence[i]);
  end;
  parsed
end function parse;

define function calculate-ith
  (input :: <vector>, i :: <integer>)
  let base = vector(0, 1, 0, -1);
  let base-index = 0;
  let j = 0;
  let output = 0;

  while (j < size(input) + 1)
    for (k from 0 below i + 1)
      if (j + k < size(input) + 1 & j > 0)
        output := output + input[j - 1 + k] * base[base-index];
      end;
    end;
    base-index := modulo(base-index + 1, 4);
    j := j + i + 1;
  end;

  modulo(abs(output), 10)
end function calculate-ith;

define function fft-phase
  (input :: <vector>)
  let output = make(<vector>, size: size(input));

  for (i from 0 below size(output))
    output[i] := calculate-ith(input, i)
  end;
  output
end function fft-phase;

define function fft
  (input :: <vector>, phases :: <integer>)
  let output = input.shallow-copy;
  for (phase from 0 below phases)
    output := fft-phase(output)
  end;
  output
end function fft;

define function slice
  (input :: <vector>, offset :: <integer>, n :: <integer>)
  let output = make(<vector>, size: n);
  for (i from offset below offset + n)
    output[i - offset] := input[i];
  end;
  output
end function slice;

// --- Part Two ---
define function extend
  (input :: <vector>, n :: <integer>)
  let m = size(input);
  let output = make(<vector>, size: n * m);
  for (i from 0 below n)
    for (j from 0 below m)
      output[i * m + j] := input[j]
    end
  end;
  output
end function extend;

// Input repeated 10000 times = sequence of length 6,500,000
// Offset = 7 first digits: 5,972,731
// At this point, to calculate the digit 5,972,731th, 5,972,732th, etc,
// we're repeating the 0 from the base pattern (0, 1, 0, -1) 5,972,731 times at least
// So, the first 5,972,731 values are multiplied by 0 and we don't care about them
// The rest are all 1s because 6,500,000 - 5,972,731 = 527,269, way smaller than 5,972,731
// which is the number of 1s we're going to have. Then, we just need to sum the values
// of the tail of the list, starting from the last one up to the first element in the tail
define function fft-tail-phase
  (input :: <vector>)
  let m = size(input);
  let output = input.shallow-copy;
  for (i from m - 1 above 0 by -1)
    output[i - 1] := modulo(output[i - 1] + output[i], 10);
  end;
  output
end function fft-tail-phase;

define function fft-tail
  (input :: <vector>, phases :: <integer>)
  let output = input.shallow-copy;
  for (phase from 0 below phases)
    output := fft-tail-phase(output)
  end;
  output
end function fft-tail;

define function main
    (name :: <string>, arguments :: <vector>)
  let input = read-line(*standard-input*);
  // --- Part One ---
  let output = fft(parse(input), 100);
  format-out("%s\n", vector-to-integer(slice(output, 0, 8)));

  // --- Part Two ---
  let extended-input = extend(parse(input), 10000);
  let offset = vector-to-integer(slice(extended-input, 0, 7));
  let sliced-extended-input = slice(extended-input, offset, size(extended-input) - offset);
  let output-tail = fft-tail(sliced-extended-input, 100);
  format-out("%s\n", vector-to-integer(slice(output-tail, 0, 8)));

  exit-application(0);
end function main;

main(application-name(), application-arguments());

// cat ../inputs/input16.txt | _build/bin/day16
// 68317988
// 53850800
