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
