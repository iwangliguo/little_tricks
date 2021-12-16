#-*-encoding:utf-8-*-
#去除从示波器中读取数据的所设置的偏差
#原文链接：https://blog.csdn.net/NORTHhan/article/details/81218860
import os
import pandas as pd
import numpy as np

for info in os.listdir(r'I:\安静\sensorless实验波形\table'):  #待处理文件所在的路径
    #domain = os.path.abspath(r'I:\安静\sensorless实验波形\table') #获取文件夹的路径
    #print(domain)
    #info = os.path.join(domain,info) #将路径与文件名结合起来就是每个文件的完整路径 
    if not os.path.isdir(info): #跳过文件夹
        if (info.lower()).startswith("delta") and (info.lower()).endswith(".csv"):  #只检查需要去偏置的CSV文件，设置筛选条件  
            data = pd.read_csv(info)
            #data = pd.read_csv(r'delta_Ibeta_LPF_2.6Nm_27rpm_HFSI_2.CSV')
            #print(data.columns)#获取列索引值
            #print(data.columns[1])#获取列索引值
            #读取待操作列头
            data_with_offset_header = data.columns[1]
            data_with_offset_series = data[data_with_offset_header]
            #操作列-去除偏置
            data_with_offset_array = np.array(data_with_offset_series)
            data_rm_offset_array = data_with_offset_array - 1.5  #偏置为1.5

            data_rm_offset_list = list(data_rm_offset_array)
            data_rm_offset_series = pd.Series(data_rm_offset_list)

            data[data_with_offset_header+"_no_offset"] = data_rm_offset_series 
            #print(data.columns)
            data.to_csv(info,mode = 'w',index =False)

#print(data_rm_offset_list)
