let vmin = 500;

function setup() {
  vmin = Math.min(windowHeight, windowWidth);
  createCanvas(vmin, vmin);
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
    console.log(coord(x), coord(y, 'y'));
    ellipse(coord(x), coord(y, 'y'), 5, 5);
    text(`${x}, ${y}`, coord(x), coord(y, 'y') - 5);
    noLoop();
  });
}
