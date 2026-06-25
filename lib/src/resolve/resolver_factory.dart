import 'dart_type_resolver.dart';
import 'name_giver.dart';

/// Selects a resolver from the spec's `openapi` version. Defaults to 3.1.
DartTypeResolver resolverForVersion(
  String? openApiVersion,
  NameGiver names, {
  Map<String, dynamic> schemas = const {},
  Set<String> overrides = const {},
}) {
  if (openApiVersion != null && openApiVersion.startsWith('3.0')) {
    return OpenApi30TypeResolver(names, schemas: schemas, overrides: overrides);
  }
  return OpenApi31TypeResolver(names, schemas: schemas, overrides: overrides);
}
