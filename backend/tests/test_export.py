import json
from pathlib import Path

import export_openapi


def test_export_writes_valid_openapi(tmp_path, monkeypatch):
    target = tmp_path / "out.json"
    monkeypatch.setattr(export_openapi, "OUTPUT", target)

    export_openapi.main()

    spec = json.loads(target.read_text())
    assert spec["openapi"].startswith("3.1")
    assert "Gadget" in spec["components"]["schemas"]
    assert "/gadgets" in spec["paths"]
