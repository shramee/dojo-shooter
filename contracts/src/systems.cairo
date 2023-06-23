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
