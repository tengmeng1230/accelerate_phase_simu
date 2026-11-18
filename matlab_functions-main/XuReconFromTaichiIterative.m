function status = XuReconFromTaichiIterative(js_file)
    copyfile('C:\Users\xji\Desktop\matlab_functions\matlab_functions\recon_from_taichi_iterative.py','./recon_temp.py');
    system(['python ./recon_temp.py ' js_file]);
    delete ./recon_temp.py
    status = 1;
end