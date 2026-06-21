from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_openapi_is_3_1_with_metadata():
    spec = app.openapi()
    assert spec["openapi"].startswith("3.1")
    assert spec["info"]["title"] == "Edge Case Test API"
    assert spec["info"]["version"] == "1.0.0"
