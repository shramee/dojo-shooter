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
mod SpawnDummyZombies {
    use array::ArrayTrait;
    use traits::Into;
    use dojo_shooter::components::{QuadTL, QuadTR, QuadBR, QuadBL, Zombie};

    fn execute(ctx: Context) {
        // Spawn zombies
        let score = commands::<Zombie,
        QuadTL>::entity(
            ctx.caller_account.into(), (Zombie { distance: 500 }, QuadTL { slope: 20000 })
        );
        let score = commands::<Zombie,
        QuadTR>::entity(
            ctx.caller_account.into(), (Zombie { distance: 700 }, QuadTR { slope: 3000 })
        );
        let score = commands::<Zombie,
        QuadBR>::entity(
            ctx.caller_account.into(), (Zombie { distance: 400 }, QuadBR { slope: 240 })
        );
        let score = commands::<Zombie,
        QuadBL>::entity(
            ctx.caller_account.into(), (Zombie { distance: 750 }, QuadBL { slope: 70000 })
        );
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
