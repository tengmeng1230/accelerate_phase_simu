import os
import sys

f = open('recon_paths.txt','r');
recon_taichi_code_path = f.readline()
recon_taichi_code_path = f.readline()
dirname = os.path.dirname(__file__)
curPath = os.path.abspath(dirname)
r = os.path.split(curPath)
rootPath = r[0]
sys.path.append(recon_taichi_code_path.replace('\n',''))

from run_mgfbp_v2 import *

jsonc_file = sys.argv[1]
run_mgfbp_v2(jsonc_file)