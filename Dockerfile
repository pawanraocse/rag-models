# Use the Ollama image as the base
FROM ollama/ollama

# Install necessary dependencies
RUN apt-get update && \
    apt-get install -y \
    python3-pip \  
    git \          
    ffmpeg \       
    && apt-get clean  # Clean up the apt cache to reduce image size

# Set the working directory inside the container
WORKDIR /app

# Copy the requirements file into the container
COPY requirements.txt .

# Copy the modelfile into the container
COPY Modelfile .

# Install any dependencies specified in requirements.txt
RUN pip3 install --no-cache-dir -r requirements.txt

# Copy the .env file into the container
COPY .env .

# Copy the entrypoint script into the container
COPY entrypoint.sh /app/entrypoint.sh

# Copy the pdf to the container
COPY sample.pdf /app/sample.pdf

# Make the entrypoint script executable
RUN chmod +x /app/entrypoint.sh

# Set the entrypoint to the script
ENTRYPOINT ["/app/entrypoint.sh"]