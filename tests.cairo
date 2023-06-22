use core::array::SpanTrait;
use core::traits::Into;
use array::ArrayTrait;
use dojo_core::auth::systems::{Route, RouteTrait};
use dojo_core::interfaces::{IWorldDispatcherTrait, IWorldDispatcher};
use dojo_core::test_utils::spawn_test_world;
use components::{
    PosComponent, VelComponent, AccComponent, ColorComponent, ZERO, RANGE, val_from_2xpc
};
use dojo_autonomous_agents::systems::{Spawn, Update};
use debug::PrintTrait;

fn setup_world() -> IWorldDispatcher {
    let caller = starknet::contract_address_const::<0x0>();
    // components
    let mut components = array::ArrayTrait::new();
    components.append(PosComponent::TEST_CLASS_HASH);
    components.append(VelComponent::TEST_CLASS_HASH);
    components.append(AccComponent::TEST_CLASS_HASH);
    components.append(ColorComponent::TEST_CLASS_HASH);
    // systems
    let mut systems = array::ArrayTrait::new();
    systems.append(Spawn::TEST_CLASS_HASH);
    systems.append(Update::TEST_CLASS_HASH);
    // routes
    let mut routes = array::ArrayTrait::new();
    // deploy executor, world and register components/systems
    let world = spawn_test_world(components, systems, routes);

    let mut systems = array::ArrayTrait::new();
    systems.append('Spawn');
    systems.append('Update');
    world.assume_role('sudo', systems);

    world
}

fn world_exec(world: IWorldDispatcher, system: felt252) {
    let spawn_call_data = array::ArrayTrait::new();
    world.execute(system, spawn_call_data.span());
}

#[test]
#[available_gas(30000000)]
fn test_physics_spawn() {
    let world = setup_world();

    world_exec(world, 'Spawn');

    let position = world.entity('Pos', 2.into(), 0, 0);
    assert(position.len() > 0, 'spawn: No data found');
    assert(*position[0] != 0, 'pos1: x is wrong');
    assert(*position[1] != 0, 'pos1: y is wrong');
}

#[test]
#[available_gas(30000000)]
fn test_physics_update() {
    let world = setup_world();

    world_exec(world, 'Spawn');
    world_exec(world, 'Update');
    let pos = world.entity('Pos', 2.into(), 0, 0);
    assert(*pos[0] == val_from_2xpc(103).into(), 'pos2: x is wrong');
    assert(*pos[1] == val_from_2xpc(102).into(), 'pos2: y is wrong');

    world_exec(world, 'Update');
    let pos = world.entity('Pos', 2.into(), 0, 0);
    assert(*pos[0] == val_from_2xpc(106).into(), 'pos3: x is wrong');
    assert(*pos[1] == val_from_2xpc(104).into(), 'pos3: y is wrong');
}