from fastapi import FastAPI

from app.schemas import Widget


def _widget_schema() -> dict:
    probe = FastAPI()

    @probe.post("/probe")
    def _probe(body: Widget):
        return body

    return probe.openapi()["components"]["schemas"]["Widget"]["properties"]


def test_widget_has_string_enum_field():
    props = _widget_schema()
    assert "status" in props


def test_priority_field_has_enum_default():
    props = _widget_schema()
    assert props["priority"]["default"] == "low"


def test_optional_description_is_nullable():
    props = _widget_schema()
    assert "anyOf" in props["description"]
    assert {"type": "null"} in props["description"]["anyOf"]


def test_metadata_is_typed_string_map():
    props = _widget_schema()
    assert props["metadata"]["additionalProperties"] == {"type": "string"}


def test_created_at_is_date_time():
    props = _widget_schema()
    assert props["created_at"]["format"] == "date-time"


def test_reserved_word_alias_field_present():
    props = _widget_schema()
    assert "default" in props
    assert props["default"]["default"] == 0
