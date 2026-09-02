use lambda_runtime::Error;
use scintilla_route_lambdas::{run, RouteSpec};

const ROUTE: RouteSpec = RouteSpec::new(
    "heavy_schedule_export",
    "POST",
    "/api/heavy/schedule-export",
    "event_id",
);

#[tokio::main]
async fn main() -> Result<(), Error> {
    return run(ROUTE).await;
}
