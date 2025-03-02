FROM python:3.12-alpine

WORKDIR /app

COPY api/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

ENV APP_ENVIRONMENT="container"
ENV LOG_LEVEL="INFO"

COPY api/utils/*.py ./utils/

COPY api/post.py .
CMD [ "python", "post.py" ]
