# Edge-Case Test Backend Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A disposable FastAPI backend whose auto-generated OpenAPI 3.1 spec exercises a broad set of generator-supported edge cases, exported to `backend/test_api.openapi.json`.

**Architecture:** Pydantic schemas (`app/schemas.py`) define the edge-case data shapes; FastAPI routes (`app/main.py`) expose all five HTTP verbs over them; `export_openapi.py` dumps `app.openapi()` to a JSON file. Tests use pytest + FastAPI's TestClient and assert against `app.openapi()`.

**Tech Stack:** Python 3, FastAPI, Pydantic v2, pytest, httpx (TestClient).

## Global Constraints

- Self-contained under `backend/`; deletable with `rm -rf backend/` with no impact on the Dart package. Nothing in the Dart package imports from it.
- No emojis anywhere (code, comments, docs, commit messages).
- OpenAPI output must be 3.1.x (FastAPI default; do not downgrade).
- Edge cases stay within generator-supported constructs: string enums (incl. enum-typed defaults), optional/nullable fields, nested `$ref`, lists, `Dict`/`additionalProperties` maps, primitives, `date-time`. Do NOT add allOf/oneOf, anonymous inline objects, or recursive models.
- Python tooling runs in a local venv at `backend/.venv`; invoke it directly as `backend/.venv/bin/python` (no activation needed).
- All pytest commands are run from the `backend/` directory so the `app` package imports cleanly.

---

### Task 1: Backend scaffold, venv, and app skeleton

**Files:**
- Create: `backend/requirements.txt`
- Create: `backend/.gitignore`
- Create: `backend/README.md`
- Create: `backend/app/__init__.py`
- Create: `backend/app/main.py`
- Create: `backend/tests/__init__.py`
- Test: `backend/tests/test_app.py`

**Interfaces:**
- Produces: a FastAPI `app` object in `backend/app/main.py` with `title="Edge Case Test API"`, `version="1.0.0"`, importable as `from app.main import app`.

- [ ] **Step 1: Create `backend/requirements.txt`**

```
fastapi>=0.110.0
uvicorn>=0.29.0
httpx>=0.27.0
pytest>=8.0.0
```

- [ ] **Step 2: Create `backend/.gitignore`**

```
.venv/
__pycache__/
*.pyc
.pytest_cache/
```

- [ ] **Step 3: Create `backend/README.md`**

```markdown
# Edge-Case Test Backend

A disposable FastAPI backend whose OpenAPI 3.1 spec exercises edge cases for the
Dart generator. Not part of the published package - delete `backend/` to remove
it entirely.

## Setup

```bash
cd backend
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt
```

## Export the swagger file

```bash
cd backend
.venv/bin/python export_openapi.py
```

Writes `backend/test_api.openapi.json`.

## Run the server (optional)

```bash
cd backend
.venv/bin/uvicorn app.main:app --reload
```

## Tests

```bash
cd backend
.venv/bin/python -m pytest tests/ -q
```
```

- [ ] **Step 4: Create `backend/app/__init__.py` and `backend/tests/__init__.py`**

Both files are empty.

- [ ] **Step 5: Create the venv and install dependencies**

Run from `backend/`:
```bash
python3 -m venv .venv && .venv/bin/pip install -r requirements.txt
```
Expected: installs fastapi, uvicorn, httpx, pytest and their dependencies.

- [ ] **Step 6: Write the failing test `backend/tests/test_app.py`**

```python
from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_openapi_is_3_1_with_metadata():
    spec = app.openapi()
    assert spec["openapi"].startswith("3.1")
    assert spec["info"]["title"] == "Edge Case Test API"
    assert spec["info"]["version"] == "1.0.0"
```

- [ ] **Step 7: Run the test to verify it fails**

Run from `backend/`: `.venv/bin/python -m pytest tests/test_app.py -q`
Expected: FAIL (`ModuleNotFoundError: No module named 'app.main'`).

- [ ] **Step 8: Create `backend/app/main.py`**

```python
from fastapi import FastAPI

app = FastAPI(title="Edge Case Test API", version="1.0.0")
```

- [ ] **Step 9: Run the test to verify it passes**

