# Multipart Uploads Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Generate Chopper multipart methods for `multipart/form-data` request bodies, with each field as its own `@Part`/`@PartFile` parameter and file fields typed as `MultipartFile`.

**Architecture:** `ParamLocation` gains `part`/`partFile`; `ServiceEmitter` emits `@multipart` plus part annotations; `SpecParser` turns a multipart body schema's properties into part parameters; the hoister leaves multipart schemas inline. Proven by a real upload round-trip against the backend.

**Tech Stack:** Dart, `package:build`, `chopper`, `package:test`; FastAPI backend.

## Global Constraints

- No emojis anywhere (code, comments, docs, commit messages).
- Single quotes, trailing commas; `dart analyze` clean; `dart test` green.
- TDD: no production code without a failing test first.
- Default (non-multipart) behavior unchanged: a request body without `multipart/form-data` keeps the `@Body()` path.
- File parts use `MultipartFile`; only `type: string, format: binary` is a file part.

---

### Task 1: ParamLocation part/partFile and the emitter

**Files:**
- Modify: `lib/src/ir/api_spec.dart`
- Modify: `lib/src/emit/service_emitter.dart`
- Modify: `test/emit/service_emitter_test.dart`

**Interfaces:**
- Produces: `ParamLocation.part`, `ParamLocation.partFile`; `ServiceEmitter` emits `@multipart` on methods with any part param and `@Part('name')`/`@PartFile('name')` annotations.

- [ ] **Step 1: Add a failing test to `test/emit/service_emitter_test.dart`**

```dart
  test('emits multipart parts', () {
    final out = ServiceEmitter().emit(
      const ServiceDef(
        name: 'DemoService',
        operations: [
          OperationDef(
            methodName: 'upload',
            httpMethod: 'POST',
            path: '/upload',
            parameters: [
              ParamDef(
                dartName: 'file',
                wireName: 'file',
                type: DartType('MultipartFile'),
                location: ParamLocation.partFile,
                isRequired: true,
              ),
              ParamDef(
                dartName: 'label',
                wireName: 'label',
                type: DartType('String'),
                location: ParamLocation.part,
                isRequired: true,
              ),
            ],
            responseType: DartType('dynamic'),
          ),
        ],
      ),
      partFileName: 'demo.service.chopper.dart',
      modelsImport: 'demo.models.dart',
      enumsImport: 'demo.enums.dart',
      enumNames: const {},
    );

    expect(out, contains('  @multipart'));
    expect(out, contains("@PartFile('file') required MultipartFile file,"));
    expect(out, contains("@Part('label') required String label,"));
  });
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `dart test test/emit/service_emitter_test.dart`
Expected: FAIL (`ParamLocation.partFile` / `part` undefined).

- [ ] **Step 3: Add the enum values in `lib/src/ir/api_spec.dart`**

```dart
enum ParamLocation { path, query, body, part, partFile }
```

- [ ] **Step 4: Emit `@multipart` and part annotations in `lib/src/emit/service_emitter.dart`**

In `_emitMethod`, after writing the verb annotation and before the return-type
line, add the multipart marker:

```dart
    buffer.writeln("  @$verb(path: '${op.path}')");
    if (op.parameters.any((p) =>
        p.location == ParamLocation.part ||
        p.location == ParamLocation.partFile)) {
      buffer.writeln('  @multipart');
    }
    buffer.write(
      '  Future<Response<${op.responseType.display}>> ${op.methodName}(',
    );
```

(Replace the existing `buffer ..writeln(verb) ..write(returnLine)` cascade with
the above; the rest of `_emitMethod` is unchanged.)

Add the two cases to `_annotation`:

```dart
      case ParamLocation.part:
        return "@Part('${p.wireName}')";
      case ParamLocation.partFile:
        return "@PartFile('${p.wireName}')";
