(() => {
  const canvas = document.getElementById('canvas');
  var ctx = canvas.getContext('2d');
  window.submitCairo = async () => {
    cairoResp = await cairoResp.text();
    processCairoResp(JSON.parse(cairoResp));
  };

  /*
   * Converts felt to string
   */
  const feltToString = (felt) =>
    felt
      .toString(16) // To hex
      .match(/.{2}/g) // Split into 2 chars
      .map((c) => String.fromCharCode(parseInt(c, 16))) // Get char from code
      .join(''); // Join to a string

  const actionHandlers = {
    arc(x, y, r, s, e) {
      s = (2 * Math.PI * s) / 10000;
      e = (2 * Math.PI * e) / 10000;
      ctx.beginPath();
      ctx.arc(x, y, r, s, e);
      ctx.stroke();
    },
  };

  function handleAction(action, args) {
    action = feltToString(+action);
    console.log(action, args);
    if (typeof actionHandlers[action] === 'function') {
      actionHandlers[action](...args);
    } else if (typeof ctx[action] === 'function') {
      ctx[action](...args);
    } else if (typeof ctx[action] !== 'undefined' && args.length === 1) {
      ctx[action] = args[0];
    }
  }

  function processCairoResp(cairoResp) {
    let dt = cairoResp;
    if (typeof cairoResp === 'string') {
      dt = cairoResp.replace(/,$/, '').split(',');
    }

    ctx.fillStyle = '#fcfaf6';
    ctx.fillRect(0, 0, 9999, 9999);
    ctx.fillStyle = '#fe4a49';
    ctx.strokeStyle = '#fe4a49';

    callbacks = {};

    for (let i = 0; i < dt.length; i++) {
      const action = dt[i];
      const n_args = +dt[i + 1];
      console.log(action, n_args);
      const args = dt.slice(i + 2, i + 2 + n_args);
      handleAction(action, args);
      i += n_args + 1;
    }
  }
})();
