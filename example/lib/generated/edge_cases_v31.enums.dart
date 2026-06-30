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

enum IntEnum {
  @JsonValue('1')
  $1,
  @JsonValue('2')
  $2,
  @JsonValue('3')
  $3,
  // Fallback for values not present in the spec.
  $unknown;

  @override
  String toString() => const {
        IntEnum.$1: '1',
        IntEnum.$2: '2',
        IntEnum.$3: '3',
      }[this] ?? '';
}

enum WeirdEnum {
  @JsonValue('with space')
  withSpace,
  @JsonValue('with-hyphen')
  withHyphen,
  @JsonValue('1leading')
  $1leading,
  @JsonValue('class')
  $class,
  @JsonValue('\$dollar')
  dollar,
  @JsonValue('')
  empty,
  // Fallback for values not present in the spec.
  $unknown;

  @override
  String toString() => const {
        WeirdEnum.withSpace: 'with space',
        WeirdEnum.withHyphen: 'with-hyphen',
        WeirdEnum.$1leading: '1leading',
        WeirdEnum.$class: 'class',
        WeirdEnum.dollar: '\$dollar',
        WeirdEnum.empty: '',
      }[this] ?? '';
}

enum SingleEnum {
  @JsonValue('ONLY')
  only,
  // Fallback for values not present in the spec.
  $unknown;

  @override
  String toString() => const {
        SingleEnum.only: 'ONLY',
      }[this] ?? '';
}

