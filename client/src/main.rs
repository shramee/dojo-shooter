extern crate rocket;
extern crate rocket_contrib;
use rocket::fairing::{Fairing, Info, Kind};
use rocket::http::Header;
use rocket::{Request, Response};

use std::{env, fs};

use rocket_contrib::serve::StaticFiles;

pub struct CORS;

impl Fairing for CORS {
    fn info(&self) -> Info {
        Info {
            name: "Add CORS headers to responses",
            kind: Kind::Response,
        }
    }

    fn on_response(&self, request: &Request, response: &mut Response) {
        response.set_header(Header::new("Access-Control-Allow-Origin", "*"));
        response.set_header(Header::new(
            "Access-Control-Allow-Methods",
            "POST, GET, PATCH, OPTIONS",
        ));
        response.set_header(Header::new("Access-Control-Allow-Headers", "*"));
        response.set_header(Header::new("Access-Control-Allow-Credentials", "true"));
    }
}

fn rocket() -> rocket::Rocket {
    rocket::ignite()
        .mount("/", StaticFiles::from("static"))
        .attach(CORS)
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
