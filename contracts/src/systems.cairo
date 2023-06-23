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
mod GetZombies {
    use array::ArrayTrait;
    use traits::Into;
    use debug::PrintTrait;
    // use dojo_shooter::components::{QuadTL, QuadTR, QuadBR, QuadBL};
    use dojo_shooter::components::{Zombie, new_i33};

    fn execute(ctx: Context) -> Array<Zombie> {
        let zombie_entities: Span<Zombie> = commands::<Zombie>::entities();
        let mut zombies: Array<Zombie> = ArrayTrait::new();
        let mut z_indx: usize = 0;
        loop {
            if (zombie_entities.len() == z_indx) {
                break ();
            };
            zombies.append(*zombie_entities.at(z_indx));
            z_indx += 1;
        };
        zombie_entities.len().print();
        zombies.len().print();
        zombies
    }
}

#[system]
mod SpawnDummyZombies {
    use array::ArrayTrait;
    use traits::Into;
    // use dojo_shooter::components::{QuadTL, QuadTR, QuadBR, QuadBL};
    use dojo_shooter::components::{Zombie, new_i33};

    fn execute(ctx: Context) {
        // Spawn zombies
        let score = commands::set_entity(
            1.into(), (Zombie { x: new_i33(500, false), y: new_i33(400, true) })
        );
        let score = commands::set_entity(
            2.into(), (Zombie { x: new_i33(700, true), y: new_i33(500, false) })
        );
        let score = commands::set_entity(
            3.into(), (Zombie { x: new_i33(400, false), y: new_i33(350, false) })
        );
        let score = commands::set_entity(
            4.into(), (Zombie { x: new_i33(750, true), y: new_i33(200, false) })
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
    // use dojo_shooter::components::{QuadTL, QuadTR, QuadBR, QuadBL, };
    use dojo_shooter::components::{Zombie};

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
