#[system]
mod SpawnPlayer {
    use array::ArrayTrait;
    use traits::Into;
    use dojo_shooter::components::{Score};

    // note: ignore linting of Context and commands
    fn execute(ctx: Context) {
        let score = commands::<Score>::entity(ctx.caller_account.into());

        if (0 == score.kills) {
            let player = commands::<Score>::set_entity(
                ctx.caller_account.into(), (Score { kills: 3 })
            );
        }

        return ();
    }
}

#[system]
mod SpawnZombies {
    use array::ArrayTrait;
    use traits::Into;
    fn execute(ctx: Context) { // Spawn zombies
    }
}

#[system]
mod MoveZombies {
    use array::ArrayTrait;
    use traits::Into;
    fn execute(ctx: Context) { // Make zombies move towards the center
    }
}

#[system]
mod Shoot {
    use array::ArrayTrait;
    use traits::Into;
    use dojo_shooter::components::{QuadTL, QuadTR, QuadBR, QuadBL, };

    #[derive(Copy, Drop, Serde)]
    enum Quadrant {
        TL: u32,
        TR: u32,
        BR: u32,
        BL: u32,
    }

    // Quadrant is Quadrant enum containing the slope
    // Slope is one-thousandth value
    fn execute(ctx: Context, q: Quadrant) { // Calculate if the shot hit a zombie
    // Gets the slope of the bullet trajectory
    // Compare the slope of zombies to the bullet trajectory (+- range for simluating hitbox)
    // Loop through the array and stop at first contact
    // Range should be affected by distance of zombie
    }
}
