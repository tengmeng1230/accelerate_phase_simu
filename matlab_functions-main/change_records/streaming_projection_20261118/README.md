# 逐视角投影输出修改记录（2026-11-18）

## 修改文件与差异

每个文件的 `.before` 是修改前原件，`.diff` 是统一格式差异；外部 Python 文件也保存在本记录目录中作为修改后快照。

| 文件 | 修改前 | 修改后 |
|---|---|---|
| Reconstruction_program_taichi-master/run_mgfpj_v2.py | 构造时分配完整 CPU 投影数组 | 仅当子类启用 streaming_output 时跳过大数组；其他调用不变 |
| Reconstruction_program_taichi-master/run_mgfpj_v3.py | 单视角计算后积累至完整数组，最后整体保存 | StreamingOutput=true 时每视角写入 .partial，关闭文件、核对长度后 os.replace 成正式文件 |
| matlab_functions-main/XuFpjFromTaichi.m | 忽略 system 退出码，始终返回 1 | 返回实际退出码；非零时抛出 ProjectionFailed 并停止调用链 |
| phase_contrast_propagation/XuPropagationSimuScale.m | 无流式默认设置 | 未指定 StreamingOutput 时默认 true；显式 false 可恢复原方式 |

## 使用与兼容性

正常调用原有 MATLAB 仿真入口即可。配置可添加 `"StreamingOutput": false` 恢复完整数组方式（大参数仍可能内存不足）。Python v3 直接调用的默认值仍为 false。流式模式仅支持 post_log_images；传入其他格式将明确报错。计算公式、噪声调用顺序和 float32 输出精度不变。

流式模式的 Python MainFunction/run_mgfpj_v3 返回值为 None，输出通过磁盘文件获取；原有 MATLAB 仅启动子进程，不依赖这个返回值。非流式模式保留数组返回。XuFpjFromTaichi 成功返回值由原来的固定 1 改为系统成功码 0，失败抛错。

写入失败时不执行正式文件替换；普通 Python 异常会关闭句柄，操作系统强制终止时由操作系统关闭。可能遗留 .partial 文件，重新运行会覆盖对应临时文件。已存在的正式文件在新结果成功之前保持原样；MATLAB 在子进程失败时立即停止，避免继续使用旧结果。未实现断点续算。临时文件与正式文件在同一目录。

## 内存与磁盘差异（估算，非实测）

参数：500×500 探测器，8 倍上采样，720 视角。完整 float32 投影数组为 4000×720×4000×4 字节，约 42.9 GiB/材料；流式 CPU 输出帧为 4000×4000×4 字节，约 61 MiB。完整 RAW 文件仍约 42.9 GiB/材料。物体数据、Taichi GPU 缓冲区、MATLAB FFT 数组等另计；未承诺整个进程只有 61 MiB。重新计算已有结果时，旧正式文件与新临时文件可能同时占用磁盘。

## 已完成验证

- 使用现有 tengmeng Python 环境编译检查修改后的 v2/v3 源码：通过。
- 从实际 v3 源码提取 TransferToRAM，使用 3 视角×4 行×5 列的 float32 测试帧执行流式和原数组路径：通过。
- 流式文件与原数组 transpose(1,0,2) 的 C-order 字节完全一致；文件大小正确：通过。

## 尚未验证

环境 PATH 中无 MATLAB 命令，未运行 MATLAB 完整调用链；未执行真实 GPU 正投影、材料批处理或 4000×4000×720 全尺寸仿真，因此没有实测峰值内存或耗时。后续应先用少量视角完成一次真实端到端对比，再运行完整参数并监测 CPU 内存、GPU 显存和磁盘。MATLAB 相位传播仍保留当前逐视角流程，其 FFT 内存占用需单独实测。
