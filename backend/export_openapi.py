import json
import sys
from pathlib import Path

try:
    from app.main import app
except ModuleNotFoundError as error:
    if error.name in ("app", "app.main"):
        sys.stderr.write(
            "Could not import the app. Run this script from the backend/ "
            "directory: python export_openapi.py\n",
        )
    else:
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
