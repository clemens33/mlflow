from langchain_core.messages import HumanMessage, SystemMessage
from langchain_community.chat_models.mlflow import ChatMlflow

chat = ChatMlflow(
    target_uri="http://127.0.0.1:5000",
    endpoint="internal-chat-openai-gpt-3.5-turbo",
)

messages = [
    SystemMessage(
        content="You are a helpful assistant that translates English to German."
    ),
    HumanMessage(
        content="Translate this sentence from English to German: I love programming."
    ),
]
print(chat(messages))

