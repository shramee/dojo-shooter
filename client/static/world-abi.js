window.ecs_data = window.ecs_data || {};

window.ecs_data.abi = [
  {
    type: 'function',
    name: 'constructor',
    inputs: [
      {
        name: 'executor',
        type: 'core::starknet::contract_address::ContractAddress',
      },
    ],
    outputs: [],
    state_mutability: 'external',
  },
  {
    type: 'struct',
    name: 'dojo_core::auth::systems::Route',
    members: [
      {
        name: 'target_id',
        type: 'core::felt252',
      },
      {
        name: 'role_id',
        type: 'core::felt252',
      },
      {
        name: 'resource_id',
        type: 'core::felt252',
      },
    ],
  },
  {
    type: 'function',
    name: 'initialize',
    inputs: [
      {
        name: 'routes',
        type: 'core::array::Array::<dojo_core::auth::systems::Route>',
      },
    ],
    outputs: [],
    state_mutability: 'external',
  },
  {
    type: 'struct',
    name: 'dojo_core::auth::components::AuthRole',
    members: [
      {
        name: 'id',
        type: 'core::felt252',
      },
    ],
  },
  {
    type: 'function',
    name: 'is_authorized',
    inputs: [
      {
        name: 'system',
        type: 'core::felt252',
      },
      {
        name: 'component',
        type: 'core::felt252',
      },
      {
        name: 'execution_role',
        type: 'dojo_core::auth::components::AuthRole',
      },
    ],
    outputs: [
      {
        type: 'core::bool',
      },
    ],
    state_mutability: 'view',
  },
  {
    type: 'function',
    name: 'is_account_admin',
    inputs: [],
    outputs: [
      {
        type: 'core::bool',
      },
    ],
    state_mutability: 'view',
  },
  {
    type: 'function',
    name: 'register_component',
    inputs: [
      {
        name: 'class_hash',
        type: 'core::starknet::class_hash::ClassHash',
      },
    ],
    outputs: [],
    state_mutability: 'external',
  },
  {
    type: 'function',
    name: 'component',
    inputs: [
      {
        name: 'name',
        type: 'core::felt252',
      },
    ],
    outputs: [
      {
        type: 'core::starknet::class_hash::ClassHash',
      },
    ],
    state_mutability: 'view',
  },
  {
    type: 'function',
    name: 'register_system',
    inputs: [
      {
        name: 'class_hash',
        type: 'core::starknet::class_hash::ClassHash',
      },
    ],
    outputs: [],
    state_mutability: 'external',
  },
  {
    type: 'function',
    name: 'system',
    inputs: [
      {
        name: 'name',
        type: 'core::felt252',
      },
    ],
    outputs: [
      {
        type: 'core::starknet::class_hash::ClassHash',
      },
    ],
    state_mutability: 'view',
  },
  {
    type: 'function',
    name: 'execute',
    inputs: [
      {
        name: 'name',
        type: 'core::felt252',
      },
      {
        name: 'execute_calldata',
        type: 'core::array::Span::<core::felt252>',
      },
    ],
    outputs: [
      {
        type: 'core::array::Span::<core::felt252>',
      },
    ],
    state_mutability: 'external',
  },
  {
    type: 'function',
    name: 'uuid',
    inputs: [],
    outputs: [
      {
        type: 'core::integer::u32',
      },
    ],
    state_mutability: 'external',
  },
  {
    type: 'struct',
    name: 'dojo_core::execution_context::Context',
    members: [
      {
        name: 'world',
        type: 'dojo_core::interfaces::IWorldDispatcher',
      },
      {
        name: 'caller_account',
        type: 'core::starknet::contract_address::ContractAddress',
      },
      {
        name: 'caller_system',
        type: 'core::felt252',
      },
      {
        name: 'execution_role',
        type: 'dojo_core::auth::components::AuthRole',
      },
    ],
  },
  {
    type: 'struct',
    name: 'dojo_core::storage::query::Query',
    members: [
      {
        name: 'address_domain',
        type: 'core::integer::u32',
      },
      {
        name: 'partition',
        type: 'core::felt252',
      },
      {
        name: 'keys',
        type: 'core::array::Span::<core::felt252>',
      },
    ],
  },
  {
    type: 'function',
    name: 'set_entity',
    inputs: [
      {
        name: 'context',
        type: 'dojo_core::execution_context::Context',
      },
      {
        name: 'component',
        type: 'core::felt252',
      },
      {
        name: 'query',
        type: 'dojo_core::storage::query::Query',
      },
      {
        name: 'offset',
        type: 'core::integer::u8',
      },
      {
        name: 'value',
        type: 'core::array::Span::<core::felt252>',
      },
    ],
    outputs: [],
    state_mutability: 'external',
  },
  {
    type: 'function',
    name: 'delete_entity',
    inputs: [
      {
        name: 'context',
        type: 'dojo_core::execution_context::Context',
      },
      {
        name: 'component',
        type: 'core::felt252',
      },
      {
        name: 'query',
        type: 'dojo_core::storage::query::Query',
      },
    ],
    outputs: [],
    state_mutability: 'external',
  },
  {
    type: 'function',
    name: 'entity',
    inputs: [
      {
        name: 'component',
        type: 'core::felt252',
      },
      {
        name: 'query',
        type: 'dojo_core::storage::query::Query',
      },
      {
        name: 'offset',
        type: 'core::integer::u8',
      },
      {
        name: 'length',
        type: 'core::integer::u32',
      },
    ],
    outputs: [
      {
        type: 'core::array::Span::<core::felt252>',
      },
    ],
    state_mutability: 'view',
  },
  {
    type: 'function',
    name: 'entities',
    inputs: [
      {
        name: 'component',
        type: 'core::felt252',
      },
      {
        name: 'partition',
        type: 'core::felt252',
      },
    ],
    outputs: [
      {
        type: '(core::array::Span::<core::felt252>, core::array::Span::<core::array::Span::<core::felt252>>)',
      },
    ],
    state_mutability: 'view',
  },
  {
    type: 'function',
    name: 'set_executor',
    inputs: [
      {
        name: 'contract_address',
        type: 'core::starknet::contract_address::ContractAddress',
      },
    ],
    outputs: [],
    state_mutability: 'external',
  },
  {
    type: 'function',
    name: 'executor',
    inputs: [],
    outputs: [
      {
        type: 'core::starknet::contract_address::ContractAddress',
      },
    ],
    state_mutability: 'view',
  },
  {
    type: 'function',
    name: 'assume_role',
    inputs: [
      {
        name: 'role_id',
        type: 'core::felt252',
      },
      {
        name: 'systems',
        type: 'core::array::Array::<core::felt252>',
      },
    ],
    outputs: [],
    state_mutability: 'external',
  },
  {
    type: 'function',
    name: 'clear_role',
    inputs: [
      {
        name: 'systems',
        type: 'core::array::Array::<core::felt252>',
      },
    ],
    outputs: [],
    state_mutability: 'external',
  },
  {
    type: 'function',
    name: 'execution_role',
    inputs: [],
    outputs: [
      {
        type: 'core::felt252',
      },
    ],
    state_mutability: 'view',
  },
  {
    type: 'function',
    name: 'system_components',
    inputs: [
      {
        name: 'system',
        type: 'core::felt252',
      },
    ],
    outputs: [
      {
        type: 'core::array::Array::<(core::felt252, core::bool)>',
      },
    ],
    state_mutability: 'view',
  },
  {
    type: 'function',
    name: 'is_system_for_execution',
    inputs: [
      {
        name: 'system',
        type: 'core::felt252',
      },
    ],
    outputs: [
      {
        type: 'core::bool',
      },
    ],
    state_mutability: 'view',
  },
  {
    type: 'event',
    name: 'WorldSpawned',
    inputs: [
      {
        name: 'address',
        type: 'core::starknet::contract_address::ContractAddress',
      },
      {
        name: 'caller',
        type: 'core::starknet::contract_address::ContractAddress',
      },
    ],
  },
  {
    type: 'event',
    name: 'ComponentRegistered',
    inputs: [
      {
        name: 'name',
        type: 'core::felt252',
      },
      {
        name: 'class_hash',
        type: 'core::starknet::class_hash::ClassHash',
      },
    ],
  },
  {
    type: 'event',
    name: 'SystemRegistered',
    inputs: [
      {
        name: 'name',
        type: 'core::felt252',
      },
      {
        name: 'class_hash',
        type: 'core::starknet::class_hash::ClassHash',
      },
    ],
  },
];
