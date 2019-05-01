#!/bin/bash



set -e

if (( $# != 1 )); then
    echo "Illegal number of parameters"
fi


if [ $1 == "gpu" ]; then 
# ==================================================================
# conda package install
# ------------------------------------------------------------------
    echo "start to install GPU related pkgs"
#    ln -s /usr/local/cuda-9.0/lib64/libcurand.so.9.0 /usr/local/cuda-9.0/lib64/libcurand.so.8.0

    conda install --yes --quiet  \
        pytorch==0.4.0 \
        opencv==3.4.1 \
        tensorflow-gpu==1.9.0 \
        keras==2.1.5 \
        statsmodels==0.9.0 \
        scipy==1.1.0 \
        numpy==1.14.3 \
        scikit-learn==0.19.1 \
        pandas==0.23.4 \
        matplotlib \
        bokeh==0.13.0 \
        seaborn==0.8.1 \
        beautifulsoup4==4.6.0 \
        nltk==3.3.0 \
        requests==2.18.4 \
        urllib3==1.22 \
        ipywidgets==7.2.1 \
        notebook==5.5.0 && \
    conda install --yes --quiet -c lukepfister \
        pycuda \
        scikits.cuda \
        && \
    conda clean -tipsy 

# ==================================================================
# pip package install
# ------------------------------------------------------------------
    pip install --upgrade pip && \
    pip install --quiet --no-cache-dir mxnet-cu90==1.2.0 konlpy==0.4.3 \
        fasttext==0.8.3 \
        xgboost==0.72.1 \
        jpype1==0.6.3 \
        gensim==3.5.0 \
        autopep8 \
        mlxtend \
        lightgbm \
        catboost \
        plotnine \
        missingno \
        pyLDAvis \
        Edward \
        dfply \
        dplython
elif [ $1 == "cpu" ]; then 
# ==================================================================
# conda package install
# ------------------------------------------------------------------
    conda install --yes --quiet  \
        pytorch==0.4.0 \
        opencv==3.4.1 \
        tensorflow==1.9.0 \
        keras==2.1.5 \
        statsmodels==0.9.0 \
        scipy==1.1.0 \
        numpy==1.14.3 \
        scikit-learn==0.19.1 \
        pandas==0.23.4 \
        matplotlib \
        bokeh==0.13.0 \
        seaborn==0.8.1 \
        beautifulsoup4==4.6.0 \
        nltk==3.3.0 \
        requests==2.18.4 \
        urllib3==1.22 \
        ipywidgets==7.2.1 \
        notebook==5.5.0 \
    && \
    conda clean -tipsy


# ==================================================================
# pip package install
# ------------------------------------------------------------------
    pip install --upgrade pip && \
    pip install --quiet --no-cache-dir mxnet==1.2.0 konlpy==0.4.3 \
        fasttext==0.8.3 \
        xgboost==0.72.1 \
        jpype1==0.6.3 \
        gensim==3.5.0 \
        autopep8 \
        mlxtend \
        lightgbm \
        catboost \
        plotnine \
        missingno \
        pyLDAvis \
        Edward \
        dfply \
        dplython
else
  echo "Illegal parameter... the parameter is cpu or gpu"
fi

