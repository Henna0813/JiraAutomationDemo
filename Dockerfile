# ===== Base Image =====
FROM python:3.13-slim

# ===== Set Work Directory =====
WORKDIR /app

# ===== Install system deps =====
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# ===== Install Robot Framework Dependencies =====
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# ===== Copy Project Files =====
COPY . .

# ===== Set default environment variables =====
ENV PLAYWRIGHT_HEADLESS=true

# ===== Run Robot Tests =====
CMD ["robot", "--pythonpath", ".", "tests/api"]
