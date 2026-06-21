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
