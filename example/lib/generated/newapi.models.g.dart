// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'newapi.models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiRequest _$ApiRequestFromJson(Map<String, dynamic> json) => ApiRequest(
  action: $enumDecodeNullable(_$ApiRequestActionEnumMap, json['action']),
  actor: json['actor'] as Map<String, dynamic>?,
  requestId: json['requestId'] as String?,
  resource: json['resource'] as Map<String, dynamic>?,
  result: $enumDecodeNullable(_$ApiRequestResultEnumMap, json['result']),
  timestamp: json['timestamp'] == null
      ? null
      : DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$ApiRequestToJson(ApiRequest instance) =>
    <String, dynamic>{
      'action': _$ApiRequestActionEnumMap[instance.action],
      'actor': instance.actor,
      'requestId': instance.requestId,
      'resource': instance.resource,
      'result': _$ApiRequestResultEnumMap[instance.result],
      'timestamp': instance.timestamp?.toIso8601String(),
    };

const _$ApiRequestActionEnumMap = {
  ApiRequestAction.read: 'READ',
  ApiRequestAction.create: 'CREATE',
  ApiRequestAction.update: 'UPDATE',
  ApiRequestAction.delete: 'DELETE',
};

const _$ApiRequestResultEnumMap = {
  ApiRequestResult.success: 'SUCCESS',
  ApiRequestResult.deny: 'DENY',
};

