# 指定多启动CTA数量
多启动的CTA SHMEM默认分配到L2上
```
-gpgpu_cta_per_core <num>
```

# Infinite shmem(deprecated)
```
-gpgpu_shmem_infinite 1
```
# Local memory To L2
## 用法
通过以下内容配置
```
# origin
-gpgpu_cache:dl2 S:32:128:24,L:B:m:L:P,A:192:4,32:0,32
# after add local memory on L2 config
-gpgpu_cache:dl2 S:32:128:24,L:B:m:L:P,A:192:4,32:0,32,1
```

# SHMEM to L2 or Global(deprecated)

**在不改动源程序的基础上**

- 允许CTA/core参数突破shm(share memory)限制后并保证total extra shmem小于指定值情况下计算得出最大CTA/core

- 将extra shm（即expect_shm/cta - actual_shm/cta) 分配到L2或global memory上

  - expect_shm/cta 指每个cta**实际使用**了多少shm

  - actual_shm/cta 指根据每个core允许分配的最大shm大小和每个core分配CTA个数计算出每个cta可以**实际分配**的shm大小

## 用法

通过以下内容配置

```
-gpgpu_shmem_extra_maxsize 3145728 # max size of total extra shmem 3MB
-gpgpu_shmem_extra_on_L2 1 # alloc on L2 or global memory
```

## 测试

- config RTX2060 (L2 expands to 6MB , 30 cores , shm 65536B/core)   
- config QV100(L2 6MB , 80 cores , shm 98304B/core)
- gpgpu-sim 4.2.0 dev
- -gpgpu_shmem_extra_maxsize 3145728
- -gpgpu_shmem_extra_on_L2 1

| 程序                       | config  | IPC    | occupancy | cta/core | expect shm(per block) | actual shm(per block) | extra shm (per block) | extra shm (total) | L2 accesses | L2 misses |
| -------------------------- | ------- | ------ | --------- | -------- | --------------------- | --------------------- | --------------------- | ----------------- | ----------- | --------- |
| copy-origin                | RTX2060 | 65.1   | 24.1%     | 1        | 49152B                | 49152B                | 0                     | 0                 | 3276800     | 3276416   |
| copy-L2                    | RTX2060 | 61.6   | 71.7%     | 3        | 49152B                | 21845B                | 27307B                | 2.34MB            | 3955200     | 3282560   |
| copy-global                | RTX2060 | 54.7   | 71.8%     | 3        | 49152B                | 21845B                | 27307B                | 2.34MB            | 3955200     | 3955200   |
| 2Dentropy(640*480)-origin  | RTX2060 | 233.9  | 12.2%     | 1        | 32872B                | 32872B                | 0                     | 0                 | 105418      | 38400     |
| 2Dentropy(640*480)-L2      | RTX2060 | 421.9  | 61.7%     | 5        | 32872B                | 13107B                | 19765B                | 2.83MB            | 4491141     | 38400     |
| 2Dentropy(1280*720)-origin | RTX2060 | 237.8  | 12.3%     | 1        | 32872B                | 32872B                | 0                     | 0                 | 265690      | 115200    |
| 2Dentropy(1280*720)-L2     | RTX2060 | 428.2  | 62.2%     | 5        | 32872B                | 13107B                | 19765B                | 2.83MB            | 13441595    | 123988    |
| 2Dentropy(640*480)-origin  | QV100   | 1405.6 | 12.2%     | 2        | 32872B                | 32872B                | 0                     | 0                 | 104358      | 38400     |
| 2Dentropy(640*480)-L2      | QV100   | 1906.1 | 23.9%     | 4        | 32872B                | 24576B                | 8296B                 | 2.53MB            | 1129438     | 38400     |
| simpleGEMM-origin          | RTX2060 | 58.0   | 3.1%      | 1        | 33024B                | 33024B                | 0                     | 0                 | 1097668     | 65536     |
| simpleGEMM-L2              | RTX2060 | 112.8  | 15.3%     | 5        | 33024B                | 13107B                | 19917B                | 2.85MB            | 5631910     | 65536     |
| simpleCONV-origin          | RTX2060 | 174.6  | 12.4%     | 1        | 33800B                | 33800B                | 0                     | 0                 | 1312032     | 9216      |
| simpleCONV-L2              | RTX2060 | 309.4  | 60.5%     | 5        | 33800B                | 13107B                | 20693B                | 2.96MB            | 1437809     | 10466     |

- 由于源程序未改变，相同程序不论采取什么策略执行的指令总数相同
- 后缀说明
  - origin指原程序不使用shm分配到L2或global策略
  - L2指extra shm分配到L2上
  - global指extra shm分配到global memory上
- 参数说明
  - copy N=3276800 GRID_DIM_X=800 
  - 2Dentropy only low occupancy kernel

# Alloc on L2

- 可以显式地在L2缓存上分配内存空间
  - 使用cudaMalloc，传入的size参数第64位设置为1（索引从1开始）
- 可以free掉在L2缓存上分配的所有内存空间
  - 使用cudaMalloc，传入的size参数第63位设置为1（索引从1开始）

## demo

```c++
//仅支持在GPGPU-Sim仿真使用
#include "cuda_runtime.h"
#include <stdio.h>
#define SIZE 10000

__global__ void kernel(int *array){
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    array[i] = i;
}

int main(){
    int *array;
    int *config;//没有实际意义,仅仅为了在free时传入参数
    cudaMalloc((void**)&array,sizeof(int)*SIZE | (unsigned long)1<<63);//alloc at L2 cache
    kernel<<<10,SIZE/10>>>(array); // GPGPU-Sim L2缓存命中率为100%
    cudaMalloc((void**)&config,(unsigned long)1<<62);//free L2 cache
    kernel<<<10,SIZE/10>>>(array); // GPGPU-Sim L2缓存命中率为0%
    return 0;
}
```
