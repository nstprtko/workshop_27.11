from app import create_app


def test_metrics_shows_request_counts_and_latency():
    client = create_app().test_client()
    client.get("/health")
    client.post("/tasks", json={})
    body = client.get("/metrics").get_data(as_text=True)
    assert 'http_requests_total{endpoint="/health",method="GET",status="200"}' in body
    assert 'http_requests_total{endpoint="/tasks",method="POST",status="400"}' in body
    assert "http_request_duration_seconds_bucket" in body
