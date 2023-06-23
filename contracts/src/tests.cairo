use array::{ArrayTrait, SpanTrait};
use traits::{Into, TryInto};
use option::OptionTrait;
use starknet::testing::set_caller_address;
use dojo_core::auth::systems::{Route, RouteTrait};
use dojo_core::interfaces::{IWorldDispatcherTrait, IWorldDispatcher};
use dojo_core::test_utils::spawn_test_world;
use dojo_shooter::components::{ScoreComponent, ZombieComponent, Zombie, zombie_speed};
use dojo_shooter::systems::{SpawnPlayer, SpawnDummyZombies, Update, Shoot};
use debug::PrintTrait;

fn setup_world() -> IWorldDispatcher {
    let caller = starknet::contract_address_const::<0x0>();
    // components
    let mut components = array::ArrayTrait::new();
    components.append(ScoreComponent::TEST_CLASS_HASH);
    components.append(ZombieComponent::TEST_CLASS_HASH);
    // systems
    let mut systems = array::ArrayTrait::new();
    systems.append(SpawnPlayer::TEST_CLASS_HASH);
    systems.append(SpawnDummyZombies::TEST_CLASS_HASH);
    systems.append(Update::TEST_CLASS_HASH);
    systems.append(Shoot::TEST_CLASS_HASH);
    // routes
    let mut routes = array::ArrayTrait::new();

    // deploy executor, world and register components/systems
    let world = spawn_test_world(components, systems, routes);

    let mut systems = array::ArrayTrait::new();
    systems.append('SpawnPlayer');
    systems.append('SpawnDummyZombies');
    systems.append('Update');
    systems.append('Shoot');

    world.assume_role('sudo', systems);

    world
}

fn array_with_val(v: felt252) -> Array<felt252> {
    let mut spawn_call_data: Array<felt252> = ArrayTrait::new();
    spawn_call_data.append(v);
    spawn_call_data
}

fn world_exec_with_calldata(
    world: IWorldDispatcher, system: felt252, spawn_call_data: Array<felt252>
) {
    world.execute(system, spawn_call_data.span());
}

fn world_exec(world: IWorldDispatcher, system: felt252) {
    world_exec_with_calldata(world, system, ArrayTrait::new());
}

#[test]
#[available_gas(30000000)]
fn test_player_spawn() {
    let world = setup_world();

    world_exec(world, 'SpawnPlayer');

    let score = world.entity('Score', 0.into(), 0, 0);
    assert(score.len() > 0, 'spawn: No data found');
    assert(*score[0] == 0, 'initial score should be 0');
}

#[test]
#[available_gas(30000000)]
fn test_dummy_zombie_spawn() {
    let world = setup_world();

    world_exec(world, 'SpawnDummyZombies');

    let zombie = world.entity('Zombie', 1.into(), 0, 0);
    assert(*zombie[0] != 0, 'spawn: No data found');
    assert(*zombie[1] != 0, 'spawn: No data found');
}

#[test]
#[available_gas(30000000)]
fn test_dummy_zombie_update() {
    let world = setup_world();

    world_exec(world, 'SpawnDummyZombies');

    let zombie = world.entity('Zombie', 1.into(), 0, 0);
    world_exec_with_calldata(world, 'Update', array_with_val(1)); // 0: all, 1: update, 2: spawn
    let zombie_n = world.entity('Zombie', 1.into(), 0, 0);
    (*zombie[0]).print();
    (*zombie_n[0]).print();
    (*zombie[1]).print();
    (*zombie_n[1]).print();
    assert((*zombie[0] - *zombie_n[0]).try_into().unwrap() == zombie_speed, 'spawn: No data found');
    assert((*zombie[1] - *zombie_n[1]).try_into().unwrap() == zombie_speed, 'spawn: No data found');
}
