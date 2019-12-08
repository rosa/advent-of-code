# --- Day 8: Space Image Format ---

use strict;
use warnings;
use 5.010;

my $IMAGE_WIDTH = 25;
my $IMAGE_HEIGHT = 6;
my $LAYER_SIZE = $IMAGE_WIDTH * $IMAGE_HEIGHT;

sub read_layers {
  my $digits = $_[0];
  # Remove all non-digits
  $digits =~ s/\D//g;

  # Split into layers
  my @layers = unpack( "(A$LAYER_SIZE)*", $digits );

  return @layers;
}

sub find_layer_with_fewest_zeros {
  my @layers = @_;
  my $min_zeros = $LAYER_SIZE;
  my $min_layer = "";
  foreach my $layer (@layers) {
    my $count = () = $layer =~ /\Q0/g;
    if($count < $min_zeros) {
      $min_zeros = $count;
      $min_layer = $layer;
    }
  }

  return $min_layer;
}

sub corruption_check {
  my $layer = $_[0];
  my $count_ones = () = $layer =~ /\Q1/g;
  my $count_twos = () = $layer =~ /\Q2/g;

  return $count_ones * $count_twos;
}

# 0 is black, 1 is white, and 2 is transparent.
sub combine_layers {
  my @layers = @_;
  my $combined_layer = '';

  foreach my $i ((0..$LAYER_SIZE)) {
    my $j = 0;
    my $pixel = '';
    do {
      $pixel = substr( $layers[$j], $i , 1 );
      $j++;
    } until ($pixel ne '2');
    $combined_layer .= ( $pixel eq '1' ? '#' : '.');
  }

  return $combined_layer;
}

sub print_layer {
  my @rows = unpack( "(A$IMAGE_WIDTH)*", $_[0] );
  foreach my $row (@rows) {
    print "$row\n";
  }
}

open my $input_handle, '<', 'inputs/input08.txt' or die "Can't open file $!";
read $input_handle, my $image, -s $input_handle;

my @layers = read_layers( $image );
print corruption_check( find_layer_with_fewest_zeros( @layers ) ) . "\n";
# 1441

# --- Part Two ---
print_layer( combine_layers( @layers ) );
# ###..#..#.####.###..###..
# #..#.#..#....#.#..#.#..#.
# #..#.#..#...#..###..#..#.
# ###..#..#..#...#..#.###..
# #.#..#..#.#....#..#.#....
# #..#..##..####.###..#....
# RUZBP
