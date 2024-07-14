from pydantic import BaseModel
from fastapi import  UploadFile

class PredictResponse(BaseModel):
    cls:str
    confidence:float
    videoUrl:str

class MCQRequest(BaseModel):
    cls:str


class PredictRequest(BaseModel):
    category:str
    image:UploadFile
