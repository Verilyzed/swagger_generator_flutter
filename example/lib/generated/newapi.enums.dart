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
}

enum ApiRequestResult {
  @JsonValue('SUCCESS')
  success,
  @JsonValue('DENY')
  deny,
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
}

enum FullItemCategory {
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
}

enum FullItemState {
  @JsonValue('ARCHIVED')
  archived,
  @JsonValue('DELETED')
  deleted,
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
}

enum ItemState {
  @JsonValue('ARCHIVED')
  archived,
  @JsonValue('DELETED')
  deleted,
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
}

