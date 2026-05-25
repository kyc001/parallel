# 扩充ANN MPI实验报告至20页

## Goal

将当前约10页的ANN MPI实验报告扩充到20页左右（含封面、目录、附录可达23-24页），补充深入的参数分析、扩展性分析、性能剖析等内容，达到与前几次实验报告（CPU架构编程、SIMD、pthread/OpenMP）相当的深度。

## Requirements

### 1. 实验数据收集

#### 1.1 参数扫描实验（双平台：Windows + Kunpeng PBS）
- **IVF-PQ**：nprobe sweep (1,2,4,8,16), nlist sweep (8,16,32,64)
- **Block-HNSW**：ef sweep (10,20,50,100,200)
- **IVF+HNSW**：nprobe sweep (1,2,4,8,16)
- **HNSW-on-HNSW**：nprobe_blocks sweep (1,2,4,8,16)
- 生成recall-latency曲线数据

#### 1.2 进程数扩展性实验（双平台：Windows + Kunpeng PBS）
- 测试np=1,2,4,8四种进程数
- 四种算法：IVF-PQ, Block-HNSW, IVF+HNSW, HNSW-on-HNSW
- 计算加速比、并行效率、通信开销变化
- 收集每个rank的搜索时间（负载均衡分析）

#### 1.3 VTune性能分析（仅Windows）
- 热点函数分析
- Cache miss分析
- 分支预测分析
- SIMD利用率分析

### 2. 报告内容扩充

#### 2.1 算法原理章节扩充
- MPI分布式ANN搜索原理（重点讲MPI部分，不重复SIMD）
- 数据划分策略
- 通信模式（broadcast, gather, reduce）
- 四种算法的MPI并行化方案对比

#### 2.2 实验环境章节扩充
- 硬件配置详细信息（CPU型号、核心数、内存、缓存层次）
- 软件版本（MPI版本、编译器版本、OpenMP版本）
- 编译选项详解

#### 2.3 参数分析章节（新增）
- 各算法参数的recall-latency曲线
- 参数选择建议
- 双平台对比

#### 2.4 扩展性分析章节（新增）
- 强扩展性曲线（np=1,2,4,8）
- 加速比和并行效率分析
- Amdahl定律验证
- 通信开销随进程数的变化
- 双平台对比

#### 2.5 负载均衡分析章节（新增）
- 各rank搜索时间分布
- 负载不均衡度量
- 不同算法的负载特征

#### 2.6 性能剖析章节（新增）
- VTune热点分析
- Cache性能分析
- 分支预测分析
- SIMD利用率分析

#### 2.7 通信模式分析章节（扩充）
- 基于已有blocking vs nonblocking数据深入分析
- 通信-计算overlap机会分析
- 双平台对比

### 3. 代码和脚本

#### 3.1 代码修改
- ✅ main.cc已添加per-rank搜索时间输出

#### 3.2 实验脚本
- Windows参数扫描脚本
- Windows扩展性实验脚本
- Kunpeng参数扫描脚本（通过PBS）
- Kunpeng扩展性实验脚本（通过PBS）

## Acceptance Criteria

- [ ] 参数扫描实验在Windows和Kunpeng PBS上完成，生成结果文件
- [ ] 扩展性实验在Windows和Kunpeng PBS上完成，生成结果文件
- [ ] 负载均衡数据在Windows和Kunpeng PBS上收集
- [ ] VTune分析在Windows上完成，生成截图和数据
- [ ] 报告正文达到18-20页
- [ ] 报告加上封面、目录、参考文献、附录达到23-24页
- [ ] 报告包含参数trade-off曲线图
- [ ] 报告包含扩展性曲线图（加速比、效率）
- [ ] 报告包含负载均衡分析图
- [ ] 报告包含VTune性能分析截图和解读
- [ ] 报告包含通信模式对比分析
- [ ] 报告算法原理讲解清晰（重点MPI部分）
- [ ] 报告实验环境描述详细
- [ ] LaTeX编译无错误，PDF生成成功
- [ ] 报告中只展示PBS运行结果，不出现direct mpiexec

## Constraints

1. 不重复前面SIMD报告中已讲过的SIMD算法原理
2. 实验环境只讲和并行实验有关的，网络环境不用讲
3. VTune分析只做Windows平台
4. 其他实验都要做双平台（Windows + Kunpeng PBS）
5. 报告中不要出现direct mpiexec，只展示PBS运行结果
6. main.cc中最终调用的应该是最快的方法

## Notes

- 参考前几次报告：
  - `D:\Study\26sp\parallel\ann-pthread-omp\report`
  - `D:\Study\26sp\parallel\ann-SIMD\report`
  - `D:\Study\26sp\parallel\lab1-CPU架构编程\report`
- 已有实验数据：
  - `results/full_score_checklist.md`
  - `results/blocking_vs_nonblocking_summary.md`
  - `results/cross_platform_summary.txt`
