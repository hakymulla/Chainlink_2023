FROM python:3.8-slim

COPY train.py /app/train.py

WORKDIR /app

COPY requirements.txt /app

RUN pip3 install -r requirements.txt

ADD train.py .

CMD ["python3", "train.py"]


