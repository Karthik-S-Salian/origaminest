from fastapi import FastAPI, UploadFile,status,HTTPException
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
from data import getVideoUrl,getMCQ,getClasses
from predict import generate_inference
from schemas import PredictResponse

TF_ENABLE_ONEDNN_OPTS=0

app = FastAPI()

origins = [
    "*",
    "http://localhost:37914",
    "http://localhost:5173",
]
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/classes")
def getCategories():
    return getClasses()

@app.post("/mcqs")
def getCategories(cls:str):
    return getMCQ(cls)


@app.post("/predict",response_model=PredictResponse)
async def predict(category:str,file: UploadFile):
    cls,confidence = generate_inference(category,await file.read())
    return {
        'cls': cls,
        'confidence': confidence,
        "videoUrl": getVideoUrl(cls),
    }

if __name__ == "__main__":
    import socket
    hostname = socket.getfqdn()
    ip = socket.gethostbyname_ex(hostname)[2][0]
    uvicorn.run(app, host=ip, port=8000)