```

- [ ] **Step 5: Run the test, full suite, and analyzer**

Run: `dart test && dart analyze`
Expected: all PASS, "No issues found!".

- [ ] **Step 6: Commit**

```bash
git add lib/src/ir/api_spec.dart lib/src/emit/service_emitter.dart test/emit/service_emitter_test.dart
git commit -m "Emit multipart parts in the service"
```

---

### Task 2: Parse multipart bodies into part parameters

**Files:**
- Modify: `lib/src/parser/spec_parser.dart`
- Modify: `lib/src/parser/schema_hoister.dart`
- Modify: `test/parser/spec_parser_test.dart`
- Modify: `test/parser/schema_hoister_test.dart`

**Interfaces:**
- Consumes: `ParamLocation.part`/`partFile` (Task 1), `_mergedObject`, `_schemasCache`.
- Produces: a `multipart/form-data` body becomes one part param per property (file properties as `partFile` + `MultipartFile`); the hoister leaves multipart media schemas inline.

- [ ] **Step 1: Add a failing parser test to `test/parser/spec_parser_test.dart`**

```dart
  test('parses a multipart body into part parameters', () {
    final spec = _parser().parse({
      'components': {'schemas': <String, dynamic>{}},
      'paths': {
        '/upload': {
          'post': {
            'operationId': 'upload',
            'requestBody': {
              'content': {
                'multipart/form-data': {
                  'schema': {
                    'type': 'object',
                    'required': ['file'],
                    'properties': {
                      'file': {'type': 'string', 'format': 'binary'},
                      'label': {'type': 'string'},
                    },
                  },
                },
              },
            },
            'responses': <String, dynamic>{},
          },
        },
      },
    }, name: 'demo');

    final params = spec.service.operations.single.parameters;
    final file = params.firstWhere((p) => p.wireName == 'file');
    final label = params.firstWhere((p) => p.wireName == 'label');
    expect(file.location, ParamLocation.partFile);
    expect(file.type.name, 'MultipartFile');
    expect(file.isRequired, isTrue);
    expect(label.location, ParamLocation.part);
    expect(label.type.name, 'String');
    expect(params.any((p) => p.location == ParamLocation.body), isFalse);
  });
```

- [ ] **Step 2: Add a failing hoister test to `test/parser/schema_hoister_test.dart`**

```dart
  test('leaves multipart media schemas inline', () {
    final out = _hoister().hoist({
      'components': {'schemas': <String, dynamic>{}},
      'paths': {
        '/upload': {
          'post': {
            'operationId': 'upload',
            'requestBody': {
              'content': {
                'multipart/form-data': {
                  'schema': {
                    'type': 'object',
                    'properties': {
                      'file': {'type': 'string', 'format': 'binary'},
                    },
                  },
                },
              },
            },
          },
        },
      },
    });

    expect(_schemas(out), isEmpty);
    final post = ((((out['paths'] as Map)['/upload'] as Map)['post'] as Map)
        .cast<String, dynamic>());
    final schema = ((((post['requestBody'] as Map)['content'] as Map)
            ['multipart/form-data'] as Map)['schema'] as Map);
    expect(schema.containsKey('properties'), isTrue);
    expect(schema.containsKey(r'$ref'), isFalse);
  });
```

- [ ] **Step 3: Run the tests to verify they fail**

Run: `dart test test/parser/spec_parser_test.dart test/parser/schema_hoister_test.dart`
Expected: FAIL (parser makes a single `@Body()`; hoister hoists the multipart schema to a named model).

- [ ] **Step 4: Skip multipart media in `lib/src/parser/schema_hoister.dart`**

Replace the loop in `_hoistContent`:

```dart
  void _hoistContent(
    Map<String, dynamic> container,
    String name,
    Map<String, dynamic> schemas,
    Set<String> used,
  ) {
    final content = container['content'];
    if (content is! Map) return;
    for (final entry in content.cast<String, dynamic>().entries) {
      if (entry.key == 'multipart/form-data') continue;
      final media = entry.value;
      if (media is! Map) continue;
      final mediaMap = media.cast<String, dynamic>();
      final schema = mediaMap['schema'];
      if (schema is Map) {
        mediaMap['schema'] = _hoistType(
          schema.cast<String, dynamic>(),
          name,
          schemas,
          used,
        );
      }
    }
  }
