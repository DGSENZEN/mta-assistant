from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Json
from typing import Any, Optional, List, Literal, Dict
import json 

app = FastAPI()

class ArrivalDepartureTime(BaseModel):
    time: str  # Or int, depending on GTFS implementation

class StopTimeUpdate(BaseModel):
    stopId: str
    arrival: Optional[ArrivalDepartureTime] = None
    departure: Optional[ArrivalDepartureTime] = None
    departureOccupancyStatus: Optional[str] = None

class TripDescriptor(BaseModel):
    tripId: str
    routeId: str
    startTime: str
    startDate: str

class TripUpdate(BaseModel):
    trip: TripDescriptor
    stopTimeUpdate: Optional[List[StopTimeUpdate]] = None

class VehiclePosition(BaseModel):
    trip: TripDescriptor
    currentStopSequence: Optional[int] = None
    currentStatus: Optional[Literal["INCOMING_AT", "STOPPED_AT", "IN_TRANSIT_TO"]] = None
    timestamp: Optional[str] = None
    stopId: Optional[str] = None

class Entity(BaseModel):
    id: str
    tripUpdate: Optional[TripUpdate] = None
    vehicle: Optional[VehiclePosition] = None

class MtaData(BaseModel):
    entity: List[Entity]

# Wrapper class to match the actual incoming data structure
class ElixirPayload(BaseModel):
    mta_data: MtaData

@app.post("/elixir_listener")
async def elixir_listener(payload: ElixirPayload):
    try:
        processed = payload.mta_data
        return {"status": 200, "parsed_payload": processed}
    except json.JSONDecodeError as e:
        raise HTTPException(status_code=400, detail=f"Invalid JSON: {e}")
    except Exception as e:
        raise HTTPException(status_code=422, detail=f"Validation error: {e}")