Run from `backend/`: `.venv/bin/python -m pytest tests/test_app.py -q`
Expected: PASS (1 passed).

- [ ] **Step 10: Commit**

```bash
git add backend/
git commit -m "Scaffold FastAPI test backend"
```

---

### Task 2: Enums and the Widget model

**Files:**
- Create: `backend/app/schemas.py`
- Test: `backend/tests/test_schemas.py`

**Interfaces:**
- Consumes: `app` from Task 1 (the test imports a route that exposes `Widget`; to keep this task self-contained, the test registers `Widget` on the app via a throwaway route defined in the test itself - see Step 1).
- Produces: `StatusEnum`, `PriorityEnum`, `ErrorCodeEnum` (str enums) and `Widget` (Pydantic model) in `app/schemas.py`.

- [ ] **Step 1: Write the failing test `backend/tests/test_schemas.py`**

```python
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
```

- [ ] **Step 2: Run the test to verify it fails**

Run from `backend/`: `.venv/bin/python -m pytest tests/test_schemas.py -q`
Expected: FAIL (`ModuleNotFoundError: No module named 'app.schemas'`).

- [ ] **Step 3: Create `backend/app/schemas.py`**

```python
from datetime import datetime
from enum import Enum
from typing import Any, Optional

from pydantic import BaseModel, Field


class StatusEnum(str, Enum):
    active = "active"
    inactive = "inactive"
    archived = "archived"


class PriorityEnum(str, Enum):
    low = "low"
    medium = "medium"
    high = "high"


class ErrorCodeEnum(str, Enum):
    unknown = "UNKNOWN"
    not_found = "NOT_FOUND"
    invalid = "INVALID"


class Widget(BaseModel):
    model_config = {"populate_by_name": True}

    id: str
    asset_id: str
    name: str
    status: StatusEnum
    priority: PriorityEnum = PriorityEnum.low
    description: Optional[str] = None
    tags: list[str] = []
    count: int = 0
    ratio: float
    is_active: bool = True
    created_at: datetime
    updated_at: Optional[datetime] = None
    metadata: dict[str, str] = {}
    extra: dict[str, Any] = {}
    html_url: Optional[str] = None
    default_value: int = Field(0, alias="default")
```

- [ ] **Step 4: Run the test to verify it passes**

Run from `backend/`: `.venv/bin/python -m pytest tests/test_schemas.py -q`
Expected: PASS (6 passed).

- [ ] **Step 5: Commit**

```bash
git add backend/app/schemas.py backend/tests/test_schemas.py
git commit -m "Add enums and the Widget edge-case model"
```

---

### Task 3: Container, create, and error models

**Files:**
- Modify: `backend/app/schemas.py`
- Test: `backend/tests/test_container_schemas.py`

**Interfaces:**
- Consumes: `Widget`, `StatusEnum`, `PriorityEnum`, `ErrorCodeEnum` from Task 2.
- Produces: `WidgetCreate`, `WidgetContainer`, `ErrorResponse` in `app/schemas.py`.

- [ ] **Step 1: Write the failing test `backend/tests/test_container_schemas.py`**

```python
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
```

- [ ] **Step 2: Run the test to verify it fails**

Run from `backend/`: `.venv/bin/python -m pytest tests/test_container_schemas.py -q`
Expected: FAIL (`ImportError: cannot import name 'WidgetContainer'`).

- [ ] **Step 3: Append to `backend/app/schemas.py`**

```python
class WidgetCreate(BaseModel):
    asset_id: str
    name: str
    status: StatusEnum
    priority: PriorityEnum = PriorityEnum.low
    description: Optional[str] = None
    tags: list[str] = []


class WidgetContainer(BaseModel):
    id: str
    primary: Widget
    widgets: list[Widget]
    widget_map: dict[str, Widget]


class ErrorResponse(BaseModel):
    error_code: ErrorCodeEnum = ErrorCodeEnum.unknown
    detail: str
```

- [ ] **Step 4: Run the test to verify it passes**

Run from `backend/`: `.venv/bin/python -m pytest tests/test_container_schemas.py -q`
Expected: PASS (3 passed).

- [ ] **Step 5: Commit**

```bash
git add backend/app/schemas.py backend/tests/test_container_schemas.py
git commit -m "Add container, create, and error models"
```

