import faiss
import numpy as np
from vcdvcd import VCDVCD
from langchain_core.prompts import PromptTemplate
from langchain.chains import LLMChain
from langchain.llms import OpenAI
from langchain.embeddings import OpenAIEmbeddings

# Step 1: Parse VCD File
vcd = VCDVCD('simulation.vcd')
signal_trace = vcd['out'].tv

# Step 2: Create Knowledge Base
# Assume 'design_docs' is a list of strings containing the documentation
embeddings = OpenAIEmbeddings()
doc_vectors = embeddings.embed_documents(design_docs)
dimension = len(doc_vectors[0])
index = faiss.IndexFlatL2(dimension)
index.add(np.array(doc_vectors))

# Step 3: Retrieve Relevant Documentation
query = "Explain the behavior of signal_name in the design."
query_vector = embeddings.embed_query(query)
D, I = index.search(np.array([query_vector]), k=5)
retrieved_docs = [design_docs[i] for i in I[0]]

# Step 4: LLM Reasoning
prompt = PromptTemplate(
    input_variables=["assertion", "signal_trace", "documentation"],
    template="""
    The following assertion failed during simulation:
    {assertion}

    Signal Trace:
    {signal_trace}

    Relevant Documentation:
    {documentation}

    Explain step-by-step why the assertion failed.
    """
)

llm = OpenAI(model_name="gpt-4")
chain = LLMChain(llm=llm, prompt=prompt)

result = chain.run({
    'assertion': 'assert(signal_a == signal_b);',
    'signal_trace': signal_trace,
    'documentation': retrieved_docs
})

print(result)

