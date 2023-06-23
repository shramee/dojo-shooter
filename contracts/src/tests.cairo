use array::{ArrayTrait, SpanTrait};
use traits::{Into, TryInto};
use option::OptionTrait;
use starknet::testing::set_caller_address;
use dojo_core::auth::systems::{Route, RouteTrait};
use dojo_core::interfaces::{IWorldDispatcherTrait, IWorldDispatcher};
use dojo_core::test_utils::spawn_test_world;
use dojo_shooter::components::{ScoreComponent, ZombieComponent, Zombie};
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

fn world_exec(world: IWorldDispatcher, system: felt252) {
    let spawn_call_data = array::ArrayTrait::new();
    world.execute(system, spawn_call_data.span());
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
fn test_player_spawn() {
    let world = setup_world();

    world_exec(world, 'SpawnPlayer');

    let score = world.entity('Score', 0.into(), 0, 0);
    assert(score.len() > 0, 'spawn: No data found');
    assert(*score[0] == 0, 'initial score should be 0');
}
// #[test]
// #[available_gas(30000000)]
// fn test_physics_update() {
//     let world = setup_world();

//     world_exec(world, 'Spawn');
//     world_exec(world, 'Update');
//     let pos = world.entity('Pos', 2.into(), 0, 0);
//     assert(*pos[0] == val_from_2xpc(103).into(), 'pos2: x is wrong');
//     assert(*pos[1] == val_from_2xpc(102).into(), 'pos2: y is wrong');

//     world_exec(world, 'Update');
//     let pos = world.entity('Pos', 2.into(), 0, 0);
//     assert(*pos[0] == val_from_2xpc(106).into(), 'pos3: x is wrong');
//     assert(*pos[1] == val_from_2xpc(104).into(), 'pos3: y is wrong');
// }


