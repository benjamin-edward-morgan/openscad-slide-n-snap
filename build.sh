#!/bin/bash -e

function render_png() {
  PLATE=$1
  SIZE=$2
  echo -e "rendering png/slide_n_snap_test_plate_${PLATE}_${SIZE}.png"
  openscad \
    --camera=100,100,100,0,0,0 \
    --imgsize=1024,768 \
    --projection=ortho \
    -D 'CMD_PLATE="'${PLATE}'"' \
    -D 'CMD_SIZE="'${SIZE}'"' \
    -o png/slide_n_snap_test_plate_${PLATE}_${SIZE}.png \
    slide-n-snap-tests.scad 
}

function render_stl() {
  PLATE=$1
  SIZE=$2
  echo -e "rendering stl/slide_n_snap_test_plate_${PLATE}_${SIZE}.stl"
  openscad \
    -D 'CMD_PLATE="'${PLATE}'"' \
    -D 'CMD_SIZE="'${SIZE}'"' \
    -o stl/slide_n_snap_test_plate_${PLATE}_${SIZE}.stl \
    slide-n-snap-tests.scad 
}

mkdir -p png
mkdir -p stl

for SIZE in "small" "medium" "large"; do
for PLATE in "a" "b"; do
  render_png $PLATE $SIZE
done done

for SIZE in "small" "medium" "large"; do
for PLATE in "a" "b"; do
  render_stl $PLATE $SIZE
done done
