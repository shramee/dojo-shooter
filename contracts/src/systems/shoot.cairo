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
        // slope of the bullet trajectory
        let shot_slope = slope(x.inner, y.inner);

        let mut z_indx: usize = 0;
        let (zombie_entities, entities_data) = ctx.world.entities('Zombie', 0);

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
