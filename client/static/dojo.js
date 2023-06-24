class DojoCalls {
  zombies_on_chain = [];
  constructor() {
    this.world_addr = ecs_data.world_addr;
    // this.rpc = new starknet.RpcProvider({
    //   nodeUrl: ecs_data.rpc || 'localhost:5050',
    // });

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
    let req = await fetch(ecs_data.rpc || 'http://localhost:5050', {
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
  async fetch_zombies() {
    let response = await window.dojo.raw_fetch('starknet_call', [
      {
        contract_address:
          '0x7f1d6c1b15e03673062d8356dc1174d5d85c310479ec49fe781e8bf89e4c4f8',
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

      this.zombies_on_chain.push([x, y]);
    }
    // this.zombies_on_chain = result;
  }
}

window.dojo = new DojoCalls();
window.dojo.fetch_zombies();
setInterval(() => window.dojo.fetch_zombies(), 100);
