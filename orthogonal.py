# encoding: utf-8

import os
import numpy as np

orthogonal_array = np.loadtxt('data/L64_4_21.txt')
print(orthogonal_array)
factor_level = [[13, 14, 15, 16],  # acc_n
                [13, 14, 15, 18],  # acc_w
                [11, 12, 13, 14],  # gyr_n
                [11, 12, 13, 14]]  # gyr_w
imu_parameter = [0.08, 0.004, 0.00004, 2.0e-6]
run_num = 27
mid_index = (run_num-1)/2
factor_level_value = []
index = 0
for array in factor_level:
    value = []
    for i in array:
        power = i - mid_index
        scale = 2**power
        print(factor_level.index(array))
        value.append(imu_parameter[index] * scale)
    factor_level_value.append(value)
    index += 1

print(factor_level_value)
status = os.system('sh script/orthogonal.sh ')

print(status)

print(status >> 8)