from datetime import datetime
from enum import Enum
from typing import Any, Optional

from pydantic import BaseModel, Field


class StatusEnum(str, Enum):
    active = "active"
    inactive = "inactive"
    archived = "archived"


class PriorityEnum(str, Enum):
    low = "low"
    medium = "medium"
    high = "high"


class ErrorCodeEnum(str, Enum):
    unknown = "UNKNOWN"
    not_found = "NOT_FOUND"
    invalid = "INVALID"


class Gadget(BaseModel):
    model_config = {"populate_by_name": True}

    id: str
    asset_id: str
    name: str
    status: StatusEnum
    priority: PriorityEnum = PriorityEnum.low
    description: Optional[str] = None
    tags: list[str] = []
    count: int = 0
    ratio: float
    is_active: bool = True
    created_at: datetime
    updated_at: Optional[datetime] = None
    metadata: dict[str, str] = {}
    extra: dict[str, Any] = {}
    html_url: Optional[str] = None
    default_value: int = Field(0, alias="default")


class GadgetCreate(BaseModel):
    asset_id: str
    name: str
    status: StatusEnum
    priority: PriorityEnum = PriorityEnum.low
    description: Optional[str] = None
    tags: list[str] = []


class GadgetContainer(BaseModel):
    id: str
    primary: Gadget
    gadgets: list[Gadget]
    gadget_map: dict[str, Gadget]


class ErrorResponse(BaseModel):
    error_code: ErrorCodeEnum = ErrorCodeEnum.unknown
    detail: str
