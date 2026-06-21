from fastapi import FastAPI

from app.schemas import ErrorResponse, WidgetContainer, WidgetCreate


def _schemas() -> dict:
    probe = FastAPI()

    @probe.post("/c")
    def _c(body: WidgetContainer):
        return body

    @probe.post("/w")
    def _w(body: WidgetCreate):
        return body

    @probe.post("/e")
    def _e(body: ErrorResponse):
        return body

    return probe.openapi()["components"]["schemas"]


def test_container_references_widget_in_a_map():
    container = _schemas()["WidgetContainer"]["properties"]
    assert container["widget_map"]["additionalProperties"] == {
        "$ref": "#/components/schemas/Widget"
    }


def test_container_has_a_list_of_widgets():
    container = _schemas()["WidgetContainer"]["properties"]
    assert container["widgets"]["type"] == "array"
    assert container["widgets"]["items"] == {"$ref": "#/components/schemas/Widget"}


def test_error_response_has_enum_default():
    err = _schemas()["ErrorResponse"]["properties"]
    assert err["error_code"]["default"] == "UNKNOWN"
