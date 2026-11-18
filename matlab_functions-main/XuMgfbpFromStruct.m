function status = XuMgfbpFromStruct(struct_js)

mkdir(struct_js.OutputDir);
XuStructToJsonc('config_fbp_temp.jsonc',struct_js);
!mgfbp.exe config_fbp_temp.jsonc
delete config_fbp_temp.jsonc
status = 1;