#!/bin/bash -e

function render_png() {
  PLATE=$1
  SIZE=$2
  echo -e "rendering img/slide_n_snap_test_plate_${PLATE}_render.png"
  openscad \
    --camera=75,75,75,0,-4,8 \
    --imgsize=1024,768 \
    --projection=ortho \
    --colorscheme=Tomorrow \
    -D 'PLATE="'${PLATE}'"' \
    -D 'SIZE="'${SIZE}'"' \
    -o img/slide_n_snap_test_plate_${PLATE}_render.png \
    slide-n-snap-tests.scad 
}

function render_stl() {
  PLATE=$1
  SIZE=$2
  echo -e "rendering stl/slide_n_snap_test_plate_${PLATE}_${SIZE}.stl"
  openscad \
    -D 'PLATE="'${PLATE}'"' \
    -D 'SIZE="'${SIZE}'"' \
    -o stl/slide_n_snap_test_plate_${PLATE}_${SIZE}.stl \
    slide-n-snap-tests.scad 
}

mkdir -p img
mkdir -p stl

for SIZE in "small"; do
for PLATE in "a" "b"; do
  render_png $PLATE $SIZE
done done

for SIZE in "small" "medium" "large"; do
for PLATE in "a" "b"; do
  render_stl $PLATE $SIZE
done done
