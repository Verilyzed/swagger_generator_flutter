from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_all_verbs_registered():
    paths = app.openapi()["paths"]
    assert set(paths["/widgets"]) >= {"get", "post"}
    assert set(paths["/widgets/{widget_id}"]) >= {"get", "put", "patch", "delete"}
    assert "get" in paths["/containers/{container_id}"]


def test_list_widgets_has_optional_enum_query():
    params = app.openapi()["paths"]["/widgets"]["get"]["parameters"]
    names = {p["name"] for p in params}
    assert {"status", "limit", "offset"} <= names


def test_get_widget_returns_a_widget():
    response = client.get("/widgets/w1")
    assert response.status_code == 200
    assert response.json()["id"] == "w1"


def test_create_widget_accepts_a_body():
    payload = {
        "asset_id": "a1",
        "name": "New",
        "status": "active",
    }
    response = client.post("/widgets", json=payload)
    assert response.status_code == 200


def test_get_container_returns_nested_widgets():
    response = client.get("/containers/c1")
    assert response.status_code == 200
    body = response.json()
    assert body["id"] == "c1"
    assert "k" in body["widget_map"]
