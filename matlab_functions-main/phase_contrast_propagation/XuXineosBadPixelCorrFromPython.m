function status = XuXineosBadPixelCorrFromPython(file_path)
    copyfile('C:\Users\xji\Desktop\matlab_functions\matlab_functions\phase_contrast_propagation\XuXineosBadPixelCorr.py','./bad_pixel_corr.py');
    system(['python ./bad_pixel_corr.py ' file_path]);
    delete ./bad_pixel_corr.py
    status = 1;
end