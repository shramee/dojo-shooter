use array::{ArrayTrait, SpanTrait};
use traits::{Into, TryInto};
use option::OptionTrait;
use starknet::{get_caller_address, testing::set_caller_address};
use dojo_core::auth::systems::{Route, RouteTrait};
use dojo_core::interfaces::{IWorldDispatcherTrait, IWorldDispatcher};
use dojo_core::test_utils::spawn_test_world;
use dojo_shooter::components::{ScoreComponent, ZombieComponent, Zombie, zombie_speed, zombie_width};
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

fn array_append(mut a: Array<felt252>, v: felt252) -> Array<felt252> {
    a.append(v);
    a
}

fn array_with_val(v: felt252) -> Array<felt252> {
    let mut spawn_call_data: Array<felt252> = ArrayTrait::new();
    spawn_call_data.append(v);
    spawn_call_data
}

#[test]
#[available_gas(30000000)]
fn test_player_spawn() {
    let world = setup_world();

    world.execute('SpawnPlayer', ArrayTrait::new().span());

    let score = world.entity('Score', 0.into(), 0, 0);
    assert(score.len() > 0, 'spawn: No data found');
    assert(*score[0] == 0, 'initial score should be 0');
}

#[test]
#[available_gas(30000000)]
fn test_dummy_zombie_spawn() {
    let world = setup_world();

    world.execute('SpawnDummyZombies', ArrayTrait::new().span());

    let zombie = world.entity('Zombie', 1.into(), 0, 0);
    assert(*zombie[0] != 0, 'spawn: No data found');
    assert(*zombie[1] != 0, 'spawn: No data found');
}

#[test]
#[available_gas(30000000)]
fn test_dummy_zombie_update() {
    let world = setup_world();

    world.execute('SpawnDummyZombies', ArrayTrait::new().span());

    let zombie = world.entity('Zombie', 1.into(), 0, 0);

    world.execute('Update', array_append(ArrayTrait::new(), 1).span());

    let zombie_n = world.entity('Zombie', 1.into(), 0, 0);
    assert((*zombie[0] - *zombie_n[0]).try_into().unwrap() == zombie_speed, 'spawn: No data found');
    assert((*zombie[1] - *zombie_n[1]).try_into().unwrap() == zombie_speed, 'spawn: No data found');
}

fn exec_shoot_system(world: IWorldDispatcher, x: felt252, y: felt252) -> Span<felt252> {
    let mut shoot_coords = ArrayTrait::new();
    shoot_coords.append(x);
    shoot_coords.append(y);
    world.execute('Shoot', shoot_coords.span())
}

#[test]
#[available_gas(30000000)]
fn test_shoot() {
    let world = setup_world();

    world.execute('SpawnPlayer', ArrayTrait::new().span());
    world.execute('SpawnDummyZombies', ArrayTrait::new().span());

    let score = world.entity('Score', get_caller_address().into(), 0, 0);
    assert(*score[0] == 0, 'Initial score should be 0');

    let zombie = world.entity('Zombie', 1.into(), 0, 0);
    assert(zombie.len() == 2, 'Zombie not Spawned');

    // Shoot too far off
    exec_shoot_system(world, *zombie[0] - zombie_width.into(), *zombie[1] + zombie_width.into());

    let zombie = world.entity('Zombie', 1.into(), 0, 0);
    assert(zombie.len() == 2, 'Zombie didn\'t survive');

    // Shoot at the zombie, but slightly off.
    exec_shoot_system(world, *zombie[0] - 22, *zombie[1] + 11);

    let zombie = world.entity('Zombie', 1.into(), 0, 0);
    assert(zombie.len() == 0, 'Zombie not dead');

    let score = world.entity('Score', get_caller_address().into(), 0, 0);
    assert(*score[0] == 1, 'Player score should be 1');
}
