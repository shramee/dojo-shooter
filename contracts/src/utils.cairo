use traits::{ Into, TryInto };
use array::{SpanTrait};
use option::OptionTrait;
use dojo_core::interfaces::{Context, IWorldDispatcherTrait};
use dojo_shooter::components::{GameState, GameStates, GameStatesSerde};

fn get_game_state(ctx: Context) -> GameStates {
    let mut game_state_serialized = ctx.world.entity('GameState', 'game_state'.into(), 0, 0);
    
    if game_state_serialized.len() == 0 {
        return GameStates::Finished(());
    }
    let game_state: GameStates = GameStatesSerde::deserialize(ref game_state_serialized).unwrap();
    
    game_state
}
