#[system]
mod Update {
    use array::ArrayTrait;
    use traits::{Into, TryInto};
    use dojo_shooter::components::{
        Zombie, zombie_speed, zombie_width, ZombieSerde, Score, SystemFrameTicker, spawn_targets,
        new_i33, GameState, GameStates
    };
    use serde::Serde;
    use debug::PrintTrait;
    use dojo_shooter::utils::get_game_state;

    // use dojo_core::interfaces::{Context, IWorldDispatcherTrait};

    #[derive(Copy, Drop, Serde)]
    enum Tasks {
        all: (),
        update: (),
        spawn: (),
    }

    fn spawn(ctx: Context) {
        let frames: u128 = (*ctx.world.entity('SystemFrameTicker', 'ticker'.into(), 0, 0)[0])
            .try_into()
            .unwrap();
        let current_score: u32 = (*ctx.world.entity('Score', ctx.caller_account.into(), 0, 0)[0])
            .try_into()
            .unwrap();
        if frames % 11 == 0 {
            let randomness: u128 = ((frames + current_score.into()) / 11) % 8;
            let conversion_felt: felt252 = ((frames + current_score.into()) % spawn_targets()
                .len()
                .into())
                .into();
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
                } else if randomness == 7 {
                    z.y.sign = true;
                    z.x.sign = true;
                }
            }

            let mut zombie_serialized: Array<felt252> = ArrayTrait::new();
            z.serialize(ref zombie_serialized);

            ctx.world.set_entity(ctx, 'Zombie', frames.into(), 0, zombie_serialized.span());
        }
    }

    fn update(ctx: Context) {
        let (zombie_entities, entities_data) = ctx.world.entities('Zombie', 0);

        let lose_distance = zombie_width * 2;

        let mut z_indx: usize = 0;
        loop {
            if (zombie_entities.len() == z_indx) {
                break ();
            };
            let z_id: felt252 = *zombie_entities.at(z_indx);
            let mut z_pos_span: Span<felt252> = *entities_data.at(z_indx);
            let mut z: Zombie = ZombieSerde::deserialize(ref z_pos_span).unwrap();

            let mut coordinates_breached = 0;

            if lose_distance != z.x.inner {
                z
                    .x
                    .inner =
                        if z.x.inner - lose_distance < zombie_speed {
                            coordinates_breached += 1;
                            lose_distance
                        } else {
                            z.x.inner - zombie_speed
                        };
            }
            if lose_distance != z.y.inner {
                z
                    .y
                    .inner =
                        if z.y.inner - lose_distance < zombie_speed {
                            coordinates_breached += 1;
                            lose_distance
                        } else {
                            z.y.inner - zombie_speed
                        };
            }

            let mut zombie_serialized: Array<felt252> = ArrayTrait::new();
            z.serialize(ref zombie_serialized);

            ctx.world.set_entity(ctx, 'Zombie', z_id.into(), 0, zombie_serialized.span());
            z_indx += 1;
        };
    }

    fn execute(ctx: Context, tasks: Tasks) {
        match get_game_state(ctx) {
            GameStates::Finished(()) => {
                return {};
            },
            GameStates::Running(()) => {}
        }

        // increment current frame ticker by 1 and then update
        let next_frame: u128 = (*ctx.world.entity('SystemFrameTicker', 'ticker'.into(), 0, 0)[0])
            .try_into()
            .unwrap()
            + 1;

        let mut ticker: SystemFrameTicker = SystemFrameTicker { frames: next_frame };

        let mut ticker_serialized: Array<felt252> = ArrayTrait::new();
        ticker.serialize(ref ticker_serialized);

        ctx
            .world
            .set_entity(ctx, 'SystemFrameTicker', 'ticker'.into(), 0, ticker_serialized.span());

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

    fn finish_game(ctx: Context) {
        // set game state to finished to prevent further frame updates
        let mut game_state: GameState = GameState { state: GameStates::Finished(()) };

        let mut game_state_serialized: Array<felt252> = ArrayTrait::new();
        game_state.serialize(ref game_state_serialized);
        
        ctx
        .world
        .set_entity(
            ctx,
            'GameState'.into(),
            'game_state'.into(),
            0,
            game_state_serialized.span()
        );

        // delete all zombies to prepare for next game
        let (zombie_entities, entities_data) = ctx.world.entities('Zombie', 0);

        let mut z_indx: usize = 0;
        loop {
            if (zombie_entities.len() == z_indx) {
                break ();
            };
            let z_id: felt252 = *zombie_entities.at(z_indx);
            ctx.world.delete_entity(ctx, 'Zombie', z_id.into());

            z_indx += 1;
            };
        }
}
