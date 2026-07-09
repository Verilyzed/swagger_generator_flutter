# Example

A Flutter project showing `swagger_generator_flutter` in use. The OpenAPI
specs in `lib/specs/` are generated into Dart clients in `lib/generated/`,
configured through `build.yaml`:

```yaml
targets:
  $default:
    builders:
      swagger_generator_flutter|swagger_generator:
        options:
          input_folder: lib/specs
          output_folder: lib/generated
```

For each spec (for example `newapi.json`), the build produces enums, models,
a Chopper service, a client, and a `newapi.api.dart` barrel that exports them.
The `.models.g.dart` and `.service.chopper.dart` part files come from
`json_serializable` and `chopper_generator`, which is why both are listed in
this project's `dev_dependencies`.

`lib/main.dart` constructs the generated `ResourceSchedulerApi` facade and
renders the result of its `listAssets` call. Point the `baseUrl` at a real
backend to fetch live data.

## Regenerate

```bash
flutter pub get
dart run build_runner build
```

The generated files are checked in, so the output can be inspected without
running the build.
