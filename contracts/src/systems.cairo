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

#[system]
// TODO: rename, doing more than spawn dummy zombies
mod SpawnDummyZombies {
    use array::ArrayTrait;
    use traits::Into;
    use dojo_shooter::components::{Zombie, new_i33, SystemFrameTicker};

    fn execute(ctx: Context) {
        // Spawn zombies
        commands::set_entity(0.into(), (Zombie { x: new_i33(500, false), y: new_i33(400, true) }));
        commands::set_entity(1.into(), (Zombie { x: new_i33(700, true), y: new_i33(800, false) }));
        commands::set_entity(2.into(), (Zombie { x: new_i33(400, false), y: new_i33(350, false) }));
        commands::set_entity(3.into(), (Zombie { x: new_i33(750, true), y: new_i33(900, true) }));

        // Initialize frame count to 4 to avoid entity id clashes later with above zombies (first update will increment next frame to 5 before spawning)
        commands::set_entity('ticker'.into(), (SystemFrameTicker { frames: 4 }));
    }
}

#[system]
mod Update {
    use array::ArrayTrait;
    use traits::{Into, TryInto};
    use dojo_shooter::components::{
        Zombie, zombie_speed, ZombieSerde, Score, SystemFrameTicker, spawn_targets, new_i33
    };
    use serde::Serde;
    use debug::PrintTrait;

    // use dojo_core::interfaces::{Context, IWorldDispatcherTrait};

    #[derive(Copy, Drop, Serde)]
    enum Tasks {
        all: (),
        update: (),
        spawn: (),
    }

    fn spawn(ctx: Context) {

        let frames: u128 = (*ctx.world.entity('SystemFrameTicker', 'ticker'.into(), 0, 0)[0]).try_into().unwrap();
        // 'CURRENT FRAME'.print();
        // frames.print();
        let current_score: u32 = (*ctx.world.entity('Score', ctx.caller_account.into(), 0, 0)[0]).try_into().unwrap();
        if frames % 11 == 0 {
            'ENTERED SPAWN'.print();
            let randomness: u128 = ((frames + current_score.into()) / 11) % 8;
            let conversion_felt: felt252 = ((frames + current_score.into()) % spawn_targets().len().into()).into();
            let spawn_target = spawn_targets()[conversion_felt.try_into().unwrap()];

            let mut z: Zombie = Zombie { x: new_i33(1000, false), y: new_i33(1000, false) };

            // first four where x is random, different positive and negative combinations; second four where y is random
            if randomness < 4 {
                z.x.inner = *spawn_target;
                if randomness == 1 {
                    z.y.sign = true;
                } else if randomness == 2 {
                    z.x.sign = true;
                } else if randomness == 3 {
                    z.x.sign = true;
                    z.y.sign = true;
                }
            } else {
                z.y.inner = *spawn_target;
                if randomness == 5 {
                    z.x.sign = true;
                } else if randomness == 6 {
                    z.y.sign = true;
                }  else if randomness == 7 {
                    z.y.sign = true;
                    z.x.sign = true;
                }
            }
            
            'NEW Z X'.print();
            z.x.inner.print();
            'NEW X SIGN'.print();
            z.x.sign.print();
            'NEW Z Y'.print();
            z.y.inner.print();
            'NEW Y SIGN'.print();
            z.y.sign.print();
            

            let mut zombie_serialized: Array<felt252> = ArrayTrait::new();
            z.serialize(ref zombie_serialized);

            ctx
                .world
                .set_entity(
                    ctx,
                    'Zombie'.into(),
                    QueryTrait::new_from_id(frames.into()),
                    0,
                    zombie_serialized.span()
                );
        }
    }

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

    fn execute(ctx: Context, tasks: Tasks) {
        // increment current frame ticker by 1 and then update
        let next_frame: u128 = (*ctx.world.entity('SystemFrameTicker', 'ticker'.into(), 0, 0)[0]).try_into().unwrap() + 1;
        // 'NEXT FRAME'.print();
        // next_frame.print();

        let mut ticker: SystemFrameTicker = SystemFrameTicker { frames: next_frame };

        let mut ticker_serialized: Array<felt252> = ArrayTrait::new();
        ticker.serialize(ref ticker_serialized);

        ctx
            .world
            .set_entity(
                ctx,
                'SystemFrameTicker'.into(),
                QueryTrait::new_from_id('ticker'.into()),
                0,
                ticker_serialized.span()
            );

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
                    'Zombie'.print();
                    z_id.print();
                    min_slope.print();
                    max_slope.print();
                    shot_slope.print();
                    (shot_slope > min_slope).print();
                    (shot_slope < max_slope).print();
                    // compare the slope of zombie to the bullet trajectory
                    // range for whole hitbox
                    if shot_slope > min_slope {
                        if shot_slope < max_slope { // Shot is within zombie hitpoint slope
                            'Zombie killed!'.print();

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