```

- [ ] **Step 5: Build multipart part parameters in `lib/src/parser/spec_parser.dart`**

In `_operation`, replace the request-body block (the `bodyType`/`bodySchema`
section) with multipart detection first:

```dart
    DartType? bodyType;
    final body = op['requestBody'];
    final bodyMap = body is Map ? body.cast<String, dynamic>() : null;
    final content = (bodyMap?['content'] as Map?)?.cast<String, dynamic>();
    final multipart =
        (content?['multipart/form-data'] as Map?)?.cast<String, dynamic>();
    if (multipart != null) {
      final schema = multipart['schema'];
      if (schema is Map) {
        final object = _objectFor(schema.cast<String, dynamic>());
        for (final entry in object.properties.entries) {
          final propSchema = (entry.value as Map).cast<String, dynamic>();
          final isFile = propSchema['type'] == 'string' &&
              propSchema['format'] == 'binary';
          params.add(ParamDef(
            dartName: _names.memberName(entry.key),
            wireName: entry.key,
            type: isFile
                ? const DartType('MultipartFile')
                : _resolver.resolve(propSchema),
            location:
                isFile ? ParamLocation.partFile : ParamLocation.part,
            isRequired: object.required.contains(entry.key),
          ));
        }
      }
    } else {
      final bodySchema = _contentSchema(bodyMap);
      if (bodySchema != null) {
        bodyType = _resolver.resolve(bodySchema);
        params.add(ParamDef(
          dartName: 'body',
          wireName: 'body',
          type: bodyType,
          location: ParamLocation.body,
          isRequired: bodyMap?['required'] == true,
        ));
      }
    }
```

Add the `_objectFor` helper next to `_mergedObject`:

```dart
  ({Map<String, dynamic> properties, List<String> required}) _objectFor(
    Map<String, dynamic> schema,
  ) {
    final ref = schema[r'$ref'];
    if (ref is String) {
      final target = _schemasCache[ref.split('/').last];
      if (target is Map<String, dynamic>) return _mergedObject(target);
    }
    return _mergedObject(schema);
  }
```

- [ ] **Step 6: Run the tests, full suite, and analyzer**

Run: `dart test && dart analyze`
Expected: all PASS, "No issues found!".

- [ ] **Step 7: Commit**

```bash
git add lib/src/parser/spec_parser.dart lib/src/parser/schema_hoister.dart test/parser/spec_parser_test.dart test/parser/schema_hoister_test.dart
git commit -m "Parse multipart bodies into part parameters"
```

---

### Task 3: Backend upload endpoint and round-trip

**Files:**
- Modify: `backend/app/main.py`, `backend/requirements.txt` (python-multipart), regenerate `backend/test_api.openapi.json`
- Test: a focused backend test for the new endpoint

**Interfaces:**
- Consumes: Tasks 1-2.

- [ ] **Step 1: Add `python-multipart` to `backend/requirements.txt`**

FastAPI needs it for form/file parsing. Add the line:

```
python-multipart>=0.0.9
```

Run from `backend/`: `.venv/bin/pip install -r requirements.txt`
Expected: installs python-multipart.

- [ ] **Step 2: Add a failing backend test `backend/tests/test_upload.py`**

```python
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
```

- [ ] **Step 3: Run the test to verify it fails**

Run from `backend/`: `.venv/bin/python -m pytest tests/test_upload.py -q`
Expected: FAIL (404 - route not defined).

- [ ] **Step 4: Add the upload route to `backend/app/main.py`**

Add the imports at the top (next to the existing FastAPI import):

```python
from fastapi import FastAPI, File, Form, UploadFile
```

Add the route (anywhere among the other routes):

```python
@app.post("/gadgets/{gadget_id}/attachments", tags=["gadgets"])
async def upload_attachment(
    gadget_id: str,
    file: UploadFile = File(...),
    label: str = Form(...),
):
    return {"gadget_id": gadget_id, "filename": file.filename, "label": label}
