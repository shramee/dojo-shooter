class DojoCalls {
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
}

window.dojo = new DojoCalls();

setInterval(async () => {}, 100);
