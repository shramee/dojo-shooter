use core::traits::TryInto;
use core::option::OptionTrait;
use array::ArrayTrait;
use serde::{Serde, Felt252Serde};
use traits::{Into};
use alexandria_math::signed_integers::i33;

impl I33Serde of Serde<i33> {
    fn serialize(self: @i33, ref output: Array<felt252>) {
        let mut val_felt: felt252 = (*self.inner).into();
        if *self.sign {
            val_felt = val_felt + 4294967296; // 2 ^ 32 = 4294967296
        }
        val_felt.serialize(ref output);
    }
    fn deserialize(ref serialized: Span<felt252>) -> Option<i33> {
        let val_felt: felt252 = Felt252Serde::deserialize(ref serialized)?;
        let val_u32_option: Option<u32> = val_felt.try_into();
        Option::Some(
            if val_u32_option.is_some() {
                // felt value fits u32, sign is false
                i33 { inner: val_u32_option?, sign: false,  }
            } else {
                // felt value exceeds u32, sign set on 33rd bit
                let inner: u32 = (val_felt - 4294967296).try_into()?;
                i33 { inner, sign: true,  }
            }
        )
    }
}

#[test]
#[available_gas(2000000)]
fn i33_test_serde() {
    let a = i33 { inner: 42, sign: false };
    let mut serilized: Array<felt252> = ArrayTrait::new();
    a.serialize(ref serilized);

    let mut serialized_span = serilized.span();
    let a_deserialized = I33Serde::deserialize(ref serialized_span).unwrap();
    assert(42 == a_deserialized.inner, 'i33 serde failed');
    assert(false == a_deserialized.sign, 'i33 serde failed');

    let a = i33 { inner: 52, sign: true };
    let mut serilized: Array<felt252> = ArrayTrait::new();
    a.serialize(ref serilized);

    let mut serialized_span = serilized.span();
    let a_deserialized = I33Serde::deserialize(ref serialized_span).unwrap();
    assert(52 == a_deserialized.inner, 'i33 serde failed');
    assert(true == a_deserialized.sign, 'i33 serde failed');
}

const zombie_speed: i33 = 2;
const zombie_width: i33 = 30;
const play_area: u32 = 1000;

fn new_i33(inner: u32, sign: bool) -> i33 {
    i33 { inner, sign }
}

#[derive(Component, Copy, Drop, Serde)]
struct Zombie {
    x: i33,
    y: i33,
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

// region Not using polar coords for now
// Quadrants
// These are structured so that Zombies can be queried by quadrant
// And shoot system can find the zombies shot
// Based on the slope
// #[derive(Component, Copy, Drop, Serde)]
// struct QuadTL {
//     x: u32, // Slope is one-ten thousandth    
// }

// #[derive(Component, Copy, Drop, Serde)]
// struct QuadTR {
//     x: u32, // Slope is one-ten thousandth    
// }

// #[derive(Component, Copy, Drop, Serde)]
// struct QuadBR {
//     x: u32, // Slope is one-ten thousandth    
// }

// #[derive(Component, Copy, Drop, Serde)]
// struct QuadBL {
//     x: u32, // Slope is one-ten thousandth    
// }
// endregion Not using polar coords for now


