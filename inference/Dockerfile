FROM python:3.8-slim

COPY Inference.py /app/Inference.py
COPY  rf.pkl /app/rf.pkl

WORKDIR /app

COPY requirements.txt /app

RUN pip3 install -r requirements.txt

ADD Inference.py .

ADD rf.pkl .


CMD ["python3", "Inference.py"]

# docker buildx build --platform linux/amd64 --push -t hakymulla/chainlink:inference .

# bacalhau docker run --id-only --cpu 1 hakymulla/chainlink:inference -- python Inference.py  --ag 30 --t "Yes" --i "Yes" --n "Yes" --c "Yes" --l "Maybe" --g "Yes" --b "Yes" --s "Yes" 

# bacalhau list --id-filter 
# bacalhau get 
