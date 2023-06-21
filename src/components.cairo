use array::ArrayTrait;

const zombies_speed: u32 = 2;

// Position of zombies
// Updated to go towards the center on every update
#[derive(Component, Copy, Drop, Serde)]
struct Position {
    x: u32,
    y: u32
}

// Keeps game score
#[derive(Component, Copy, Drop, Serde)]
struct Score {
    kills: u32, 
}
// @todo later
// Keeps all time score
// #[derive(Component, Copy, Drop, Serde)]
// struct ScoreAllTime {
//     kills: u32, 
// }


