from fastapi import FastAPI
from log_reader import get_logs

app = FastAPI()

@app.get("/")
def home():
    return {"status": "running"}

@app.get("/logs")
def logs():
    return get_logs()