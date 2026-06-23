// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:json_annotation/json_annotation.dart';
import 'newapi.enums.dart';

part 'newapi.models.g.dart';

@JsonSerializable()
class ApiRequest {
  final ApiRequestAction? action;
  final ApiRequestActor? actor;
  final String? requestId;
  final ApiRequestResource? resource;
  final ApiRequestResult? result;
  final DateTime? timestamp;

  ApiRequest({
    this.action,
    this.actor,
    this.requestId,
    this.resource,
    this.result,
    this.timestamp,
  });

  factory ApiRequest.fromJson(Map<String, dynamic> json) =>
      _$ApiRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ApiRequestToJson(this);
}

@JsonSerializable()
class ErrorResponse {
  final String? message;
  final int? status;

  ErrorResponse({
    this.message,
    this.status,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$ErrorResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ErrorResponseToJson(this);
}

@JsonSerializable()
class FieldModel {
  final double? entropy;
  final bool generate;
  final String id;
  final String? label;
  final FieldPurpose? purpose;
  final GeneratorRecipe? recipe;
  final FieldSection? section;
  final FieldType type;
  final String? value;

  FieldModel({
    this.entropy,
    this.generate = false,
    required this.id,
    this.label,
    this.purpose,
    this.recipe,
    this.section,
    this.type = FieldType.string,
    this.value,
  });

  factory FieldModel.fromJson(Map<String, dynamic> json) =>
      _$FieldModelFromJson(json);

  Map<String, dynamic> toJson() => _$FieldModelToJson(this);
}

@JsonSerializable()
class File {
  final String? content;
  @JsonKey(name: 'content_path')
  final String? contentPath;
  final String? id;
  final String? name;
  final FileSection? section;
  final int? size;

  File({
    this.content,
    this.contentPath,
    this.id,
    this.name,
    this.section,
    this.size,
  });

  factory File.fromJson(Map<String, dynamic> json) =>
      _$FileFromJson(json);

  Map<String, dynamic> toJson() => _$FileToJson(this);
}

@JsonSerializable()
class FullItem {
  final ItemCategory category;
  final DateTime? createdAt;
  final bool favorite;
  final String? id;
  final String? lastEditedBy;
  final ItemState? state;
  final List<String>? tags;
  final String? title;
  final DateTime? updatedAt;
  final List<ItemUrlsItem>? urls;
  final ItemVault vault;
  final int? version;
  final List<FieldModel>? fields;
  final List<File>? files;
  final List<FullItemSectionsItem>? sections;

  FullItem({
    required this.category,
    this.createdAt,
    this.favorite = false,
    this.id,
    this.lastEditedBy,
    this.state,
    this.tags,
    this.title,
    this.updatedAt,
    this.urls,
    required this.vault,
    this.version,
    this.fields,
    this.files,
    this.sections,
  });

  factory FullItem.fromJson(Map<String, dynamic> json) =>
      _$FullItemFromJson(json);

  Map<String, dynamic> toJson() => _$FullItemToJson(this);
}

@JsonSerializable()
class GeneratorRecipe {
  final List<GeneratorRecipeCharacterSetsItem>? characterSets;
  final String? excludeCharacters;
  final int length;

  GeneratorRecipe({
    this.characterSets,
    this.excludeCharacters,
    this.length = 32,
  });

  factory GeneratorRecipe.fromJson(Map<String, dynamic> json) =>
      _$GeneratorRecipeFromJson(json);

  Map<String, dynamic> toJson() => _$GeneratorRecipeToJson(this);
}

@JsonSerializable()
class Item {
  final ItemCategory category;
  final DateTime? createdAt;
  final bool favorite;
  final String? id;
  final String? lastEditedBy;
  final ItemState? state;
  final List<String>? tags;
  final String? title;
  final DateTime? updatedAt;
  final List<ItemUrlsItem>? urls;
  final ItemVault vault;
  final int? version;

  Item({
    required this.category,
    this.createdAt,
    this.favorite = false,
    this.id,
    this.lastEditedBy,
    this.state,
    this.tags,
    this.title,
    this.updatedAt,
    this.urls,
    required this.vault,
    this.version,
  });

  factory Item.fromJson(Map<String, dynamic> json) =>
      _$ItemFromJson(json);

  Map<String, dynamic> toJson() => _$ItemToJson(this);
}

@JsonSerializable()
class ServiceDependency {
  final String? message;
  final String? service;
  final String? status;

  ServiceDependency({
    this.message,
    this.service,
    this.status,
  });

  factory ServiceDependency.fromJson(Map<String, dynamic> json) =>
      _$ServiceDependencyFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceDependencyToJson(this);
}

@JsonSerializable()
class Vault {
  final int? attributeVersion;
  final int? contentVersion;
  final DateTime? createdAt;
  final String? description;
  final String? id;
  final int? items;
  final String? name;
  final VaultType? type;
  final DateTime? updatedAt;

  Vault({
    this.attributeVersion,
    this.contentVersion,
    this.createdAt,
    this.description,
    this.id,
    this.items,
    this.name,
    this.type,
    this.updatedAt,
  });

  factory Vault.fromJson(Map<String, dynamic> json) =>
      _$VaultFromJson(json);

  Map<String, dynamic> toJson() => _$VaultToJson(this);
}

@JsonSerializable()
class ApiRequestActor {
  final String? account;
  final String? id;
  final String? jti;
  final String? requestIp;
  final String? userAgent;

  ApiRequestActor({
    this.account,
    this.id,
    this.jti,
    this.requestIp,
    this.userAgent,
  });

  factory ApiRequestActor.fromJson(Map<String, dynamic> json) =>
      _$ApiRequestActorFromJson(json);

  Map<String, dynamic> toJson() => _$ApiRequestActorToJson(this);
}

@JsonSerializable()
class ApiRequestResourceItem {
  final String? id;

  ApiRequestResourceItem({
    this.id,
  });

  factory ApiRequestResourceItem.fromJson(Map<String, dynamic> json) =>
      _$ApiRequestResourceItemFromJson(json);

  Map<String, dynamic> toJson() => _$ApiRequestResourceItemToJson(this);
}

@JsonSerializable()
class ApiRequestResourceVault {
  final String? id;

  ApiRequestResourceVault({
    this.id,
  });

  factory ApiRequestResourceVault.fromJson(Map<String, dynamic> json) =>
      _$ApiRequestResourceVaultFromJson(json);

  Map<String, dynamic> toJson() => _$ApiRequestResourceVaultToJson(this);
}

@JsonSerializable()
class ApiRequestResource {
  final ApiRequestResourceItem? item;
  final int? itemVersion;
  final ApiRequestResourceType? type;
  final ApiRequestResourceVault? vault;

  ApiRequestResource({
    this.item,
    this.itemVersion,
    this.type,
    this.vault,
  });

  factory ApiRequestResource.fromJson(Map<String, dynamic> json) =>
      _$ApiRequestResourceFromJson(json);

  Map<String, dynamic> toJson() => _$ApiRequestResourceToJson(this);
}

@JsonSerializable()
class FieldSection {
  final String? id;

  FieldSection({
    this.id,
  });

  factory FieldSection.fromJson(Map<String, dynamic> json) =>
      _$FieldSectionFromJson(json);

  Map<String, dynamic> toJson() => _$FieldSectionToJson(this);
}

@JsonSerializable()
class FileSection {
  final String? id;

  FileSection({
    this.id,
  });

  factory FileSection.fromJson(Map<String, dynamic> json) =>
      _$FileSectionFromJson(json);

  Map<String, dynamic> toJson() => _$FileSectionToJson(this);
}

@JsonSerializable()
class FullItemSectionsItem {
  final String? id;
  final String? label;

  FullItemSectionsItem({
    this.id,
    this.label,
  });

  factory FullItemSectionsItem.fromJson(Map<String, dynamic> json) =>
      _$FullItemSectionsItemFromJson(json);

  Map<String, dynamic> toJson() => _$FullItemSectionsItemToJson(this);
}

@JsonSerializable()
class ItemUrlsItem {
  final String href;
  final String? label;
  final bool? primary;

  ItemUrlsItem({
    required this.href,
    this.label,
    this.primary,
  });

  factory ItemUrlsItem.fromJson(Map<String, dynamic> json) =>
      _$ItemUrlsItemFromJson(json);

  Map<String, dynamic> toJson() => _$ItemUrlsItemToJson(this);
}

@JsonSerializable()
class ItemVault {
  final String id;

  ItemVault({
    required this.id,
  });

  factory ItemVault.fromJson(Map<String, dynamic> json) =>
      _$ItemVaultFromJson(json);

  Map<String, dynamic> toJson() => _$ItemVaultToJson(this);
}

@JsonSerializable()
class PatchItem {
  final PatchItemOp op;
  final String path;
  final Map<String, dynamic>? value;

  PatchItem({
    required this.op,
    required this.path,
    this.value,
  });

  factory PatchItem.fromJson(Map<String, dynamic> json) =>
      _$PatchItemFromJson(json);

  Map<String, dynamic> toJson() => _$PatchItemToJson(this);
}

@JsonSerializable()
class GetServerHealthResponse {
  final List<ServiceDependency>? dependencies;
  final String name;
  final String version;

  GetServerHealthResponse({
    this.dependencies,
    required this.name,
    required this.version,
  });

  factory GetServerHealthResponse.fromJson(Map<String, dynamic> json) =>
      _$GetServerHealthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GetServerHealthResponseToJson(this);
}

