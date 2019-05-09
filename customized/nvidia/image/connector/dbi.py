import os
import sys
import time
import random 
import pandas as pd


def dbGetQuery(query: str, source: str='oracle', sep: str=',', clean_outfile: bool=True, dtype=None):
    """
    데이터베이스에서 query 를 실행한 결과물을 DataFrame으로 반환한다. 

    params
    query: str, valid query statement
    source: str, data source, hive or oracle
    sep: str, 분할자, default ','

    return 
    df: DataFrame
    예시:
    df = dfGetQuery("SELECT * from SC202079.SHC_MCT")
    """

    PREFIX_OUTFILE = '/home/jovyan/notebooks/data/'
    outfile = "temp%d.csv" % random.randint(0, 1e10)    
    cmd = 'jdbc-cli -t {} -o {} -q "{}" -s "{}"'.format(source, outfile, query, sep)
    print('cmd:' + cmd)
    os.system(command=cmd)
    df = pd.read_csv(PREFIX_OUTFILE + outfile, error_bad_lines=False, encoding='utf-8', sep=sep, dtype=dtype)
    
    if clean_outfile:
        os.system(command='rm %s' % PREFIX_OUTFILE + outfile)

    return df