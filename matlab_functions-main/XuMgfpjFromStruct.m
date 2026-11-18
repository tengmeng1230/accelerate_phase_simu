function status = XuMgfpjFromStruct(struct_js)

mkdir(struct_js.OutputDir);
XuStructToJsonc('config_fpj_temp.jsonc',struct_js);
!mgfpj.exe config_fpj_temp.jsonc
delete config_fpj_temp.jsonc
status = 1;