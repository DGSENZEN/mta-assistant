from fastapi import FastAPI 
from pydantic import BaseModel

app = FastAPI()

class ExPostRequest(BaseModel):
    sender: str
    sender_id: int
    body: str
    timestamp: str | None = None
    """"""

@app.post("/test_endpoint")
async def test_endpoint(msg: ExPostRequest):
    return msg 