---

### Task 4: Routes for all five HTTP verbs

**Files:**
- Modify: `backend/app/main.py`
- Test: `backend/tests/test_routes.py`

**Interfaces:**
- Consumes: `app` (Task 1); `Widget`, `WidgetCreate`, `WidgetContainer`, `ErrorResponse`, `StatusEnum` (Tasks 2-3).
- Produces: routes `GET/POST /widgets`, `GET/PUT/PATCH/DELETE /widgets/{widget_id}`, `GET /containers/{container_id}` on `app`, plus a `_sample_widget` helper.

- [ ] **Step 1: Write the failing test `backend/tests/test_routes.py`**

```python
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
```

- [ ] **Step 2: Run the test to verify it fails**

Run from `backend/`: `.venv/bin/python -m pytest tests/test_routes.py -q`
Expected: FAIL (KeyError on `/widgets` - no routes registered yet).

- [ ] **Step 3: Replace `backend/app/main.py`**

```python
from datetime import datetime
from typing import Optional

from fastapi import FastAPI

from app.schemas import (
    ErrorResponse,
    StatusEnum,
    Widget,
    WidgetContainer,
    WidgetCreate,
)

app = FastAPI(title="Edge Case Test API", version="1.0.0")


def _sample_widget(widget_id: str = "w1") -> Widget:
    return Widget(
        id=widget_id,
        asset_id="a1",
        name="Sample",
        status=StatusEnum.active,
        ratio=1.0,
        created_at=datetime(2020, 1, 1),
    )


@app.get("/widgets", response_model=list[Widget], tags=["widgets"])
def list_widgets(
    status: Optional[StatusEnum] = None,
    limit: int = 50,
    offset: int = 0,
):
    return [_sample_widget()]


@app.get(
    "/widgets/{widget_id}",
    response_model=Widget,
    responses={404: {"model": ErrorResponse}},
    tags=["widgets"],
)
def get_widget(widget_id: str):
    return _sample_widget(widget_id)


@app.post("/widgets", response_model=Widget, tags=["widgets"])
def create_widget(body: WidgetCreate):
    return _sample_widget()


@app.put("/widgets/{widget_id}", response_model=Widget, tags=["widgets"])
def replace_widget(widget_id: str, body: WidgetCreate):
    return _sample_widget(widget_id)


@app.patch("/widgets/{widget_id}", response_model=Widget, tags=["widgets"])
def update_widget(widget_id: str, body: WidgetCreate):
    return _sample_widget(widget_id)


@app.delete("/widgets/{widget_id}", tags=["widgets"])
def delete_widget(widget_id: str):
    return {"deleted": widget_id}


@app.get(
    "/containers/{container_id}",
    response_model=WidgetContainer,
    responses={404: {"model": ErrorResponse}},
    tags=["containers"],
)
def get_container(container_id: str):
    widget = _sample_widget()
    return WidgetContainer(
        id=container_id,
        primary=widget,
        widgets=[widget],
        widget_map={"k": widget},
    )
```

- [ ] **Step 4: Run the test to verify it passes**

Run from `backend/`: `.venv/bin/python -m pytest tests/test_routes.py -q`
Expected: PASS (5 passed).

- [ ] **Step 5: Commit**

```bash
git add backend/app/main.py backend/tests/test_routes.py
git commit -m "Add routes covering all five HTTP verbs"
```

---

### Task 5: OpenAPI export script

**Files:**
- Create: `backend/export_openapi.py`
- Test: `backend/tests/test_export.py`

**Interfaces:**
- Consumes: `app` from `app/main.py` (Task 4).
- Produces: `export_openapi.py` with a `main()` that writes `backend/test_api.openapi.json`.

- [ ] **Step 1: Write the failing test `backend/tests/test_export.py`**

```python
import json
from pathlib import Path

import export_openapi


def test_export_writes_valid_openapi(tmp_path, monkeypatch):
    target = tmp_path / "out.json"
    monkeypatch.setattr(export_openapi, "OUTPUT", target)

    export_openapi.main()

    spec = json.loads(target.read_text())
    assert spec["openapi"].startswith("3.1")
    assert "Widget" in spec["components"]["schemas"]
    assert "/widgets" in spec["paths"]
```

