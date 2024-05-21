from langchain_core.prompts import PromptTemplate
from langchain_community.llms.mlflow import Mlflow

llm = Mlflow(
    target_uri="http://127.0.0.1:5000",
    endpoint="internal-completions-openai-gpt-3.5-turbo",
)

prompt = PromptTemplate(
    input_variables=["adjective"],
    template="Tell me a {adjective} joke",
)

chain = prompt | llm
print(chain.invoke("funny"))


