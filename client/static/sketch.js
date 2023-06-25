let vmin = 500;
let shape_shifter_ani;
let blaster, zombie_sprites, center_patch;
let clicked = false;
let click_coordinates = [100, 0];
let gun_rotation = findAngleToRotateInRads(click_coordinates);

function preload() {
  blaster = loadImage('assets/ImageToStl.com_blasterA.png');
  center_patch = loadImage('assets/patch.png');
  zombie_sprites = [
    loadImage('assets/character_zombie_switch0.png'),
    loadImage('assets/character_zombie_switch1.png'),
  ];
}

function setup() {
  vmin = Math.min(windowHeight, windowWidth);
  createCanvas(vmin, vmin);
  imageMode(CENTER);
  noStroke();
}

function renderZombie(x, y, z_id) {
  //   text(`${x}, ${y}`, coord(x) + 25, coord(y, 'y') - 5);
  //   console.log(Math.floor(frameCount / 20)) % 2);
  ellipse(
    coord(x),
    coord(y, 'y') + (vmin * 25) / 1000,
    (vmin * 52) / 1000,
    (vmin * 52) / 1000,
  );
  image(
    zombie_sprites[
      Math.floor(z_id * 3 + frameCount / 12 + 1.5 * (z_id % 6)) % 2
    ],
    coord(x),
    coord(y, 'y'),
    (vmin * 72) / 1000,
    (vmin * 90) / 1000,
  );
}

function coord(val, is_y = false) {
  if (is_y) val *= -1;
  let display_field = vmin / 2;
  return (val * display_field) / 1000;
}

function draw() {
  translate(vmin / 2, vmin / 2);
  background(189, 137, 89);

  image(center_patch, 0, 0, (160 * vmin) / 1000, (160 * vmin) / 1000);

  fill(46, 48, 105);
  ellipse(0, 0, (vmin * 40) / 1000, (vmin * 40) / 1000);
  fill(255, 0, 0);
  angleMode(RADIANS);

  fill(0, 0, 0, 50);
  window.dojo.zombies_on_chain.forEach(([x, y, id]) => renderZombie(x, y, id));
  //   animation(shape_shifter_ani);

  rotate(gun_rotation);
  image(blaster, 0, 0, (100 * vmin) / 1000, (0.25 * (100 * vmin)) / 1000);
}

function mouseClicked() {
  clicked = true;
  // convert default P5 coordinates with (0,0) to coordinates with (0,0) as center
  click_coordinates = [mouseX - vmin / 2, mouseY - vmin / 2];
  gun_rotation = findAngleToRotateInRads(click_coordinates);
  if (click_coordinates[0] < 0) {
    gun_rotation += Math.PI;
  }
  dojo.shoot(...click_coordinates);
  // prevent default
  return false;
}

function findAngleToRotateInRads([coordX, coordY]) {
  // return in rads
  return Math.atan(coordY / coordX);
}