- [ ] **Step 2: Run the test to verify it fails**

Run from `backend/`: `.venv/bin/python -m pytest tests/test_export.py -q`
Expected: FAIL (`ModuleNotFoundError: No module named 'export_openapi'`).

- [ ] **Step 3: Create `backend/export_openapi.py`**

```python
import json
import sys
from pathlib import Path

try:
    from app.main import app
except ModuleNotFoundError as error:
    sys.stderr.write(
        f"Failed to import the FastAPI app: {error}\n"
        "Install dependencies first: pip install -r requirements.txt\n",
    )
    sys.exit(1)

OUTPUT = Path(__file__).parent / "test_api.openapi.json"


def main() -> None:
    spec = app.openapi()
    OUTPUT.write_text(json.dumps(spec, indent=2) + "\n")
    schema_count = len(spec.get("components", {}).get("schemas", {}))
    path_count = len(spec.get("paths", {}))
    print(f"Wrote {OUTPUT} ({schema_count} schemas, {path_count} paths)")


if __name__ == "__main__":
    main()
```

- [ ] **Step 4: Run the test to verify it passes**

Run from `backend/`: `.venv/bin/python -m pytest tests/test_export.py -q`
Expected: PASS (1 passed).

- [ ] **Step 5: Commit**

```bash
git add backend/export_openapi.py backend/tests/test_export.py
git commit -m "Add OpenAPI export script"
```

---

### Task 6: Generate the swagger file and verify against the generator

**Files:**
- Create: `backend/test_api.openapi.json` (generated)

**Interfaces:**
- Consumes: everything above.

- [ ] **Step 1: Run the full backend test suite**

Run from `backend/`: `.venv/bin/python -m pytest tests/ -q`
Expected: PASS (all tests from Tasks 1-5, 0 failures).

- [ ] **Step 2: Generate the swagger file**

Run from `backend/`: `.venv/bin/python export_openapi.py`
Expected: prints `Wrote .../backend/test_api.openapi.json (N schemas, M paths)` with N >= 6 and M >= 3, and the file exists.

- [ ] **Step 3: Sanity-check the generated spec**

Run from `backend/`:
```bash
.venv/bin/python -c "import json; s=json.load(open('test_api.openapi.json')); print(s['openapi']); print(sorted(s['components']['schemas'])); print(sorted(s['paths']))"
```
Expected: prints a `3.1.x` version, a schema list including `Widget`, `WidgetContainer`, `WidgetCreate`, `ErrorResponse`, `StatusEnum`, `PriorityEnum`, `ErrorCodeEnum`, and the three paths.

- [ ] **Step 4: End-to-end check through the Dart generator (verification only, do not commit example changes)**

From the repo root:
```bash
cp backend/test_api.openapi.json example/lib/edge_cases.openapi.json
cd example && flutter pub get && dart run build_runner build && flutter analyze
```
Expected: build_runner writes the `edge_cases.*` generated files and `flutter analyze` reports `No issues found!`. If analyze reports errors, that is a real generator gap on a supported construct - record the failing construct, fix it in the generator with a focused test (in the generator package), regenerate, and re-run. After verifying, remove the temporary copy and its generated outputs:
```bash
cd .. && rm -f example/lib/edge_cases.openapi.json example/lib/edge_cases.*.dart
```
(Leave `example/` as it was; this step only proves the spec feeds the generator.)

- [ ] **Step 5: Commit the swagger file**

```bash
git add -f backend/test_api.openapi.json
git commit -m "Generate edge-case swagger file"
```

(The `-f` is in case a broad `*.json` ignore exists; `backend/.gitignore` does not ignore it, so normally `git add` suffices.)

---

## Notes for the implementer

- Run every pytest and export command from the `backend/` directory so `import app...` and `import export_openapi` resolve.
- The probe-app pattern in Tasks 2-3 (registering a model on a throwaway `FastAPI()` to read its JSON schema) keeps schema tests independent of the real routes.
- If `dart run build_runner build` in Step 4 of Task 6 surfaces a generator bug, the fix belongs in the Dart generator package (with its own failing test first), not in the backend.
