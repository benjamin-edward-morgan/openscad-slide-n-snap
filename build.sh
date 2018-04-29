#!/bin/bash -e

openscad -v >/dev/null 2>&1 || { 
  printf "Please set up openscad so that it can be used in this script.\nSee https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Using_OpenSCAD_in_a_command_line_environment\n" 
  exit 1
}

function render_png() {
  PLATE=$1
  SIZE=$2
  FILENAME="img/slide_n_snap_${PLATE}_${SIZE}.png"
  echo -e "rendering ${FILENAME}"
  openscad \
    --camera=75,75,75,0,-4,8 \
    --imgsize=1024,768 \
    --projection=ortho \
    --colorscheme=Tomorrow \
    -D 'PLATE="'${PLATE}'"' \
    -D 'SIZE="'${SIZE}'"' \
    -o $FILENAME \
    slide-n-snap-tests.scad 
}

function render_stl() {
  PLATE=$1
  SIZE=$2
  FILENAME="stl/slide_n_snap_${PLATE}_${SIZE}.stl"
  echo -e "rendering ${FILENAME}"
  openscad \
    -D 'PLATE="'${PLATE}'"' \
    -D 'SIZE="'${SIZE}'"' \
    -o $FILENAME \
    slide-n-snap-tests.scad 
}

mkdir -p img
mkdir -p stl

for SIZE in "small"; do
for PLATE in "test_a" "test_b"; do
  render_png $PLATE $SIZE
done done

for SIZE in "small" "medium" "large"; do
for PLATE in "test_a" "test_b" "female_negative" "male_positive"; do
  render_stl $PLATE $SIZE
done done
