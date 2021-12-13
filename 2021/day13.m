% --- Day 13: Transparent Origami ---

1;

function parsedinput = parseinput (path)
  fid = fopen (path);

  coords = [];
  folds = [];

  do
    line = fgetl (fid);

    if (line != -1 && length(line) > 0)
      tokens = regexp(line, 'fold along (y|x)=(\d+)', 'tokens');
      if (isempty(tokens))
        c =  strsplit(line, ",");
        coords = [coords; [str2num(c{1,1}), str2num(c{1,2})]];
      else
        folds = [folds; [tokens{1,1}]];
      endif
    endif
  until (line == -1)

  fclose (fid);

  parsedinput = {coords, folds};
endfunction

function padedup = padup (mat, tosize)
  padedup = [zeros(tosize(1) - size(mat)(1), tosize(2)); mat];
endfunction

function folded = foldup (paper, y)
  top = paper(1:y,:);
  bottom = flipud(paper(y+2:end,:));
  folded = top + padup(bottom, size(top));
endfunction

function folded = foldleft (paper, x)
  % Transpose and fold up
  folded = foldup (paper', x);
  folded = folded';
endfunction

function folded = fold (paper, type, axis)
  switch (type)
    case "x"
      folded = foldleft (paper, axis);
    case "y"
      folded = foldup (paper, axis);
  endswitch
endfunction

parsedinput = parseinput ("inputs/input13.txt");
coords = parsedinput{1,1};
folds = parsedinput{1,2};

paper = zeros (max (coords(:,2)) + 1, max (coords(:,1)) + 1);
for i = 1:length(coords)
  paper(coords(i,2) + 1, coords(i,1) + 1) = 1;
endfor

% First fold:
folded = fold (paper, folds{1,1}, str2num (folds{1,2}));
display (nnz (folded));

% Then all remaining folds:
for i = 2:length(folds)
  folded = fold (folded, folds{i,1}, str2num (folds{i,2}));
end

% This displays a black and white image with the code
imshow(folded)

% octave day13.m
% 17
% ECFHLHZF
