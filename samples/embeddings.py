from langchain_community.embeddings.mlflow import MlflowEmbeddings

embeddings = MlflowEmbeddings(
    target_uri="http://127.0.0.1:5000",
    endpoint="internal-embeddings-openai-text-embedding-3-large",
)

print(embeddings.embed_query("Tell me a funny joke"))