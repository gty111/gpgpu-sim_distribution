NVCC_ARG="-lcudart -arch=sm_80"
BIN_PATH="/mnt/sda/2022-0526/home/gtyinstinct/CUDA_code/L2-sim/bin"
export NVCC_PREPEND_FLAGS='--resource-usage -maxrregcount 0 -Xptxas -v -Xptxas -warn-spills -Xptxas -warn-lmem-usage'

#nvcc ${NVCC_ARG} -o ${BIN_PATH}/convolutionSeparableX2 -lcudart -Itest/convolutionSeparable test/convolutionSeparable/*.cu test/convolutionSeparable/*.cpp
#nvcc ${NVCC_ARG} -o ${BIN_PATH}/2Dentropy test/2Dentropy/2Dentropy.cu
#nvcc ${NVCC_ARG} -o ${BIN_PATH}/cfd -I test/hybridsort  test/cfd/euler3d_double.cu
#nvcc ${NVCC_ARG} -o ${BIN_PATH}/heartwall test/heartwall/heartwall.cu
#nvcc ${NVCC_ARG} -o ${BIN_PATH}/hybridsort test/hybridsort/bucketsort.cu test/hybridsort/mergesort.cu test/hybridsort/main.cu
#nvcc ${NVCC_ARG} -o ${BIN_PATH}/lavaMD test/lavaMD/lavaMD.cu
#nvcc ${NVCC_ARG} -o ${BIN_PATH}/LIB -L test/NQU/cutil/lib -lcutil_x86_64 -I test/NQU/cutil/inc -I test/LIB test/LIB/libor.cu
#nvcc ${NVCC_ARG} -o ${BIN_PATH}/lulesh test/lulesh/lulesh.cu -I test/lulesh
nvcc ${NVCC_ARG} -o ${BIN_PATH}/NQU -I test/NQU/cutil/inc -L test/NQU/cutil/lib -lcutil_x86_64 test/NQU/nqueen.cu
#nvcc ${NVCC_ARG} -o ${BIN_PATH}/RAY -L test/NQU/cutil/lib -lcutil_x86_64 -I test/NQU/cutil/inc -I test/RAY test/RAY/*.cpp test/RAY/rayTracing.cu
#nvcc ${NVCC_ARG} -o ${BIN_PATH}/recursiveGaussian -I test/recursiveGaussian test/recursiveGaussian/*.cu test/recursiveGaussian/*.cpp
#nvcc ${NVCC_ARG} -o ${BIN_PATH}/SNAP -I test/SNAP test/SNAP/sweep.cu
#nvcc ${NVCC_ARG} -o ${BIN_PATH}/STO -I test/NQU/cutil/inc -L test/NQU/cutil/lib -lcutil_x86_64 -I test/STO test/STO/*.cpp test/STO/storeGPU.cu test/STO/main.cu
