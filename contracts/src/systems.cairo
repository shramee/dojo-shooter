#[system]
mod SpawnPlayer {
    use array::ArrayTrait;
    use traits::Into;
    use dojo_shooter::components::{Score};

    // note: ignore linting of Context and commands
    fn execute(ctx: Context) {
        let player = commands::<Score>::set_entity(ctx.caller_account.into(), (Score { kills: 0 }));

        return ();
    }
}

// To get the Zombies
// "method": "starknet_call",
// "params": [
//     {
//         "contract_address": "0x7f1d6c1b15e03673062d8356dc1174d5d85c310479ec49fe781e8bf89e4c4f8",
//         "entry_point_selector": "0x027706e83545bc0fb130476239ec381f65fba8f92e2379d60a07869aa04b4ccc",
//         "calldata": [
//             "0x5a6f6d626965", "0"
//         ]
//     },
//     "pending"
// ]

#[system]
mod SpawnDummyZombies {
    use array::ArrayTrait;
    use traits::Into;
    use dojo_shooter::components::{Zombie, new_i33};

    fn execute(ctx: Context) {
        // Spawn zombies
        commands::set_entity(1.into(), (Zombie { x: new_i33(500, false), y: new_i33(400, true) }));
        commands::set_entity(2.into(), (Zombie { x: new_i33(700, true), y: new_i33(800, false) }));
        commands::set_entity(3.into(), (Zombie { x: new_i33(400, false), y: new_i33(350, false) }));
        commands::set_entity(4.into(), (Zombie { x: new_i33(750, true), y: new_i33(900, true) }));
    }
}

#[system]
mod Update {
    use array::ArrayTrait;
    use traits::Into;
    use dojo_shooter::components::{Zombie, zombie_speed, ZombieSerde};
    use serde::Serde;
    use debug::PrintTrait;
    // use dojo_core::interfaces::{Context, IWorldDispatcherTrait};

    #[derive(Copy, Drop, Serde)]
    enum Tasks {
        all: (),
        update: (),
        spawn: (),
    }

    fn spawn(ctx: Context) {}

    fn update(ctx: Context) {
        let (zombie_entities, entities_data) = ctx.world.entities('Zombie', 0);

        let mut z_indx: usize = 0;
        loop {
            if (zombie_entities.len() == z_indx) {
                break ();
            };
            let z_id: felt252 = *zombie_entities.at(z_indx);
            let mut z_pos_span: Span<felt252> = *entities_data.at(z_indx);
            let mut z: Zombie = ZombieSerde::deserialize(ref z_pos_span).unwrap();

            if 0 != z.x.inner {
                z.x.inner = if z.x.inner < zombie_speed {
                    0
                } else {
                    z.x.inner - zombie_speed
                };
            }
            if 0 != z.y.inner {
                z.y.inner = if z.y.inner < zombie_speed {
                    0
                } else {
                    z.y.inner - zombie_speed
                };
            }

            let mut zombie_serialized: Array<felt252> = ArrayTrait::new();
            z.serialize(ref zombie_serialized);

            ctx
                .world
                .set_entity(
                    ctx,
                    'Zombie'.into(),
                    QueryTrait::new_from_id(z_id.into()),
                    0,
                    zombie_serialized.span()
                );
            z_indx += 1;
        };
    }

    fn execute(ctx: Context, tasks: Tasks) { // Make zombies move towards the center
        match tasks {
            Tasks::all(_) => {
                update(ctx);
                spawn(ctx);
            },
            Tasks::update(_) => {
                update(ctx);
            },
            Tasks::spawn(_) => {
                spawn(ctx);
            },
        }
    }
}

#[system]
mod Shoot {
    use array::ArrayTrait;
    use traits::Into;
    use debug::PrintTrait;
    use dojo_shooter::components::{Zombie, ZombieSerde, i33, I33Serde, zombie_width, Score, };

    // Calculates slope from coordinates
    fn slope(x: u32, y: u32) -> u32 {
        y * 10000 / x
    }

    // Calculates range of slope for a zombie coordinates
    // Uses 
    fn zombie_slope_range(x_: i33, y_: i33) -> (u32, u32) {
        let x = x_.inner;
        let y = y_.inner;

        (slope(x + zombie_width, y - zombie_width), slope(x - zombie_width, y + zombie_width))
    }

    // use dojo_core::interfaces::{Context, IWorldDispatcherTrait};
    fn execute(ctx: Context, x: i33, y: i33) {
        let (zombie_entities, entities_data) = ctx.world.entities('Zombie', 0);

        // slope of the bullet trajectory
        let shot_slope = slope(x.inner, y.inner);

        let mut z_indx: usize = 0;
        loop {
            if (zombie_entities.len() == z_indx) {
                break ();
            };
            // Zombie ID
            let z_id: felt252 = *zombie_entities.at(z_indx);

            // Zombie position
            let mut z_pos_span: Span<felt252> = *entities_data.at(z_indx);
            // Le Zombie
            let mut z: Zombie = ZombieSerde::deserialize(ref z_pos_span).unwrap();

            ///////// Calculate if the shot hit a zombie /////////
            if z.x.sign == x.sign {
                if z.y.sign == y.sign { // Zombie is in same quadrant as the shot
                    let (min_slope, max_slope) = zombie_slope_range(z.x, z.y);
                    // compare the slope of zombie to the bullet trajectory
                    // range for whole hitbox
                    if shot_slope > min_slope {
                        if shot_slope < max_slope { // Shot is within zombie hitpoint slope
                            ctx.world.delete_entity(ctx, 'Zombie', z_id.into());
                            let score = commands::<Score>::entity(ctx.caller_account.into());
                            let player = commands::<Score>::set_entity(
                                ctx.caller_account.into(), (Score { kills: score.kills + 1 })
                            );

                            break ();
                        }
                    }
                }
            }
            z_indx += 1;
        };
    // Loop through the array and stop at first contact
    // Range should be affected by distance of zombie
    }
}
