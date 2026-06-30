// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:json_annotation/json_annotation.dart';

enum Status {
  @JsonValue('ACTIVE')
  active,
  @JsonValue('INACTIVE')
  inactive,
  // Fallback for values not present in the spec.
  $unknown;

  @override
  String toString() => const {
        Status.active: 'ACTIVE',
        Status.inactive: 'INACTIVE',
      }[this] ?? '';
}

