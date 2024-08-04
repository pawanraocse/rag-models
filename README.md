# RAG (Retrieval-Augmented Generation) Project

This project is a sample implementation of a Retrieval-Augmented Generation (RAG) model that can take a PDF document or a YouTube video link and answer questions based on the content. The model leverages OpenAI's language model and in-memory embeddings to provide accurate responses. The entire project is developed in a Docker environment, making it easy to set up and run.

## Features

- **PDF Processing**: Upload a PDF and ask questions about its content.
- **YouTube Video Processing**: Provide a YouTube video link and ask questions about its content.
- **Local LLM Model**: Uses OpenAI's language model for natural language processing.
- **In-Memory Embeddings**: Efficient and fast embeddings for quick retrieval and response.

## Prerequisites

- Docker
- Git

## Setup

1. **Clone the Repository**

   ```bash
   git clone https://github.com/pawanraocse/rag-models.git
   cd rag-models
   ```

2. **Build the docker image**
   ```bash
   docker-compose up --build -d
   ```
3. **Access Jupyter Notebook**
   ```bash
   Open your browser and go to http://localhost:8888. You should see the Jupyter Notebook interface.
   ```

### Directory Descriptions

- **`docker-compose.yml`**: Defines the services, networks, and volumes for Docker Compose.
- **`Dockerfile`**: Contains instructions to build the Docker image.
- **`requirements.txt`**: Lists Python packages required for the project.
- **`src/`**: Contains the source code for the project.
  - **`main.py`**: Main script that integrates PDF and YouTube processing.
  - **`pdf_processor.py`**: Handles PDF document loading and processing.
  - **`youtube_processor.py`**: Manages YouTube video downloading and transcription.
  - **`utils.py`**: Provides utility functions used across the project.
- **`notebooks/`**: Includes Jupyter notebooks for interactive experimentation.
  - **`example_notebook.ipynb`**: Demonstrates how to use the project's functionality.
- **`data/`**: Stores sample data files for testing and demonstration purposes.
- **`.env`**: Contains environment variables for configuration.
- **`README.md`**: Provides an overview of the project, installation instructions, and usage guidelines.

## Usage

### Processing a PDF Document

1. **Load and Split Document:**

   ```python
   from langchain_community.document_loaders import PyPDFLoader

   # Replace 'your_document.pdf' with the path to your PDF
   loader = PyPDFLoader("your_document.pdf")
   pages = loader.load_and_split()
   ```

2. **Create and Use Vectorstore:**

   ```python
   from langchain.embeddings import OpenAIEmbeddings
   from langchain.vectorstores import DocArrayInMemorySearch
   from langchain.llms import OpenAI

   embeddings = OpenAIEmbeddings()
   vectorstore = DocArrayInMemorySearch.from_documents(pages, embedding=embeddings)
   retriever = vectorstore.as_retriever()
   model = OpenAI()

   chain = (
       {"context": retriever, "question": "Your question"}
       | model
   )

   result = chain.invoke("What is this document about?")
   print(result)
   ```

### Processing a YouTube Video

1. **Download and Transcribe Video:**

   ```python
   import tempfile
   import whisper
   from pytube import YouTube
   import os

   YOUTUBE_VIDEO = "https://www.youtube.com/watch?v=YOUR_VIDEO_ID"

   if not os.path.exists("transcription.txt"):
       youtube = YouTube(YOUTUBE_VIDEO)
       audio = youtube.streams.filter(only_audio=True).first()
       whisper_model = whisper.load_model("base")

       with tempfile.TemporaryDirectory() as tmpdir:
           file = audio.download(output_path=tmpdir)
           transcription = whisper_model.transcribe(file, fp16=False)["text"].strip()
           with open("transcription.txt", "w") as file:
               file.write(transcription)
   ```

2. **Process and Query Transcription:**

   ```python
   from langchain.embeddings import OpenAIEmbeddings
   from langchain.vectorstores import DocArrayInMemorySearch
   from langchain.llms import OpenAI

   with open("transcription.txt", "r") as file:
       transcription = file.read()

   documents = [{"text": transcription}]
   embeddings = OpenAIEmbeddings()
   vectorstore = DocArrayInMemorySearch.from_documents(documents, embedding=embeddings)
   retriever = vectorstore.as_retriever()
   model = OpenAI()

   chain = (
       {"context": retriever, "question": "Your question"}
       | model
   )

   result = chain.invoke("What is this video about?")
   print(result)
   ```

This approach provides practical examples of how to use the project while keeping the README clear and focused.

## Troubleshooting

- **Error: `HTTPError: HTTP Error 400: Bad Request`**

  - **Possible Cause**: The YouTube video URL might be incorrect or the video might be restricted.
  - **Solution**: Verify the YouTube URL and ensure the video is accessible. Try using a different video URL.

- **Error: `Failed to extract uploader id`**

  - **Possible Cause**: There might be issues with `yt-dlp` version or YouTube’s page structure.
  - **Solution**: Update `yt-dlp` to the latest version using `yt-dlp -U`. Ensure `ffmpeg` is installed and properly configured.

- **Error: `Postprocessing: ffprobe and ffmpeg not found`**

  - **Possible Cause**: `ffmpeg` might not be installed or configured correctly.
  - **Solution**: Install `ffmpeg` using the following command:
    ```bash
    sudo apt-get install ffmpeg
    ```

- **Error: `RegexNotFoundError`**

  - **Possible Cause**: This can occur if YouTube changes its page structure or if `yt-dlp` is out of date.
  - **Solution**: Update `yt-dlp` to the latest version and try again.

- **Docker Issues**

  - **Error: `Docker container not starting`**
    - **Possible Cause**: Misconfiguration in `docker-compose.yml` or missing dependencies.
    - **Solution**: Check the Docker logs for errors and verify the configuration in `docker-compose.yml`.
