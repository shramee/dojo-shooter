let vmin = 500;
let shapeShifterAni;

function setup() {
  vmin = Math.min(windowHeight, windowWidth);
  createCanvas(vmin, vmin);
  shapeShifterAni = loadAnimation(
    'assets/character_zombie_switch0.png',
    'assets/character_zombie_switch1.png',
  );
  shapeShifterAni.frameDelay = 20;
  noStroke();
}

function coord(val, is_y = false) {
  if (is_y) val *= -1;
  let display_field = vmin / 2;
  return (val * display_field) / 1000;
}

function draw() {
  translate(vmin / 2, vmin / 2);
  background(240, 240, 240);
  fill(255, 0, 0);
  ellipse(0, 0, 25, 25);

  fill(0, 0, 0);

  window.dojo.zombies_on_chain.forEach(([x, y]) => {
    ellipse(coord(x), coord(y, 'y'), 1, 1);
    text(`${x}, ${y}`, coord(x), coord(y, 'y') - 5);
  });
  animation(shapeShifterAni, 250, 80);
}
