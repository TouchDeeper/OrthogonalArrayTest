# encoding: utf-8

import os
import numpy as np
import subprocess

orthogonal_array = np.loadtxt('data/L64_4_21.txt', int)
print(orthogonal_array)
factor_level = [[13, 14, 15, 16],  # acc_n
                [13, 14, 15, 18],  # acc_w
                [11, 12, 13, 14],  # gyr_n
                [11, 12, 13, 14]]  # gyr_w
imu_init_parameter = [0.08, 0.004, 0.00004, 2.0e-6]
factor_col = [0, 1, 5, 10]  # factor corresponding column in orthogonal array.
run_num = 27
mid_index = (run_num-1)/2
factor_level_value = []
index = 0
for array in factor_level:
    value = []
    for i in array:
        power = i - mid_index
        scale = 2**power
        # print(factor_level.index(array))
        value.append(imu_init_parameter[index] * scale)
    factor_level_value.append(value)
    index += 1
print(factor_level_value)

imu_parameter = [0, 0, 0, 0]
# test_num = 0
f = open("script/imu_parameters_array.txt", 'w')
for array in orthogonal_array:
    print("array = ", array)
    for i in range(len(factor_col)):
        imu_parameter[i] = factor_level_value[i][array[factor_col[i]]-1]
        f.write(str(imu_parameter[i]))
        f.write(" ")
    f.write("\n")
    # print(imu_parameter)
    # acc_n = imu_parameter[0]
    # acc_w = imu_parameter[1]
    # gyr_n = imu_parameter[2]
    # gyr_w = imu_parameter[3]
    # status = os.system('./script/orthogonal.sh ' + str(acc_n)
    # + " " + str(acc_w) + " " + str(gyr_n) + " " + str(gyr_w))

    # test_num += 1

    # command = './script/orthogonal.sh ' + str(acc_n) + " " + str(acc_w) + " " \
    #           + str(gyr_n) + " " + str(gyr_w) + " " + str(test_num)
    # process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE)
    # process.wait()
    # print(process.returncode)

# print(status)

# print(status >> 8)
