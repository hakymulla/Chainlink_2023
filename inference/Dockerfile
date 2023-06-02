FROM python:3.8-slim

COPY Inference.py /app/Inference.py
COPY  rf.pkl /app/rf.pkl

WORKDIR /app

COPY requirements.txt /app

RUN pip3 install -r requirements.txt

ADD Inference.py .

ADD rf.pkl .


CMD ["python3", "Inference.py"]

