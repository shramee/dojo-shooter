#[system]
mod Update {
    use array::ArrayTrait;
    use traits::{Into, TryInto};
    use dojo_shooter::components::{
        Zombie, zombie_speed, ZombieSerde, Score, SystemFrameTicker, spawn_targets, new_i33, GameState, GameStates, HighScore, HighScoreSerde
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

        if frames > 100 {
            finish_game(ctx);
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

        match get_game_state(ctx) {
            GameStates::Finished(()) => { return {}; },
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

    fn finish_game(ctx: Context) {
        // set game state to finished to prevent further frame updates
        let mut game_state: GameState = GameState { state: GameStates::Finished(()) };

        let mut game_state_serialized: Array<felt252> = ArrayTrait::new();
        game_state_serialized.serialize(ref game_state_serialized);
        
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

        // // get current score to see if new high score should be set (don't have to reset to 0 as init on next game does so for us)
        // let current_score: u128 = (*ctx.world.entity('Score', ctx.caller_account.into(), 0, 0)[0])
        //     .try_into()
        //     .unwrap();

        // let mut score_to_serialize: Score = Score { kills: current_score };

        // let mut current_score_serialized: Array<felt252> = ArrayTrait::new();
        // score_to_serialize.serialize(ref ticker_serialized);

        //     let mut high_score_serialized = ctx.world.entity('HighScore', 'high_score'.into(), 0, 0);
        //     if high_score_serialized.len() == 0 {
        //                     ctx
        //                     .world
        //                     .set_entity(
        //                         ctx,
        //                         ''.into(),
        //                         QueryTrait::new_from_id('game_state'.into()),
        //                         0,
        //                         current_score_serialized.span()
        //                         );
        //     } else {
        //         let current_high_score: u32 = HighScoreSerde::deserialize(ref high_score_serialized).unwrap();
        //         if current_score > current_high_score {
        //             commands::set_entity('high_score'.into(), (HighScore { score: current_score, score_holer: ctx.caller_account}));
        //         }
        //     }
        
        // let player = commands::<Score>::set_entity(
        //     ctx.caller_account.into(), (Score { kills: 0 })
        //     );
}
}
