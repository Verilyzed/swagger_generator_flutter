// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'newapi.models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiRequest _$ApiRequestFromJson(Map<String, dynamic> json) => ApiRequest(
  action: $enumDecodeNullable(
    _$ApiRequestActionEnumMap,
    json['action'],
    unknownValue: ApiRequestAction.$unknown,
  ),
  actor: json['actor'] == null
      ? null
      : ApiRequestActor.fromJson(json['actor'] as Map<String, dynamic>),
  requestId: json['requestId'] as String?,
  resource: json['resource'] == null
      ? null
      : ApiRequestResource.fromJson(json['resource'] as Map<String, dynamic>),
  result: $enumDecodeNullable(
    _$ApiRequestResultEnumMap,
    json['result'],
    unknownValue: ApiRequestResult.$unknown,
  ),
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
  ApiRequestAction.$unknown: r'$unknown',
};

const _$ApiRequestResultEnumMap = {
  ApiRequestResult.success: 'SUCCESS',
  ApiRequestResult.deny: 'DENY',
  ApiRequestResult.$unknown: r'$unknown',
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
  purpose: $enumDecodeNullable(
    _$FieldPurposeEnumMap,
    json['purpose'],
    unknownValue: FieldPurpose.$unknown,
  ),
  recipe: json['recipe'] == null
      ? null
      : GeneratorRecipe.fromJson(json['recipe'] as Map<String, dynamic>),
  section: json['section'] == null
      ? null
      : FieldSection.fromJson(json['section'] as Map<String, dynamic>),
  type:
      $enumDecodeNullable(
        _$FieldTypeEnumMap,
        json['type'],
        unknownValue: FieldType.$unknown,
      ) ??
      FieldType.string,
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
  FieldPurpose.$unknown: r'$unknown',
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
  FieldType.$unknown: r'$unknown',
};

