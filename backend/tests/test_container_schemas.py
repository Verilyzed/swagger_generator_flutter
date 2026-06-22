from fastapi import FastAPI

from app.schemas import ErrorResponse, GadgetContainer, GadgetCreate


def _schemas() -> dict:
    probe = FastAPI()

    @probe.post("/c")
    def _c(body: GadgetContainer):
        return body

    @probe.post("/w")
    def _w(body: GadgetCreate):
        return body

    @probe.post("/e")
    def _e(body: ErrorResponse):
        return body

    return probe.openapi()["components"]["schemas"]


def test_container_references_gadget_in_a_map():
    container = _schemas()["GadgetContainer"]["properties"]
    assert container["gadget_map"]["additionalProperties"] == {
        "$ref": "#/components/schemas/Gadget"
    }


def test_container_has_a_list_of_gadgets():
    container = _schemas()["GadgetContainer"]["properties"]
    assert container["gadgets"]["type"] == "array"
    assert container["gadgets"]["items"] == {"$ref": "#/components/schemas/Gadget"}


def test_error_response_has_enum_default():
    err = _schemas()["ErrorResponse"]["properties"]
    assert err["error_code"]["default"] == "UNKNOWN"
