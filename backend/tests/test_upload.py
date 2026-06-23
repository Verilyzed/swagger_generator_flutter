from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_upload_accepts_file_and_label():
    response = client.post(
        "/gadgets/g1/attachments",
        files={"file": ("note.txt", b"hello", "text/plain")},
        data={"label": "notes"},
    )
    assert response.status_code == 200
    body = response.json()
    assert body["filename"] == "note.txt"
    assert body["label"] == "notes"


def test_upload_spec_is_multipart():
    schema = app.openapi()["paths"]["/gadgets/{gadget_id}/attachments"]["post"]
    assert "multipart/form-data" in schema["requestBody"]["content"]
