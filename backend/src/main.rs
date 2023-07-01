use axum::{response::Html, routing::get, Router};
use std::net::SocketAddr;
use sqlx::postgres::PgPoolOptions;
use redis::Commands;

#[tokio::main]
async fn main() -> Result<(), sqlx::Error> {
    let pool = PgPoolOptions::new()
        .max_connections(5)
        .connect("postgres://postgres:password@postgres/postgres").await?;

    let client = redis::Client::open("redis://redis/").ok().unwrap();
    let mut con = client.get_connection().unwrap();
    let _ : () = con.set("my_key", 42).ok().unwrap();
    let count : i32 = con.get("my_key").ok().unwrap();
    
    let row: (i64,) = sqlx::query_as("SELECT $1")
    .bind(150_i64)
    .fetch_one(&pool).await?;

    // build our application with a route
    let app = Router::new().route("/", get(handler));

    // run it
    let addr = SocketAddr::from(([0, 0, 0, 0], 3000));
    println!("listening on {}", addr);
    axum::Server::bind(&addr)
        .serve(app.into_make_service())
        .await
        .unwrap();

    Ok(())
}

async fn handler() -> Html<&'static str> {
    Html("<h1>Hello, World!</h1>")
}
