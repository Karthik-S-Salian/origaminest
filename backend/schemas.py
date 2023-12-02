from pydantic import BaseModel


class PredictResponse(BaseModel):
    cls:str
    confidence:float
