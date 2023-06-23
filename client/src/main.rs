extern crate rocket;
extern crate rocket_contrib;

use std::{env, fs};

use rocket_contrib::serve::StaticFiles;

fn rocket() -> rocket::Rocket {
    rocket::ignite().mount("/", StaticFiles::from("static"))
}

fn main() {
    let world_addr = env::var("WORLD_ADDR").unwrap_or("".into());
    let rpc_addr = env::var("RPC_ADDR").unwrap_or("http://localhost:5050".into());
    fs::write(
        "./static/ecs-data.js",
        format!("window.ecs_data={{world_addr:\"{world_addr}\",rpc:\"{rpc_addr}\"}};"),
    )
    .unwrap();
    rocket().launch();
}
