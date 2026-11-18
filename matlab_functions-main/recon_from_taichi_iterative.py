
from run_mgfbp_iterative_recon import run_mgfbp_ir
from run_mgfbp import load_jsonc
from run_mgfbp import save_jsonc
import os
import sys

dirname = os.path.dirname(__file__)
curPath = os.path.abspath(dirname)
r= os.path.split(curPath)
rootPath = r[0]
sys.path.append("C:\\Users\\xji\\Desktop\\xuchenglong_code_test\\source_code")

jsonc_file = sys.argv[1]
run_mgfbp_ir(jsonc_file)