ErrorResponse _$ErrorResponseFromJson(Map<String, dynamic> json) =>
    ErrorResponse(
      message: json['message'] as String?,
      status: (json['status'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ErrorResponseToJson(ErrorResponse instance) =>
    <String, dynamic>{'message': instance.message, 'status': instance.status};

FieldModel _$FieldModelFromJson(Map<String, dynamic> json) => FieldModel(
  entropy: (json['entropy'] as num?)?.toDouble(),
  generate: json['generate'] as bool? ?? false,
  id: json['id'] as String,
  label: json['label'] as String?,
  purpose: $enumDecodeNullable(_$FieldPurposeEnumMap, json['purpose']),
  recipe: json['recipe'] == null
      ? null
      : GeneratorRecipe.fromJson(json['recipe'] as Map<String, dynamic>),
  section: json['section'] as Map<String, dynamic>?,
  type:
      $enumDecodeNullable(_$FieldTypeEnumMap, json['type']) ?? FieldType.string,
  value: json['value'] as String?,
);

Map<String, dynamic> _$FieldModelToJson(FieldModel instance) =>
    <String, dynamic>{
      'entropy': instance.entropy,
      'generate': instance.generate,
      'id': instance.id,
      'label': instance.label,
      'purpose': _$FieldPurposeEnumMap[instance.purpose],
      'recipe': instance.recipe,
      'section': instance.section,
      'type': _$FieldTypeEnumMap[instance.type]!,
      'value': instance.value,
    };

const _$FieldPurposeEnumMap = {
  FieldPurpose.empty: '',
  FieldPurpose.username: 'USERNAME',
  FieldPurpose.password: 'PASSWORD',
  FieldPurpose.notes: 'NOTES',
};

const _$FieldTypeEnumMap = {
  FieldType.string: 'STRING',
  FieldType.email: 'EMAIL',
  FieldType.concealed: 'CONCEALED',
  FieldType.url: 'URL',
  FieldType.totp: 'TOTP',
  FieldType.date: 'DATE',
  FieldType.monthYear: 'MONTH_YEAR',
  FieldType.menu: 'MENU',
};

File _$FileFromJson(Map<String, dynamic> json) => File(
  content: json['content'] as String?,
  contentPath: json['content_path'] as String?,
  id: json['id'] as String?,
  name: json['name'] as String?,
  section: json['section'] as Map<String, dynamic>?,
  size: (json['size'] as num?)?.toInt(),
);

Map<String, dynamic> _$FileToJson(File instance) => <String, dynamic>{
  'content': instance.content,
  'content_path': instance.contentPath,
  'id': instance.id,
  'name': instance.name,
  'section': instance.section,
  'size': instance.size,
};

FullItem _$FullItemFromJson(Map<String, dynamic> json) => FullItem(
  category: $enumDecode(_$FullItemCategoryEnumMap, json['category']),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  favorite: json['favorite'] as bool? ?? false,
  id: json['id'] as String?,
  lastEditedBy: json['lastEditedBy'] as String?,
  state: $enumDecodeNullable(_$FullItemStateEnumMap, json['state']),
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
  title: json['title'] as String?,
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  urls: (json['urls'] as List<dynamic>?)
      ?.map((e) => e as Map<String, dynamic>)
      .toList(),
  vault: json['vault'] as Map<String, dynamic>,
  version: (json['version'] as num?)?.toInt(),
  fields: (json['fields'] as List<dynamic>?)
      ?.map((e) => FieldModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  files: (json['files'] as List<dynamic>?)
      ?.map((e) => File.fromJson(e as Map<String, dynamic>))
      .toList(),
  sections: (json['sections'] as List<dynamic>?)
      ?.map((e) => e as Map<String, dynamic>)
      .toList(),
);

Map<String, dynamic> _$FullItemToJson(FullItem instance) => <String, dynamic>{
  'category': _$FullItemCategoryEnumMap[instance.category]!,
  'createdAt': instance.createdAt?.toIso8601String(),
  'favorite': instance.favorite,
  'id': instance.id,
  'lastEditedBy': instance.lastEditedBy,
  'state': _$FullItemStateEnumMap[instance.state],
  'tags': instance.tags,
  'title': instance.title,
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'urls': instance.urls,
  'vault': instance.vault,
  'version': instance.version,
  'fields': instance.fields,
  'files': instance.files,
  'sections': instance.sections,
};

const _$FullItemCategoryEnumMap = {
  FullItemCategory.login: 'LOGIN',
  FullItemCategory.password: 'PASSWORD',
  FullItemCategory.apiCredential: 'API_CREDENTIAL',
  FullItemCategory.server: 'SERVER',
  FullItemCategory.database: 'DATABASE',
  FullItemCategory.creditCard: 'CREDIT_CARD',
  FullItemCategory.membership: 'MEMBERSHIP',
  FullItemCategory.passport: 'PASSPORT',
  FullItemCategory.softwareLicense: 'SOFTWARE_LICENSE',
  FullItemCategory.outdoorLicense: 'OUTDOOR_LICENSE',
  FullItemCategory.secureNote: 'SECURE_NOTE',
  FullItemCategory.wirelessRouter: 'WIRELESS_ROUTER',
  FullItemCategory.bankAccount: 'BANK_ACCOUNT',
  FullItemCategory.driverLicense: 'DRIVER_LICENSE',
  FullItemCategory.identity: 'IDENTITY',
  FullItemCategory.rewardProgram: 'REWARD_PROGRAM',
  FullItemCategory.document: 'DOCUMENT',
  FullItemCategory.emailAccount: 'EMAIL_ACCOUNT',
  FullItemCategory.socialSecurityNumber: 'SOCIAL_SECURITY_NUMBER',
  FullItemCategory.medicalRecord: 'MEDICAL_RECORD',
  FullItemCategory.sshKey: 'SSH_KEY',
  FullItemCategory.custom: 'CUSTOM',
};

const _$FullItemStateEnumMap = {
  FullItemState.archived: 'ARCHIVED',
  FullItemState.deleted: 'DELETED',
};

GeneratorRecipe _$GeneratorRecipeFromJson(Map<String, dynamic> json) =>
    GeneratorRecipe(
      characterSets: (json['characterSets'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      excludeCharacters: json['excludeCharacters'] as String?,
      length: (json['length'] as num?)?.toInt() ?? 32,
    );

Map<String, dynamic> _$GeneratorRecipeToJson(GeneratorRecipe instance) =>
    <String, dynamic>{
      'characterSets': instance.characterSets,
      'excludeCharacters': instance.excludeCharacters,
      'length': instance.length,
    };

Item _$ItemFromJson(Map<String, dynamic> json) => Item(
  category: $enumDecode(_$ItemCategoryEnumMap, json['category']),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  favorite: json['favorite'] as bool? ?? false,
  id: json['id'] as String?,
  lastEditedBy: json['lastEditedBy'] as String?,
  state: $enumDecodeNullable(_$ItemStateEnumMap, json['state']),
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
  title: json['title'] as String?,
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  urls: (json['urls'] as List<dynamic>?)
      ?.map((e) => e as Map<String, dynamic>)
      .toList(),
  vault: json['vault'] as Map<String, dynamic>,
  version: (json['version'] as num?)?.toInt(),
);

Map<String, dynamic> _$ItemToJson(Item instance) => <String, dynamic>{
  'category': _$ItemCategoryEnumMap[instance.category]!,
  'createdAt': instance.createdAt?.toIso8601String(),
  'favorite': instance.favorite,
  'id': instance.id,
  'lastEditedBy': instance.lastEditedBy,
  'state': _$ItemStateEnumMap[instance.state],
  'tags': instance.tags,
  'title': instance.title,
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'urls': instance.urls,
  'vault': instance.vault,
  'version': instance.version,
};

const _$ItemCategoryEnumMap = {
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
};

const _$ItemStateEnumMap = {
  ItemState.archived: 'ARCHIVED',
  ItemState.deleted: 'DELETED',
};

ServiceDependency _$ServiceDependencyFromJson(Map<String, dynamic> json) =>
    ServiceDependency(
      message: json['message'] as String?,
      service: json['service'] as String?,
      status: json['status'] as String?,
    );

Map<String, dynamic> _$ServiceDependencyToJson(ServiceDependency instance) =>
    <String, dynamic>{
      'message': instance.message,
      'service': instance.service,
      'status': instance.status,
    };

Vault _$VaultFromJson(Map<String, dynamic> json) => Vault(
  attributeVersion: (json['attributeVersion'] as num?)?.toInt(),
  contentVersion: (json['contentVersion'] as num?)?.toInt(),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  description: json['description'] as String?,
  id: json['id'] as String?,
  items: (json['items'] as num?)?.toInt(),
  name: json['name'] as String?,
  type: $enumDecodeNullable(_$VaultTypeEnumMap, json['type']),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$VaultToJson(Vault instance) => <String, dynamic>{
  'attributeVersion': instance.attributeVersion,
  'contentVersion': instance.contentVersion,
  'createdAt': instance.createdAt?.toIso8601String(),
  'description': instance.description,
  'id': instance.id,
  'items': instance.items,
  'name': instance.name,
  'type': _$VaultTypeEnumMap[instance.type],
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

const _$VaultTypeEnumMap = {
  VaultType.userCreated: 'USER_CREATED',
  VaultType.personal: 'PERSONAL',
  VaultType.everyone: 'EVERYONE',
  VaultType.transfer: 'TRANSFER',
};
