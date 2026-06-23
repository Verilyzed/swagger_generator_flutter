/// The raw name an operation is derived from, before identifier formatting.
///
/// Shared by the method-name path (`memberName`) and the hoisted request and
/// response model names (`className`), so both stay in sync.
String operationBaseName({
  required String httpMethod,
  required String path,
  String? operationId,
  required bool nameFromPath,
}) =>
    nameFromPath
        ? '${httpMethod.toLowerCase()}_$path'
        : operationId ?? '${httpMethod.toLowerCase()}_$path';
