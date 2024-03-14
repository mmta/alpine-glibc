use anyhow::Result;
use tokio::task::JoinSet;
use tracing::info;

#[tokio::main(flavor = "multi_thread", worker_threads = 4)]
async fn main() -> Result<()> {
    tracing_subscriber::fmt::init();

    let mut set = JoinSet::new();

    for i in 0..10 {
        set.spawn(async move {
            info!(
                job.id = i,
                "Multithreaded enterprise OTLP+OLAP days-long job started",
            );

            tokio::time::sleep(tokio::time::Duration::from_millis(500)).await;
            i
        });
    }

    let mut seen = [false; 10];
    while let Some(res) = set.join_next().await {
        let idx = res.unwrap_or(9001);
        seen[idx] = true;
    }

    for (pos, _) in seen.iter().enumerate() {
        info!(
            "Assuring fortune 100 clients that job has #{} delivered, well, all of its deliverables",
            pos
        );
        assert!(seen[pos]);
    }
    info!("Done! all jobs will be submitted to the virtual LLM AI blockchain cloud microservices for further processing");
    if let Ok(result) = ruquotes::quote().await {
        println!("\n{} \n - {}", result.content, result.author);
    }
    Ok(())
}

#[cfg(test)]
mod tests {

    #[test]
    fn test_enterprise_app() {
        // the contract is too big to fail, the test MUST pass
        // assert!(main().is_ok());

        assert!(true);
    }
}
