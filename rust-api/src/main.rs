#![feature(plugin, const_fn, decl_macro, proc_macro_hygiene)]
#![allow(proc_macro_derive_resolution_fallback, unused_attributes)]

#[macro_use]
extern crate diesel;
#[macro_use]
extern crate diesel_migrations;
extern crate dotenv;
extern crate r2d2;
extern crate r2d2_diesel;
#[macro_use]
extern crate rocket;
extern crate rocket_contrib;
#[macro_use]
extern crate serde_derive;
#[macro_use]
extern crate serde_json;

use dotenv::dotenv;
use std::env;
use routes::*;

mod db;
mod models;
mod routes;
mod schema;

embed_migrations!();

fn rocket() -> rocket::Rocket {
    dotenv().ok();

    let database_url = env::var("DATABASE_URL").expect("set DATABASE_URL");

    let pool = db::init_pool(database_url);
    let conn = pool.get().unwrap();
    match embedded_migrations::run(&*conn) {
        Err(e) => println!("{:?}", e),
        _ => ()
    }
    rocket::ignite()
        .manage(pool)
        .mount(
            "/api/v1/",
            routes![get_all, new_user, find_user],
        )
}

fn main() {
    rocket().launch();
}
