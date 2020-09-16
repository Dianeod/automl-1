if defined QLIC_KC (
        pip -q install -r requirements.txt
	echo getting test.q from embedpy
        git clone https://github.com/KxSystems/ml.git
	git clone https://github.com/KxSystems/nlp.git
	pip -q install -r nlp/requirements.txt
	pip install --upgrade matplotlib
	pip install gensim
	pip install sobol-seq
        curl -fsSL -o test.q https://github.com/KxSystems/embedpy/raw/master/test.q
        q test.q -q
)
