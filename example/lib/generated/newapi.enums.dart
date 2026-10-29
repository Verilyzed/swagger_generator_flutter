// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:json_annotation/json_annotation.dart';

enum ApiRequestAction {
  @JsonValue('READ')
  read,
  @JsonValue('CREATE')
  create,
  @JsonValue('UPDATE')
  update,
  @JsonValue('DELETE')
  delete,
  // Fallback for values not present in the spec.
  $unknown;

  @override
  String toString() => const {
        ApiRequestAction.read: 'READ',
        ApiRequestAction.create: 'CREATE',
        ApiRequestAction.update: 'UPDATE',
        ApiRequestAction.delete: 'DELETE',
      }[this] ?? '';
}

enum ApiRequestResourceType {
  @JsonValue('ITEM')
  item,
  @JsonValue('VAULT')
  vault,
  // Fallback for values not present in the spec.
  $unknown;

  @override
  String toString() => const {
        ApiRequestResourceType.item: 'ITEM',
        ApiRequestResourceType.vault: 'VAULT',
      }[this] ?? '';
}

enum ApiRequestResult {
  @JsonValue('SUCCESS')
  success,
  @JsonValue('DENY')
  deny,
  // Fallback for values not present in the spec.
  $unknown;

  @override
  String toString() => const {
        ApiRequestResult.success: 'SUCCESS',
        ApiRequestResult.deny: 'DENY',
      }[this] ?? '';
}

enum FieldPurpose {
  @JsonValue('')
  empty,
  @JsonValue('USERNAME')
  username,
  @JsonValue('PASSWORD')
  password,
  @JsonValue('NOTES')
  notes,
  // Fallback for values not present in the spec.
  $unknown;

  @override
  String toString() => const {
        FieldPurpose.empty: '',
        FieldPurpose.username: 'USERNAME',
        FieldPurpose.password: 'PASSWORD',
        FieldPurpose.notes: 'NOTES',
      }[this] ?? '';
}

enum FieldType {
  @JsonValue('STRING')
  string,
  @JsonValue('EMAIL')
  email,
  @JsonValue('CONCEALED')
  concealed,
  @JsonValue('URL')
  url,
  @JsonValue('TOTP')
  totp,
  @JsonValue('DATE')
  date,
  @JsonValue('MONTH_YEAR')
  monthYear,
  @JsonValue('MENU')
  menu,
  // Fallback for values not present in the spec.
  $unknown;

  @override
  String toString() => const {
        FieldType.string: 'STRING',
        FieldType.email: 'EMAIL',
        FieldType.concealed: 'CONCEALED',
        FieldType.url: 'URL',
        FieldType.totp: 'TOTP',
        FieldType.date: 'DATE',
        FieldType.monthYear: 'MONTH_YEAR',
        FieldType.menu: 'MENU',
      }[this] ?? '';
}

enum GeneratorRecipeCharacterSetsItem {
  @JsonValue('LETTERS')
  letters,
  @JsonValue('DIGITS')
  digits,
  @JsonValue('SYMBOLS')
  symbols,
  // Fallback for values not present in the spec.
  $unknown;

  @override
  String toString() => const {
        GeneratorRecipeCharacterSetsItem.letters: 'LETTERS',
        GeneratorRecipeCharacterSetsItem.digits: 'DIGITS',
        GeneratorRecipeCharacterSetsItem.symbols: 'SYMBOLS',
      }[this] ?? '';
}

