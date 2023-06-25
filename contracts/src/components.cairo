use traits::TryInto;
use option::OptionTrait;
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

// This speed is for both x and y,
// So max speed is zombie_speed * root 2
const zombie_speed: u32 = 5;

// This is actually half of zombie width
const zombie_width: u32 = 72;

// Area in a quadrant, play field = 2 * play_area
const play_area: u32 = 1000;

// An array of random u32
// For simulating randomness with a mod based index
fn spawn_targets() -> Array<u32> {
    let mut ar = ArrayTrait::new();
    ar.append(854);
    ar.append(744);
    ar.append(700);
    ar.append(533);
    ar.append(488);
    ar.append(802);
    ar.append(698);
    ar.append(797);
    ar.append(643);
    ar.append(980);
    ar.append(614);
    ar.append(504);
    ar.append(673);
    ar.append(603);
    ar.append(474);
    ar.append(851);
    ar.append(707);
    ar.append(984);
    ar.append(771);
    ar.append(495);
    ar.append(642);
    ar.append(789);
    ar.append(419);
    ar.append(442);
    ar.append(657);
    ar.append(396);
    ar.append(602);
    ar.append(896);
    ar.append(563);
    ar.append(780);
    ar.append(787);
    ar.append(911);
    ar
}

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

// Keeps how many frames have passed
#[derive(Component, Copy, Drop, Serde)]
struct SystemFrameTicker {
    frames: u128, 
}

#[derive(Component, Copy, Drop, Serde)]
enum GameState {
    Running: (),
    Finished: (),
}
