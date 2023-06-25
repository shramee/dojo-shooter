function asciiToFelt(str) {
  if (!isNaN(str)) return '' + str;
  var arr1 = [];
  for (var n = 0, l = str.length; n < l; n++) {
    const hex = Number(str.charCodeAt(n)).toString(16);
    arr1.push(hex);
  }
  let hex = arr1.join('');
  if (hex % 2) hex = '0' + hex;
  return BigInt('0x' + hex).toString();
}

class DojoCalls {
  zombies_on_chain = [];
  rpcUrl = ecs_data.rpc || 'localhost:5050';
  constructor() {
    this.world_addr = ecs_data.world_addr;
    this.rpc = new starknet_.RpcProvider({
      nodeUrl: this.rpcUrl,
    });

    // initialize existing pre-deployed account 0 of Devnet
    const privateKey =
      '0x0326b6d921c2d9c9b76bb641c433c94b030cf57d48803dc742729704ffdd0fc6';
    const starkKeyPair = starknet_.ec.getKeyPair(privateKey);
    const accountAddress =
      '0x04b352538f61697825af242c9c451df02a40cca99391a47054489dee82138008';

    this.account = new starknet_.Account(
      this.rpc,
      accountAddress,
      starkKeyPair,
    );
    setTimeout(async () => {
      await starknet.enable();
      this.contract = new starknet_.Contract(
        ecs_data.abi,
        this.world_addr,
        starknet.provider,
      );
    }, 1000);
  }

  async raw_fetch(method, params = []) {
    let req = await fetch(this.rpcUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        jsonrpc: '2.0',
        id: 1,
        method,
        params,
      }),
    });
    return await req.json();
  }

  async exec_system(system_name, calldata) {
    const nonce = await this.account.getNonce();
    return await this.account.execute(
      {
        contractAddress: this.world_addr,
        // Entrypoint for execute: 0x02400...b1c44
        entrypoint: 'execute',
        // '0x240060cdb34fcc260f41eac7474ee1d7c80b7e3607daff9ac67c7ea2ebb1c44',
        calldata: [asciiToFelt(system_name), calldata.length, ...calldata],
      },
      undefined,
      {
        nonce,
        maxFee: 99999999999, // TODO: Update
      },
    );
  }

  async shoot(x, y) {
    x = Math.round(x);
    y = Math.round(y) * -1;
    x = x < 0 ? Math.abs(x) + 4294967296 : Math.abs(x);
    y = y < 0 ? Math.abs(y) + 4294967296 : Math.abs(y);
    let response = await this.exec_system('Shoot', [x, y]);

    console.log(response);
  }

  async fetch_zombies() {
    let response = await window.dojo.raw_fetch('starknet_call', [
      {
        contract_address: this.world_addr,
        entry_point_selector:
          '0x027706e83545bc0fb130476239ec381f65fba8f92e2379d60a07869aa04b4ccc',
        calldata: ['0x5a6f6d626965', '0'],
      },
      'pending',
    ]);

    let { result } = response;

    if (!result) {
      return console.log('Error occurred', response);
    }

    let zombies_count = parseInt(result[0]);
    let starting_index = 2 + zombies_count;
    let zombie_data_gap = 1 + parseInt(result[starting_index]); // Gap is

    this.zombies_on_chain = [];

    for (let i = 0; i < zombies_count; i++) {
      // zi is index of individual Zombie data span
      let zid = parseInt(result[1 + i]);
      let zi = starting_index + i * zombie_data_gap;
      //   console.log(i, zi, result[zi]);
      let x = parseInt(result[zi + 1]);
      let y = parseInt(result[zi + 2]);

      if (x >= 4294967296) {
        x -= 4294967296;
        x *= -1;
      }
      if (y >= 4294967296) {
        y -= 4294967296;
        y *= -1;
      }

      this.zombies_on_chain.push([x, y, zid]);
    }
    // this.zombies_on_chain = result;
  }

  start() {
    this.fetch_zombies();
    this.interval = setInterval(() => {
      this.fetch_zombies();
    }, 100);
  }

  stop() {
    clearInterval(this.interval);
  }
}

window.dojo = new DojoCalls();
window.dojo.start();
