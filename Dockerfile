# Use Python slim image for ARM (Raspberry Pi)
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

RUN pip list


# Copy application files
COPY src/ ./src/
COPY schema.sql .

# Create data directory
RUN mkdir -p /app/data

# Set Python to run in unbuffered mode (so logs show up immediately)
ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=/app

# Run the bot directly
CMD ["python", "src/bot.py"]
