/*
  	World endpoints
	---------------
	ex constructor
	ex initialize
	vi is_authorized
	vi is_account_admin
	ex register_component
	vi component
	ex register_system
	vi system
	ex execute
	ex uuid
	ex set_entity
	ex delete_entity
	vi entity
	vi entities
	ex set_executor
	vi executor
	ex assume_role
	ex clear_role
	vi execution_role
	vi system_components
	vi is_system_for_execution
*/
class DojoCalls {
  constructor() {
    let contract =
      '0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7';
    // this.rpc = new starknet.RpcProvider({
    //   nodeUrl: ecs_data.rpc || 'localhost:5050',
    // });

    setTimeout(async () => {
      await starknet.enable();
      this.contract = new starknet_.Contract(
        ecs_data.abi,
        contract,
        starknet.provider,
      );
    }, 1000);
  }

  play() {
    this.world.call('executor');
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

  async entity_position(entity) {
    let pos_store_hashes = [
      // No entity with id 0
      [],
      // Entity with id 1
      [
        '0x35bb8bbcd50e384fb64d8f2125f420f74427a9d9e54b29941800b97b2cd8cf3',
        '0x35bb8bbcd50e384fb64d8f2125f420f74427a9d9e54b29941800b97b2cd8cf4',
      ],
      // Entity with id 2
      [
        '0x79e109b90a9fa15a87f1effe651e498fc129f01e2d0681dfbdab117e2d780cd',
        '0x79e109b90a9fa15a87f1effe651e498fc129f01e2d0681dfbdab117e2d780ce',
      ],
    ];

    return await Promise.all([
      this.storage(pos_store_hashes[entity][0]),
      this.storage(pos_store_hashes[entity][1]),
    ]);
  }

  async storage(hash) {
    let resp = await this.raw_fetch('starknet_getStorageAt', [
      ecs_data.world_addr,
      hash,
      'pending',
    ]);
    return resp.result || 0;
  }

  call() {
    return this.rpc('starknet_call');
  }
}

window.dojo = new DojoCalls();
window.entity_position = [[]];

setInterval(async () => {
  window.entity_position[1] = await dojo.entity_position(1);
  window.entity_position[2] = await dojo.entity_position(2);
}, 100);
