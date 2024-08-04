#!/bin/sh

# Function to log messages with timestamps
log() {
  echo "$(date +"%Y-%m-%d %T") - $1"
}

# Define the model names
MODEL_NAME="phi3"
MODEL_JARVIS="jarvis"

# Start the Ollama service in the background
log "Starting Ollama service..."
ollama serve &

# Wait for the Ollama service to start
sleep 10

# Pull the model to ensure it's up-to-date
log "Pulling $MODEL_NAME model..."
if ollama pull $MODEL_NAME; then
  log "$MODEL_NAME model pull complete."
else
  log "Failed to pull $MODEL_NAME model."
  exit 1
fi

# Check if the jarvis model exists and remove it if it does
# log "Checking for existing $MODEL_JARVIS model..."
# if ollama show $MODEL_JARVIS > /dev/null 2>&1; then
#   log "$MODEL_JARVIS model exists. Removing..."
#   if ollama rm $MODEL_JARVIS; then
#     log "$MODEL_JARVIS model removed."
#   else
#     log "Failed to remove $MODEL_JARVIS model."
#     exit 1
#   fi
# else
#   log "$MODEL_JARVIS model does not exist."
# fi

# Create the $MODEL_JARVIS model using the Modelfile
# log "Creating $MODEL_JARVIS model..."
# if ollama create $MODEL_JARVIS -f ./Modelfile; then
#   log "$MODEL_JARVIS model creation complete."
# else
#   log "Failed to create $MODEL_JARVIS model."
#   exit 1
# fi

# Run the $MODEL_NAME model
log "Running $MODEL_NAME model..."
if ollama run $MODEL_NAME; then
  log "$MODEL_NAME model is now running."
else
  log "Failed to run $MODEL_NAME model."
  exit 1
fi

# Start Jupyter Notebook
log "Starting Jupyter Notebook..."
jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser --allow-root &
log "Jupyter Notebook started."

# Keep the container running regardless of the previous steps' outcome
log "Setup complete. Keeping the container running."

tail -f /dev/null