enum ItemCategory {
  @JsonValue('LOGIN')
  login,
  @JsonValue('PASSWORD')
  password,
  @JsonValue('API_CREDENTIAL')
  apiCredential,
  @JsonValue('SERVER')
  server,
  @JsonValue('DATABASE')
  database,
  @JsonValue('CREDIT_CARD')
  creditCard,
  @JsonValue('MEMBERSHIP')
  membership,
  @JsonValue('PASSPORT')
  passport,
  @JsonValue('SOFTWARE_LICENSE')
  softwareLicense,
  @JsonValue('OUTDOOR_LICENSE')
  outdoorLicense,
  @JsonValue('SECURE_NOTE')
  secureNote,
  @JsonValue('WIRELESS_ROUTER')
  wirelessRouter,
  @JsonValue('BANK_ACCOUNT')
  bankAccount,
  @JsonValue('DRIVER_LICENSE')
  driverLicense,
  @JsonValue('IDENTITY')
  identity,
  @JsonValue('REWARD_PROGRAM')
  rewardProgram,
  @JsonValue('DOCUMENT')
  document,
  @JsonValue('EMAIL_ACCOUNT')
  emailAccount,
  @JsonValue('SOCIAL_SECURITY_NUMBER')
  socialSecurityNumber,
  @JsonValue('MEDICAL_RECORD')
  medicalRecord,
  @JsonValue('SSH_KEY')
  sshKey,
  @JsonValue('CUSTOM')
  custom,
  // Fallback for values not present in the spec.
  $unknown;

  @override
  String toString() => const {
        ItemCategory.login: 'LOGIN',
        ItemCategory.password: 'PASSWORD',
        ItemCategory.apiCredential: 'API_CREDENTIAL',
        ItemCategory.server: 'SERVER',
        ItemCategory.database: 'DATABASE',
        ItemCategory.creditCard: 'CREDIT_CARD',
        ItemCategory.membership: 'MEMBERSHIP',
        ItemCategory.passport: 'PASSPORT',
        ItemCategory.softwareLicense: 'SOFTWARE_LICENSE',
        ItemCategory.outdoorLicense: 'OUTDOOR_LICENSE',
        ItemCategory.secureNote: 'SECURE_NOTE',
        ItemCategory.wirelessRouter: 'WIRELESS_ROUTER',
        ItemCategory.bankAccount: 'BANK_ACCOUNT',
        ItemCategory.driverLicense: 'DRIVER_LICENSE',
        ItemCategory.identity: 'IDENTITY',
        ItemCategory.rewardProgram: 'REWARD_PROGRAM',
        ItemCategory.document: 'DOCUMENT',
        ItemCategory.emailAccount: 'EMAIL_ACCOUNT',
        ItemCategory.socialSecurityNumber: 'SOCIAL_SECURITY_NUMBER',
        ItemCategory.medicalRecord: 'MEDICAL_RECORD',
        ItemCategory.sshKey: 'SSH_KEY',
        ItemCategory.custom: 'CUSTOM',
      }[this] ?? '';
}

enum ItemState {
  @JsonValue('ARCHIVED')
  archived,
  @JsonValue('DELETED')
  deleted,
  // Fallback for values not present in the spec.
  $unknown;

  @override
  String toString() => const {
        ItemState.archived: 'ARCHIVED',
        ItemState.deleted: 'DELETED',
      }[this] ?? '';
}

enum PatchItemOp {
  @JsonValue('add')
  add,
  @JsonValue('remove')
  remove,
  @JsonValue('replace')
  replace,
  // Fallback for values not present in the spec.
  $unknown;

  @override
  String toString() => const {
        PatchItemOp.add: 'add',
        PatchItemOp.remove: 'remove',
        PatchItemOp.replace: 'replace',
      }[this] ?? '';
}

enum VaultType {
  @JsonValue('USER_CREATED')
  userCreated,
  @JsonValue('PERSONAL')
  personal,
  @JsonValue('EVERYONE')
  everyone,
  @JsonValue('TRANSFER')
  transfer,
  // Fallback for values not present in the spec.
  $unknown;

  @override
  String toString() => const {
        VaultType.userCreated: 'USER_CREATED',
        VaultType.personal: 'PERSONAL',
        VaultType.everyone: 'EVERYONE',
        VaultType.transfer: 'TRANSFER',
      }[this] ?? '';
}

