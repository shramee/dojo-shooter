function setup() {
  createCanvas(440, 440);
}

const ZERO = 1000000;
const RANGE = 20000;

// Converts percentage * 100 into a ZERO based value
// 100 is center of the map
// 50 is left/top half center of the map
// 200 is right/bottom most point on the map
function val_from_2xpc(pc2x) {
  //   let half_range = RANGE / 2;
  //   ZERO - half_range + (half_range * pc2x) / 100;
}

function process_val(v) {
  PADDING = 20;
  //   console.log(((v - ZERO) / RANGE) * 400 + RANGE / 2);
  return PADDING + (v - ZERO) / RANGE + 400 / 2;
}

function draw() {
  background(220);
  if (window.entity_position.length < 3) return;
  const e1 = window.entity_position[1];
  const e2 = window.entity_position[2];

  ellipse(process_val(e1[0]), process_val(e1[1]), 5);
  ellipse(process_val(e2[0]), process_val(e2[1]), 7);
}
