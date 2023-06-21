#[system]
mod SpawnPlayer {
    use array::ArrayTrait;
    use traits::Into;
    use dojo_shooter::components::{Score};

    // note: ignore linting of Context and commands
    fn execute(ctx: Context) {
        let (score, all_time_score) = commands::<Score>::entity(ctx.caller_account.into());

        if (0 == score.kills) {
            let player = commands::set_entity(
                ctx.caller_account.into(),
                (Score { kills: 3 }, ScoreAllTime { kills: all_time_score.kills }, )
            );
        }

        return ();
    }
}

#[system]
mod SpawnZombies {
    use array::ArrayTrait;
    use traits::Into;
    use dojo_shooter::components::Position;
    fn execute(ctx: Context) { // Spawn zombies
    }
}

#[system]
mod MoveZombies {
    use array::ArrayTrait;
    use traits::Into;
    use dojo_shooter::components::Position;
    fn execute(ctx: Context) { // Make zombies move towards the center
    }
}

#[system]
mod Shoot {
    use array::ArrayTrait;
    use traits::Into;
    use dojo_shooter::components::Position;

    struct Slope {
        x: u32,
        y: u32,
    }

    fn execute(ctx: Context, slope: Slope) { // Calculate if the shot hit a zombie
    // Gets the slope of the bullet trajectory
    // Compare the slope of zombies to the bullet trajectory (+- range for simluating hitbox)
    // Loop through the array and stop at first contact

    }
}
