import time

from flask import Blueprint, Response, request
from prometheus_client import CONTENT_TYPE_LATEST, Counter, Histogram, generate_latest

REQUESTS = Counter(
    "http_requests_total", "HTTP requests", ["method", "endpoint", "status"]
)
LATENCY = Histogram(
    "http_request_duration_seconds", "Request latency in seconds", ["endpoint"]
)

bp = Blueprint("metrics", __name__)


@bp.get("/metrics")
def metrics():
    return Response(generate_latest(), content_type=CONTENT_TYPE_LATEST)


def init_metrics(app):
    @app.before_request
    def start_timer():
        request.environ["metrics_start"] = time.perf_counter()

    @app.after_request
    def record(response):
        endpoint = request.url_rule.rule if request.url_rule else "unmatched"
        if endpoint != "/metrics":
            seconds = time.perf_counter() - request.environ["metrics_start"]
            REQUESTS.labels(request.method, endpoint, str(response.status_code)).inc()
            LATENCY.labels(endpoint).observe(seconds)
        return response

    app.register_blueprint(bp)
