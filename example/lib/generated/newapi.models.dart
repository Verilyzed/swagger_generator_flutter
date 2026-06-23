// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:json_annotation/json_annotation.dart';
import 'newapi.enums.dart';

part 'newapi.models.g.dart';

@JsonSerializable()
class ApiRequest {
  final ApiRequestAction? action;
  final Map<String, dynamic>? actor;
  final String? requestId;
  final Map<String, dynamic>? resource;
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
  final Map<String, dynamic>? section;
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
  final Map<String, dynamic>? section;
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
  final FullItemCategory category;
  final DateTime? createdAt;
  final bool favorite;
  final String? id;
  final String? lastEditedBy;
  final FullItemState? state;
  final List<String>? tags;
  final String? title;
  final DateTime? updatedAt;
  final List<Map<String, dynamic>>? urls;
  final Map<String, dynamic> vault;
  final int? version;
  final List<FieldModel>? fields;
  final List<File>? files;
  final List<Map<String, dynamic>>? sections;

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
  final List<String>? characterSets;
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
  final List<Map<String, dynamic>>? urls;
  final Map<String, dynamic> vault;
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