```

- [ ] **Step 5: Run the backend suite and regenerate the spec**

Run from `backend/`:
```bash
.venv/bin/python -m pytest -q
.venv/bin/python export_openapi.py
```
Expected: all backend tests pass; `test_api.openapi.json` now has the
`/gadgets/{gadget_id}/attachments` POST with a `multipart/form-data` body.

- [ ] **Step 6: Commit the backend changes**

```bash
git add backend/app/main.py backend/requirements.txt backend/tests/test_upload.py backend/test_api.openapi.json
git commit -m "Add a multipart upload endpoint to the test backend"
```

- [ ] **Step 7: Generate the client and round-trip the upload**

Copy the spec into the example and generate:
```bash
cp backend/test_api.openapi.json example/lib/specs/gadgets.json
cd example && dart run build_runner build && flutter analyze 2>&1 | grep -i gadgets || echo "gadgets clean"
cd ..
grep -E "@multipart|@PartFile|MultipartFile" example/lib/generated/gadgets.service.dart | head
```
Expected: `gadgets clean`; the generated upload method has `@multipart`,
`@PartFile('file') required MultipartFile file`, and `@Part('label') ...`. If
`MultipartFile` is undefined, add `import 'package:http/http.dart' show MultipartFile;`
to `ServiceEmitter.emit` (only when a `partFile` param exists), add an emitter
test for the import, regenerate, and continue.

- [ ] **Step 8: Run the backend and a consumer that uploads**

Start the backend (`uvicorn app.main:app --port 8000` from `backend/`). Write
`example/bin/upload_check.dart` (confirm the generated method name from
`gadgets.service.dart` first):
```dart
import 'package:chopper/chopper.dart';
import 'package:http/http.dart' show MultipartFile;
import 'package:example/generated/gadgets.api.dart';

Future<void> main() async {
  final client = createClient(baseUrl: Uri.parse('http://localhost:8000'));
  final service = GadgetsService.create(client);

  final res = await service.<uploadMethodName>(
    gadgetId: 'g1',
    file: MultipartFile.fromBytes('file', [104, 105], filename: 'note.txt'),
    label: 'notes',
  );
  print('upload -> ${res.statusCode}, body: ${res.body}');
  if (res.statusCode != 200) throw StateError('upload failed');
  client.dispose();
  print('RUNTIME OK');
}
```
Run from `example/`: `dart run bin/upload_check.dart`
Expected: `200`, the body shows `filename: note.txt` and `label: notes`, and
`RUNTIME OK`. This confirms the multipart wire format and that `MultipartFile`
carries the filename.

- [ ] **Step 9: Tear down**

```bash
pkill -f "uvicorn app.main"
rm -f example/lib/specs/gadgets.json example/bin/upload_check.dart
rmdir example/bin 2>/dev/null
cd example && dart run build_runner build >/dev/null 2>&1 && cd ..
git checkout -- example/ 2>/dev/null
git status --short
```
Expected: no leftover `gadgets.*` or consumer files; `example/` clean.

- [ ] **Step 10: Record the result**

No commit beyond the backend changes (committed in Step 6) and any generator
fix from Step 7. The deliverable is the verified `RUNTIME OK`.

---

## Notes for the implementer

- Only `type: string, format: binary` is a file part; every other multipart property is a value `@Part`.
- The hoister skips multipart media so no dead `<Op>Request` model is generated; the parser reads the properties directly, following a `$ref` to a named schema when the spec author named the multipart body.
- `MultipartFile` comes from `package:http`; Chopper may re-export it. The runtime step in Task 3 confirms whether the generated service needs an explicit http import.
