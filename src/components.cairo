use array::ArrayTrait;

const zombie_speed: u32 = 2;
const zombie_width: u32 = 30;

const play_area: u32 = 1000;

// Quadrants
// These are structured so that Zombies can be queried by quadrant
// And shoot system can find the zombies shot
// Based on the slope
#[derive(Component, Copy, Drop, Serde)]
struct QuadTL {
    x: u32, // Slope is one-ten thousandth    
}

#[derive(Component, Copy, Drop, Serde)]
struct QuadTR {
    x: u32, // Slope is one-ten thousandth    
}

#[derive(Component, Copy, Drop, Serde)]
struct QuadBR {
    x: u32, // Slope is one-ten thousandth    
}

#[derive(Component, Copy, Drop, Serde)]
struct QuadBL {
    x: u32, // Slope is one-ten thousandth    
}

#[derive(Component, Copy, Drop, Serde)]
struct Zombie {
    distance: u32, 
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


