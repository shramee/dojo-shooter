extern crate rocket;
extern crate rocket_contrib;

use std::{env, fs};

use rocket_contrib::serve::StaticFiles;

fn rocket() -> rocket::Rocket {
    rocket::ignite().mount("/", StaticFiles::from("static"))
}

fn main() {
    let world_addr = env::var("W_ADDR").unwrap_or("".into());
    let ac_addr = env::var("AC_ADDR").unwrap_or("".into());
    let ac_key = env::var("PK").unwrap_or("".into());
    let rpc_addr = env::var("RPC_URL").unwrap_or("http://localhost:5050".into());

    print!(
        "world_addr: {world_addr}
ac_addr: {ac_addr}
ac_key: {ac_key}
rpc_addr: {rpc_addr}"
    );

    fs::write(
        "./static/ecs-data.js",
        format!("window.ecs_data={{ac_addr:'{ac_addr}',ac_key:'{ac_key}',world_addr:'{world_addr}',rpc:'{rpc_addr}'}};"),
    )
    .unwrap();
    rocket().launch();
}
