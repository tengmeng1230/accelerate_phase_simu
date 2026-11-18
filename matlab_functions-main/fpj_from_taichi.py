


import os
import sys

f = open('recon_paths.txt','r');
recon_taichi_code_path = f.readline()
recon_taichi_code_path = f.readline()

#recon_taichi_code_path is at the second line

dirname = os.path.dirname(__file__)
curPath = os.path.abspath(dirname)
r = os.path.split(curPath)
rootPath = r[0]
sys.path.append(recon_taichi_code_path.replace('\n',''))

from run_mgfpj import *
jsonc_file = sys.argv[1]
run_mgfpj(jsonc_file)