FROM python:3.8-slim

COPY train.py /app/train.py

WORKDIR /app

COPY requirements.txt /app

RUN pip3 install -r requirements.txt

ADD train.py .

CMD ["python3", "train.py"]

# docker buildx build --platform linux/amd64 --push -t hakymulla/chainlink:train .

# bacalhau docker run \
#     --input ipfs://Qma2xggBtRKGCQc6JZRgmaNiXswbPdJSas9hQ8AaM3ngyY:/inputs/train_data.csv \
#     hakymulla/chainlink:train

# bacalhau list --id-filter 

# bacalhau get