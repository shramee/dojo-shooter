# Dojo shooter

### You are the last survivor in a zombie apocalypse. Shoot the zombies before they invade your base.

Dojo shooter is a fun implementation of a game that would be normally considered a bad fit for the blockchain.
This is because the game requires fast updates and high frequency transactions for updates/interactions which
is typically not possible on a blockchain. This game is built with all game logic and mechanics in
Cairo. All this makes it fully provable for when stakes are high enough.

Built with tooling from the StarkNet ecosystem particularly Dojo, the game runs a fully on chain with every action happening in smart contracts and a P5js based renderer.

## Installation

### Pre-requisites:

1. Install Cairo - https://cairo-book.github.io/ch01-01-installation.html
2. Install Dojo - https://dojoengine.org/
3. Use `nightly-8062d63c3ed382753ebc3302bb26e63d791e0f2e` version of dojo,
  ```
  dojoup -v nightly-8062d63c3ed382753ebc3302bb26e63d791e0f2e
  ```

### Running the game

Clone the repo and go into the direectory in the terminal and run these commands.

1. Run Katana in a terminal window with,
  ```
  katana --allow-zero-max-fee --gas-price 0
  ```
2. Switch to a new terminal window to run these commands,
  ```
  make build # Builds the contracts
  make deploy # Deploys the contracts to local Katana
  ```
3. In a(nother) terminal window, start the client serve,
  ```
  make serve # Serves game client on http://localhost:8000
  ```
4. In (yet) another terminal start ticker, this updates the games at regular interval of 100ms
  ```
  make loop_tick
  ```
5. Go to http://localhost:8000

## Challenges and ideas

### Player wallets

A set of keys could be generated for the player when she opens the game. This could then be used to create a (temporary) account for the user.
This abstracts away the friction of having to have your wallet/account to interact with the game.
Some tokens could also be credited to the user to allow them to have an experience before the wallet/funding friction.
Right now renderer is using prefunded account hard coded into the client.

### Glitch when shooting

You may notice a glitch when you shoot a zombie.
The whole rendition pauses for like half a second, that when the client tries to prepare the transaction and do the signatures.
This whole process can be offloaded to another thread to avoid having the renderer freeze up.

### Known bug - Indexing issue

There seems to ba an issue with indexing when setting entity components with the same ID duplicates them (which can be affirmed by shadow getting thicker in the UI). Similar issue which might be related happens when trying to delete these entities. This issue is reported at https://github.com/dojoengine/dojo/issues/558.
This either happens because of some indexing bug or 
