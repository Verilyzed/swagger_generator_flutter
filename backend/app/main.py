from datetime import datetime
from typing import Optional

from fastapi import FastAPI

from app.schemas import (
    ErrorResponse,
    StatusEnum,
    Widget,
    WidgetContainer,
    WidgetCreate,
)

app = FastAPI(title="Edge Case Test API", version="1.0.0")


def _sample_widget(widget_id: str = "w1") -> Widget:
    return Widget(
        id=widget_id,
        asset_id="a1",
        name="Sample",
        status=StatusEnum.active,
        ratio=1.0,
        created_at=datetime(2020, 1, 1),
    )


@app.get("/widgets", response_model=list[Widget], tags=["widgets"])
def list_widgets(
    status: Optional[StatusEnum] = None,
    limit: int = 50,
    offset: int = 0,
):
    return [_sample_widget()]


@app.get(
    "/widgets/{widget_id}",
    response_model=Widget,
    responses={404: {"model": ErrorResponse}},
    tags=["widgets"],
)
def get_widget(widget_id: str):
    return _sample_widget(widget_id)


@app.post("/widgets", response_model=Widget, tags=["widgets"])
def create_widget(body: WidgetCreate):
    return _sample_widget()


@app.put("/widgets/{widget_id}", response_model=Widget, tags=["widgets"])
def replace_widget(widget_id: str, body: WidgetCreate):
    return _sample_widget(widget_id)


@app.patch("/widgets/{widget_id}", response_model=Widget, tags=["widgets"])
def update_widget(widget_id: str, body: WidgetCreate):
    return _sample_widget(widget_id)


@app.delete("/widgets/{widget_id}", tags=["widgets"])
def delete_widget(widget_id: str):
    return {"deleted": widget_id}


@app.get(
    "/containers/{container_id}",
    response_model=WidgetContainer,
    responses={404: {"model": ErrorResponse}},
    tags=["containers"],
)
def get_container(container_id: str):
    widget = _sample_widget()
    return WidgetContainer(
        id=container_id,
        primary=widget,
        widgets=[widget],
        widget_map={"k": widget},
    )
