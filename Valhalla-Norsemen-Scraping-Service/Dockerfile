FROM python:3.9.0-slim

COPY ./requirements.txt ./
RUN python -m pip install --upgrade pip && \
    python -m pip install -r requirements.txt

ARG BUILD_VERSION
ENV VERSION=$BUILD_VERSION
ENV PATH=/root/.local/bin:$PATH

COPY . /app
WORKDIR /app

CMD ["python", "./main.py"]
