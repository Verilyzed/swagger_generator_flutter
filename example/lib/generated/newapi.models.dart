// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:json_annotation/json_annotation.dart';
import 'newapi.enums.dart';

part 'newapi.models.g.dart';

@JsonSerializable()
class ApiRequest {
  @JsonKey(unknownEnumValue: ApiRequestAction.$unknown)
  final ApiRequestAction? action;
  final ApiRequestActor? actor;
  final String? requestId;
  final ApiRequestResource? resource;
  @JsonKey(unknownEnumValue: ApiRequestResult.$unknown)
  final ApiRequestResult? result;
  final DateTime? timestamp;

  const ApiRequest({
    this.action,
    this.actor,
    this.requestId,
    this.resource,
    this.result,
    this.timestamp,
  });

  ApiRequest copyWith({
    ApiRequestAction? action,
    ApiRequestActor? actor,
    String? requestId,
    ApiRequestResource? resource,
    ApiRequestResult? result,
    DateTime? timestamp,
  }) {
    return ApiRequest(
      action: action ?? this.action,
      actor: actor ?? this.actor,
      requestId: requestId ?? this.requestId,
      resource: resource ?? this.resource,
      result: result ?? this.result,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  factory ApiRequest.fromJson(Map<String, dynamic> json) =>
      _$ApiRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ApiRequestToJson(this);
}

@JsonSerializable()
class ErrorResponse {
  final String? message;
  final int? status;

  const ErrorResponse({
    this.message,
    this.status,
  });

  ErrorResponse copyWith({
    String? message,
    int? status,
  }) {
    return ErrorResponse(
      message: message ?? this.message,
      status: status ?? this.status,
    );
  }

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
  @JsonKey(unknownEnumValue: FieldPurpose.$unknown)
  final FieldPurpose? purpose;
  final GeneratorRecipe? recipe;
  final FieldSection? section;
  @JsonKey(unknownEnumValue: FieldType.$unknown)
  final FieldType type;
  final String? value;

  const FieldModel({
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

  FieldModel copyWith({
    double? entropy,
    bool? generate,
    String? id,
    String? label,
    FieldPurpose? purpose,
    GeneratorRecipe? recipe,
    FieldSection? section,
    FieldType? type,
    String? value,
  }) {
    return FieldModel(
      entropy: entropy ?? this.entropy,
      generate: generate ?? this.generate,
      id: id ?? this.id,
      label: label ?? this.label,
      purpose: purpose ?? this.purpose,
      recipe: recipe ?? this.recipe,
      section: section ?? this.section,
      type: type ?? this.type,
      value: value ?? this.value,
    );
  }

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

  const File({
    this.content,
    this.contentPath,
    this.id,
    this.name,
    this.section,
    this.size,
  });

  File copyWith({
    String? content,
    String? contentPath,
    String? id,
    String? name,
    FileSection? section,
    int? size,
  }) {
    return File(
      content: content ?? this.content,
      contentPath: contentPath ?? this.contentPath,
      id: id ?? this.id,
      name: name ?? this.name,
      section: section ?? this.section,
      size: size ?? this.size,
    );
  }

  factory File.fromJson(Map<String, dynamic> json) =>
      _$FileFromJson(json);

  Map<String, dynamic> toJson() => _$FileToJson(this);
}

@JsonSerializable()
class FullItem {
  @JsonKey(unknownEnumValue: ItemCategory.$unknown)
  final ItemCategory category;
  final DateTime? createdAt;
  final bool favorite;
  final String? id;
  final String? lastEditedBy;
  @JsonKey(unknownEnumValue: ItemState.$unknown)
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

  const FullItem({
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

  FullItem copyWith({
    ItemCategory? category,
    DateTime? createdAt,
    bool? favorite,
    String? id,
    String? lastEditedBy,
    ItemState? state,
    List<String>? tags,
    String? title,
    DateTime? updatedAt,
    List<ItemUrlsItem>? urls,
    ItemVault? vault,
    int? version,
    List<FieldModel>? fields,
    List<File>? files,
    List<FullItemSectionsItem>? sections,
  }) {
    return FullItem(
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      favorite: favorite ?? this.favorite,
      id: id ?? this.id,
      lastEditedBy: lastEditedBy ?? this.lastEditedBy,
      state: state ?? this.state,
      tags: tags ?? this.tags,
      title: title ?? this.title,
      updatedAt: updatedAt ?? this.updatedAt,
      urls: urls ?? this.urls,
      vault: vault ?? this.vault,
      version: version ?? this.version,
      fields: fields ?? this.fields,
      files: files ?? this.files,
      sections: sections ?? this.sections,
    );
  }

  factory FullItem.fromJson(Map<String, dynamic> json) =>
      _$FullItemFromJson(json);

  Map<String, dynamic> toJson() => _$FullItemToJson(this);
}

@JsonSerializable()
class GeneratorRecipe {
  @JsonKey(unknownEnumValue: GeneratorRecipeCharacterSetsItem.$unknown)
  final List<GeneratorRecipeCharacterSetsItem>? characterSets;
  final String? excludeCharacters;
  final int length;

  const GeneratorRecipe({
    this.characterSets,
    this.excludeCharacters,
    this.length = 32,
  });

  GeneratorRecipe copyWith({
    List<GeneratorRecipeCharacterSetsItem>? characterSets,
    String? excludeCharacters,
    int? length,
  }) {
    return GeneratorRecipe(
      characterSets: characterSets ?? this.characterSets,
      excludeCharacters: excludeCharacters ?? this.excludeCharacters,
      length: length ?? this.length,
    );
  }

  factory GeneratorRecipe.fromJson(Map<String, dynamic> json) =>
      _$GeneratorRecipeFromJson(json);

  Map<String, dynamic> toJson() => _$GeneratorRecipeToJson(this);
}

@JsonSerializable()
class Item {
  @JsonKey(unknownEnumValue: ItemCategory.$unknown)
  final ItemCategory category;
  final DateTime? createdAt;
  final bool favorite;
  final String? id;
  final String? lastEditedBy;
  @JsonKey(unknownEnumValue: ItemState.$unknown)
  final ItemState? state;
  final List<String>? tags;
  final String? title;
  final DateTime? updatedAt;
  final List<ItemUrlsItem>? urls;
  final ItemVault vault;
  final int? version;

  const Item({
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

  Item copyWith({
    ItemCategory? category,
    DateTime? createdAt,
    bool? favorite,
    String? id,
    String? lastEditedBy,
    ItemState? state,
    List<String>? tags,
    String? title,
    DateTime? updatedAt,
    List<ItemUrlsItem>? urls,
    ItemVault? vault,
    int? version,
  }) {
    return Item(
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      favorite: favorite ?? this.favorite,
      id: id ?? this.id,
      lastEditedBy: lastEditedBy ?? this.lastEditedBy,
      state: state ?? this.state,
      tags: tags ?? this.tags,
      title: title ?? this.title,
      updatedAt: updatedAt ?? this.updatedAt,
      urls: urls ?? this.urls,
      vault: vault ?? this.vault,
      version: version ?? this.version,
    );
  }

  factory Item.fromJson(Map<String, dynamic> json) =>
      _$ItemFromJson(json);

  Map<String, dynamic> toJson() => _$ItemToJson(this);
}

@JsonSerializable()
class ServiceDependency {
  final String? message;
  final String? service;
  final String? status;

  const ServiceDependency({
    this.message,
    this.service,
    this.status,
  });

  ServiceDependency copyWith({
    String? message,
    String? service,
    String? status,
  }) {
    return ServiceDependency(
      message: message ?? this.message,
      service: service ?? this.service,
      status: status ?? this.status,
    );
  }

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
  @JsonKey(unknownEnumValue: VaultType.$unknown)
  final VaultType? type;
  final DateTime? updatedAt;

  const Vault({
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

  Vault copyWith({
    int? attributeVersion,
    int? contentVersion,
    DateTime? createdAt,
    String? description,
    String? id,
    int? items,
    String? name,
    VaultType? type,
    DateTime? updatedAt,
  }) {
    return Vault(
      attributeVersion: attributeVersion ?? this.attributeVersion,
      contentVersion: contentVersion ?? this.contentVersion,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      id: id ?? this.id,
      items: items ?? this.items,
      name: name ?? this.name,
      type: type ?? this.type,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

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

  const ApiRequestActor({
    this.account,
    this.id,
    this.jti,
    this.requestIp,
    this.userAgent,
  });

  ApiRequestActor copyWith({
    String? account,
    String? id,
    String? jti,
    String? requestIp,
    String? userAgent,
  }) {
    return ApiRequestActor(
      account: account ?? this.account,
      id: id ?? this.id,
      jti: jti ?? this.jti,
      requestIp: requestIp ?? this.requestIp,
      userAgent: userAgent ?? this.userAgent,
    );
  }

  factory ApiRequestActor.fromJson(Map<String, dynamic> json) =>
      _$ApiRequestActorFromJson(json);

  Map<String, dynamic> toJson() => _$ApiRequestActorToJson(this);
}

@JsonSerializable()
class ApiRequestResourceItem {
  final String? id;

  const ApiRequestResourceItem({
    this.id,
  });

  ApiRequestResourceItem copyWith({
    String? id,
  }) {
    return ApiRequestResourceItem(
      id: id ?? this.id,
    );
  }

  factory ApiRequestResourceItem.fromJson(Map<String, dynamic> json) =>
      _$ApiRequestResourceItemFromJson(json);

  Map<String, dynamic> toJson() => _$ApiRequestResourceItemToJson(this);
}

@JsonSerializable()
class ApiRequestResourceVault {
  final String? id;

  const ApiRequestResourceVault({
    this.id,
  });

  ApiRequestResourceVault copyWith({
    String? id,
  }) {
    return ApiRequestResourceVault(
      id: id ?? this.id,
    );
  }

  factory ApiRequestResourceVault.fromJson(Map<String, dynamic> json) =>
      _$ApiRequestResourceVaultFromJson(json);

  Map<String, dynamic> toJson() => _$ApiRequestResourceVaultToJson(this);
}

@JsonSerializable()
class ApiRequestResource {
  final ApiRequestResourceItem? item;
  final int? itemVersion;
  @JsonKey(unknownEnumValue: ApiRequestResourceType.$unknown)
  final ApiRequestResourceType? type;
  final ApiRequestResourceVault? vault;

  const ApiRequestResource({
    this.item,
    this.itemVersion,
    this.type,
    this.vault,
  });

  ApiRequestResource copyWith({
    ApiRequestResourceItem? item,
    int? itemVersion,
    ApiRequestResourceType? type,
    ApiRequestResourceVault? vault,
  }) {
    return ApiRequestResource(
      item: item ?? this.item,
      itemVersion: itemVersion ?? this.itemVersion,
      type: type ?? this.type,
      vault: vault ?? this.vault,
    );
  }

  factory ApiRequestResource.fromJson(Map<String, dynamic> json) =>
      _$ApiRequestResourceFromJson(json);

  Map<String, dynamic> toJson() => _$ApiRequestResourceToJson(this);
}

@JsonSerializable()
class FieldSection {
  final String? id;

  const FieldSection({
    this.id,
  });

  FieldSection copyWith({
    String? id,
  }) {
    return FieldSection(
      id: id ?? this.id,
    );
  }

  factory FieldSection.fromJson(Map<String, dynamic> json) =>
      _$FieldSectionFromJson(json);

  Map<String, dynamic> toJson() => _$FieldSectionToJson(this);
}

@JsonSerializable()
class FileSection {
  final String? id;

  const FileSection({
    this.id,
  });

  FileSection copyWith({
    String? id,
  }) {
    return FileSection(
      id: id ?? this.id,
    );
  }

  factory FileSection.fromJson(Map<String, dynamic> json) =>
      _$FileSectionFromJson(json);

  Map<String, dynamic> toJson() => _$FileSectionToJson(this);
}

@JsonSerializable()
class FullItemSectionsItem {
  final String? id;
  final String? label;

  const FullItemSectionsItem({
    this.id,
    this.label,
  });

  FullItemSectionsItem copyWith({
    String? id,
    String? label,
  }) {
    return FullItemSectionsItem(
      id: id ?? this.id,
      label: label ?? this.label,
    );
  }

  factory FullItemSectionsItem.fromJson(Map<String, dynamic> json) =>
      _$FullItemSectionsItemFromJson(json);

  Map<String, dynamic> toJson() => _$FullItemSectionsItemToJson(this);
}

@JsonSerializable()
class ItemUrlsItem {
  final String href;
  final String? label;
  final bool? primary;

  const ItemUrlsItem({
    required this.href,
    this.label,
    this.primary,
  });

  ItemUrlsItem copyWith({
    String? href,
    String? label,
    bool? primary,
  }) {
    return ItemUrlsItem(
      href: href ?? this.href,
      label: label ?? this.label,
      primary: primary ?? this.primary,
    );
  }

  factory ItemUrlsItem.fromJson(Map<String, dynamic> json) =>
      _$ItemUrlsItemFromJson(json);

  Map<String, dynamic> toJson() => _$ItemUrlsItemToJson(this);
}

@JsonSerializable()
class ItemVault {
  final String id;

  const ItemVault({
    required this.id,
  });

  ItemVault copyWith({
    String? id,
  }) {
    return ItemVault(
      id: id ?? this.id,
    );
  }

  factory ItemVault.fromJson(Map<String, dynamic> json) =>
      _$ItemVaultFromJson(json);

  Map<String, dynamic> toJson() => _$ItemVaultToJson(this);
}

@JsonSerializable()
class PatchItem {
  @JsonKey(unknownEnumValue: PatchItemOp.$unknown)
  final PatchItemOp op;
  final String path;
  final Map<String, dynamic>? value;

  const PatchItem({
    required this.op,
    required this.path,
    this.value,
  });

  PatchItem copyWith({
    PatchItemOp? op,
    String? path,
    Map<String, dynamic>? value,
  }) {
    return PatchItem(
      op: op ?? this.op,
      path: path ?? this.path,
      value: value ?? this.value,
    );
  }

  factory PatchItem.fromJson(Map<String, dynamic> json) =>
      _$PatchItemFromJson(json);

  Map<String, dynamic> toJson() => _$PatchItemToJson(this);
}

@JsonSerializable()
class GetServerHealthResponse {
  final List<ServiceDependency>? dependencies;
  final String name;
  final String version;

  const GetServerHealthResponse({
    this.dependencies,
    required this.name,
    required this.version,
  });

  GetServerHealthResponse copyWith({
    List<ServiceDependency>? dependencies,
    String? name,
    String? version,
  }) {
    return GetServerHealthResponse(
      dependencies: dependencies ?? this.dependencies,
      name: name ?? this.name,
      version: version ?? this.version,
    );
  }

  factory GetServerHealthResponse.fromJson(Map<String, dynamic> json) =>
      _$GetServerHealthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GetServerHealthResponseToJson(this);
}

