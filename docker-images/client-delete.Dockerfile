FROM python:3.12-alpine

WORKDIR /app

COPY client/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

ENV APP_ENVIRONMENT="container"
ENV LOG_LEVEL="INFO"

COPY client/utils/*.py ./utils/

COPY client/delete.py .
CMD [ "python", "delete.py" ]
