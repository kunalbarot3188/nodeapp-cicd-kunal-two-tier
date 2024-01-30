# Stage 1: Build stage
FROM python:3.9 AS builder

# Set the working directory in the container
WORKDIR /app

# Install required packages for system
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y gcc default-libmysqlclient-dev pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Copy the requirements file into the container
COPY requirements.txt .

# Install app dependencies, including mysqlclient
RUN pip install mysqlclient \
    && pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . .

# Stage 2: Runtime stage
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

COPY --from=builder /app /app/

COPY --from=builder /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages
#COPY --from=builder /usr/lib/ /usr/lib/
COPY --from=builder /usr/lib/x86_64-linux-gnu/libmariadb.so.3 /usr/lib/x86_64-linux-gnu/

EXPOSE 5000

#COPY --from=builder /usr/bin/ /usr/bin/

# Copy only the necessary files from the build stage
#COPY --from=builder /app /app/

# Specify the command to run your application
CMD ["python", "app.py"]

