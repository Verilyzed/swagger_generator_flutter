from datetime import datetime
from typing import Optional

from fastapi import FastAPI

from app.schemas import (
    ErrorResponse,
    StatusEnum,
    Gadget,
    GadgetContainer,
    GadgetCreate,
)

app = FastAPI(title="Edge Case Test API", version="1.0.0")


def _sample_gadget(gadget_id: str = "w1") -> Gadget:
    return Gadget(
        id=gadget_id,
        asset_id="a1",
        name="Sample",
        status=StatusEnum.active,
        ratio=1.0,
        created_at=datetime(2020, 1, 1),
    )


@app.get("/gadgets", response_model=list[Gadget], tags=["gadgets"])
def list_gadgets(
    status: Optional[StatusEnum] = None,
    limit: int = 50,
    offset: int = 0,
):
    return [_sample_gadget()]


@app.get(
    "/gadgets/{gadget_id}",
    response_model=Gadget,
    responses={404: {"model": ErrorResponse}},
    tags=["gadgets"],
)
def get_gadget(gadget_id: str):
    return _sample_gadget(gadget_id)


@app.post("/gadgets", response_model=Gadget, tags=["gadgets"])
def create_gadget(body: GadgetCreate):
    return _sample_gadget()


@app.put("/gadgets/{gadget_id}", response_model=Gadget, tags=["gadgets"])
def replace_gadget(gadget_id: str, body: GadgetCreate):
    return _sample_gadget(gadget_id)


@app.patch("/gadgets/{gadget_id}", response_model=Gadget, tags=["gadgets"])
def update_gadget(gadget_id: str, body: GadgetCreate):
    return _sample_gadget(gadget_id)


@app.delete("/gadgets/{gadget_id}", tags=["gadgets"])
def delete_gadget(gadget_id: str):
    return {"deleted": gadget_id}


@app.get(
    "/containers/{container_id}",
    response_model=GadgetContainer,
    responses={404: {"model": ErrorResponse}},
    tags=["containers"],
)
def get_container(container_id: str):
    gadget = _sample_gadget()
    return GadgetContainer(
        id=container_id,
        primary=gadget,
        gadgets=[gadget],
        gadget_map={"k": gadget},
    )