File _$FileFromJson(Map<String, dynamic> json) => File(
  content: json['content'] as String?,
  contentPath: json['content_path'] as String?,
  id: json['id'] as String?,
  name: json['name'] as String?,
  section: json['section'] == null
      ? null
      : FileSection.fromJson(json['section'] as Map<String, dynamic>),
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
  category: $enumDecode(
    _$ItemCategoryEnumMap,
    json['category'],
    unknownValue: ItemCategory.$unknown,
  ),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  favorite: json['favorite'] as bool? ?? false,
  id: json['id'] as String?,
  lastEditedBy: json['lastEditedBy'] as String?,
  state: $enumDecodeNullable(
    _$ItemStateEnumMap,
    json['state'],
    unknownValue: ItemState.$unknown,
  ),
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
  title: json['title'] as String?,
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  urls: (json['urls'] as List<dynamic>?)
      ?.map((e) => ItemUrlsItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  vault: ItemVault.fromJson(json['vault'] as Map<String, dynamic>),
  version: (json['version'] as num?)?.toInt(),
  fields: (json['fields'] as List<dynamic>?)
      ?.map((e) => FieldModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  files: (json['files'] as List<dynamic>?)
      ?.map((e) => File.fromJson(e as Map<String, dynamic>))
      .toList(),
  sections: (json['sections'] as List<dynamic>?)
      ?.map((e) => FullItemSectionsItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$FullItemToJson(FullItem instance) => <String, dynamic>{
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
  'fields': instance.fields,
  'files': instance.files,
  'sections': instance.sections,
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
  ItemCategory.$unknown: r'$unknown',
};

const _$ItemStateEnumMap = {
  ItemState.archived: 'ARCHIVED',
  ItemState.deleted: 'DELETED',
  ItemState.$unknown: r'$unknown',
};

GeneratorRecipe _$GeneratorRecipeFromJson(Map<String, dynamic> json) =>
    GeneratorRecipe(
      characterSets: (json['characterSets'] as List<dynamic>?)
          ?.map(
            (e) => $enumDecode(
              _$GeneratorRecipeCharacterSetsItemEnumMap,
              e,
              unknownValue: GeneratorRecipeCharacterSetsItem.$unknown,
            ),
          )
          .toList(),
      excludeCharacters: json['excludeCharacters'] as String?,
      length: (json['length'] as num?)?.toInt() ?? 32,
    );

Map<String, dynamic> _$GeneratorRecipeToJson(GeneratorRecipe instance) =>
    <String, dynamic>{
      'characterSets': instance.characterSets
          ?.map((e) => _$GeneratorRecipeCharacterSetsItemEnumMap[e]!)
          .toList(),
      'excludeCharacters': instance.excludeCharacters,
      'length': instance.length,
    };

const _$GeneratorRecipeCharacterSetsItemEnumMap = {
  GeneratorRecipeCharacterSetsItem.letters: 'LETTERS',
  GeneratorRecipeCharacterSetsItem.digits: 'DIGITS',
  GeneratorRecipeCharacterSetsItem.symbols: 'SYMBOLS',
  GeneratorRecipeCharacterSetsItem.$unknown: r'$unknown',
};

Item _$ItemFromJson(Map<String, dynamic> json) => Item(
  category: $enumDecode(
    _$ItemCategoryEnumMap,
    json['category'],
    unknownValue: ItemCategory.$unknown,
  ),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  favorite: json['favorite'] as bool? ?? false,
  id: json['id'] as String?,
  lastEditedBy: json['lastEditedBy'] as String?,
  state: $enumDecodeNullable(
    _$ItemStateEnumMap,
    json['state'],
    unknownValue: ItemState.$unknown,
  ),
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
  title: json['title'] as String?,
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  urls: (json['urls'] as List<dynamic>?)
      ?.map((e) => ItemUrlsItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  vault: ItemVault.fromJson(json['vault'] as Map<String, dynamic>),
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
  type: $enumDecodeNullable(
    _$VaultTypeEnumMap,
    json['type'],
    unknownValue: VaultType.$unknown,
  ),
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
  VaultType.$unknown: r'$unknown',
};

ApiRequestActor _$ApiRequestActorFromJson(Map<String, dynamic> json) =>
    ApiRequestActor(
      account: json['account'] as String?,
      id: json['id'] as String?,
      jti: json['jti'] as String?,
      requestIp: json['requestIp'] as String?,
      userAgent: json['userAgent'] as String?,
    );

Map<String, dynamic> _$ApiRequestActorToJson(ApiRequestActor instance) =>
    <String, dynamic>{
      'account': instance.account,
      'id': instance.id,
      'jti': instance.jti,
      'requestIp': instance.requestIp,
      'userAgent': instance.userAgent,
    };

ApiRequestResourceItem _$ApiRequestResourceItemFromJson(
  Map<String, dynamic> json,
) => ApiRequestResourceItem(id: json['id'] as String?);

Map<String, dynamic> _$ApiRequestResourceItemToJson(
  ApiRequestResourceItem instance,
) => <String, dynamic>{'id': instance.id};

ApiRequestResourceVault _$ApiRequestResourceVaultFromJson(
  Map<String, dynamic> json,
) => ApiRequestResourceVault(id: json['id'] as String?);

Map<String, dynamic> _$ApiRequestResourceVaultToJson(
  ApiRequestResourceVault instance,
) => <String, dynamic>{'id': instance.id};

ApiRequestResource _$ApiRequestResourceFromJson(
  Map<String, dynamic> json,
) => ApiRequestResource(
  item: json['item'] == null
      ? null
      : ApiRequestResourceItem.fromJson(json['item'] as Map<String, dynamic>),
  itemVersion: (json['itemVersion'] as num?)?.toInt(),
  type: $enumDecodeNullable(
    _$ApiRequestResourceTypeEnumMap,
    json['type'],
    unknownValue: ApiRequestResourceType.$unknown,
  ),
  vault: json['vault'] == null
      ? null
      : ApiRequestResourceVault.fromJson(json['vault'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ApiRequestResourceToJson(ApiRequestResource instance) =>
    <String, dynamic>{
      'item': instance.item,
      'itemVersion': instance.itemVersion,
      'type': _$ApiRequestResourceTypeEnumMap[instance.type],
      'vault': instance.vault,
    };

const _$ApiRequestResourceTypeEnumMap = {
  ApiRequestResourceType.item: 'ITEM',
  ApiRequestResourceType.vault: 'VAULT',
  ApiRequestResourceType.$unknown: r'$unknown',
};

FieldSection _$FieldSectionFromJson(Map<String, dynamic> json) =>
    FieldSection(id: json['id'] as String?);

Map<String, dynamic> _$FieldSectionToJson(FieldSection instance) =>
    <String, dynamic>{'id': instance.id};

FileSection _$FileSectionFromJson(Map<String, dynamic> json) =>
    FileSection(id: json['id'] as String?);

Map<String, dynamic> _$FileSectionToJson(FileSection instance) =>
    <String, dynamic>{'id': instance.id};

FullItemSectionsItem _$FullItemSectionsItemFromJson(
  Map<String, dynamic> json,
) => FullItemSectionsItem(
  id: json['id'] as String?,
  label: json['label'] as String?,
);

Map<String, dynamic> _$FullItemSectionsItemToJson(
  FullItemSectionsItem instance,
) => <String, dynamic>{'id': instance.id, 'label': instance.label};

ItemUrlsItem _$ItemUrlsItemFromJson(Map<String, dynamic> json) => ItemUrlsItem(
  href: json['href'] as String,
  label: json['label'] as String?,
  primary: json['primary'] as bool?,
);

Map<String, dynamic> _$ItemUrlsItemToJson(ItemUrlsItem instance) =>
    <String, dynamic>{
      'href': instance.href,
      'label': instance.label,
      'primary': instance.primary,
    };

ItemVault _$ItemVaultFromJson(Map<String, dynamic> json) =>
    ItemVault(id: json['id'] as String);

Map<String, dynamic> _$ItemVaultToJson(ItemVault instance) => <String, dynamic>{
  'id': instance.id,
};

PatchItem _$PatchItemFromJson(Map<String, dynamic> json) => PatchItem(
  op: $enumDecode(
    _$PatchItemOpEnumMap,
    json['op'],
    unknownValue: PatchItemOp.$unknown,
  ),
  path: json['path'] as String,
  value: json['value'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$PatchItemToJson(PatchItem instance) => <String, dynamic>{
  'op': _$PatchItemOpEnumMap[instance.op]!,
  'path': instance.path,
  'value': instance.value,
};

const _$PatchItemOpEnumMap = {
  PatchItemOp.add: 'add',
  PatchItemOp.remove: 'remove',
  PatchItemOp.replace: 'replace',
  PatchItemOp.$unknown: r'$unknown',
};

GetServerHealthResponse _$GetServerHealthResponseFromJson(
  Map<String, dynamic> json,
) => GetServerHealthResponse(
  dependencies: (json['dependencies'] as List<dynamic>?)
      ?.map((e) => ServiceDependency.fromJson(e as Map<String, dynamic>))
      .toList(),
  name: json['name'] as String,
  version: json['version'] as String,
);

Map<String, dynamic> _$GetServerHealthResponseToJson(
  GetServerHealthResponse instance,
) => <String, dynamic>{
  'dependencies': instance.dependencies,
  'name': instance.name,
  'version': instance.version,
};
