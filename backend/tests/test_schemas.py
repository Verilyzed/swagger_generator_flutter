from fastapi import FastAPI

from app.schemas import Gadget


def _gadget_schema() -> dict:
    probe = FastAPI()

    @probe.post("/probe")
    def _probe(body: Gadget):
        return body

    return probe.openapi()["components"]["schemas"]["Gadget"]["properties"]


def test_gadget_has_string_enum_field():
    props = _gadget_schema()
    assert props["status"] == {"$ref": "#/components/schemas/StatusEnum"}


def test_extra_is_untyped_map():
    props = _gadget_schema()
    assert props["extra"]["additionalProperties"] is True


def test_priority_field_has_enum_default():
    props = _gadget_schema()
    assert props["priority"]["default"] == "low"


def test_optional_description_is_nullable():
    props = _gadget_schema()
    assert "anyOf" in props["description"]
    assert {"type": "null"} in props["description"]["anyOf"]


def test_metadata_is_typed_string_map():
    props = _gadget_schema()
    assert props["metadata"]["additionalProperties"] == {"type": "string"}


def test_created_at_is_date_time():
    props = _gadget_schema()
    assert props["created_at"]["format"] == "date-time"


def test_reserved_word_alias_field_present():
    props = _gadget_schema()
    assert "default" in props
    assert props["default"]["default"] == 0
