import faiss
import numpy as np
from vcdvcd import VCDVCD
from langchain_core.prompts import PromptTemplate
from langchain.chains import LLMChain
from langchain_community.llms import OpenAI
from langchain_openai import OpenAIEmbeddings


# Step 1: Parse VCD File
vcd = VCDVCD('simulation.vcd')
# print all the signal names: print(vcd.references_to_ids.keys())
signal_trace = vcd['opposite_tb.out[3:0]'].tv
design_doc = "ridecore.pdf"
# Step 2: Create Knowledge Base
# Assume 'design_docs' is a list of strings containing the documentation
embeddings = OpenAIEmbeddings()
doc_vectors = embeddings.embed_documents(design_doc)
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

llm = OpenAI(model_name="gpt-4o-mini-2024-07-18")
chain = LLMChain(llm=llm, prompt=prompt)

result = chain.run({
    'assertion': 'assert(signal_a == signal_b);',
    'signal_trace': signal_trace,
    'documentation': retrieved_docs
})

print(result)

