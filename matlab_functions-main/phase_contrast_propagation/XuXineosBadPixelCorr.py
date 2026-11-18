from correct2 import repair_bad_pixels
import tifffile as tf
import numpy as np
import os
import sys

dirname = os.path.dirname(__file__)
curPath = os.path.abspath(dirname)
r= os.path.split(curPath)
rootPath = r[0]
sys.path.append("C:\\Users\\xji\\Desktop\\xuchenglong_code_test\\source_code")

file_path = sys.argv[1]
img_tf = tf.imread(file_path)
img_corr = repair_bad_pixels(img_tf)
tf.imwrite(file_path.replace('.tif','') + '_bad_corr.tif', data = img_corr, shape = img_tf.shape)