#!/usr/bin/env python3

# coding: utf-8
import os
import numpy as np
import matplotlib.pyplot as plt
from scipy import signal

fs = 1000 # sampling frequency
fc = 6    # cut-off frequency
t = np.arange(1000)/fs
sga = np.sin(2*np.pi*2*t)   # signal with f = 2
sgb = np.sin(2*np.pi*10*t)  # signal with f = 10
sgo = sga + sgb #+ (np.random.random(1000) - 0.5)

np.savetxt('original.doc', sgo)

#f = open('original.txt',encoding='utf-8')

#os.system('cat original.txt | zpsbwlpf.exe 1000 {:.2f} > filtered.txt'.format(fc/2))
'''
powershell 是cmd的超集，可以执行linux命令
这也是为什么在powershell中可以运行cat指令
但是本函数os.system默认调用的是cmd命令，没有cat指令，所以无法生成filtered
改用为cmd中的cat命令替换cat
'''
os.system('type original.doc | zpsbwlpf.exe 1000 {:.2f} > filtered.doc'.format(fc/2)) 

sgf1 = np.loadtxt('filtered.doc')

plt.plot(t, sgo, label = 'original')
plt.plot(t, sga, label = 'f = 2')
plt.plot(t, sgf1, 'r-', linewidth = 3, label = 'o4zpsbwlpf')

w = fc/fs
b, a = signal.butter(4, w, 'low')
sgf2 = signal.filtfilt(b, a, sgo)
sgf3 = signal.lfilter(b, a, sgo)
plt.plot(t, sgf2, label = 'filtfilt')
plt.plot(t, sgf3, 'k-', linewidth = 1.5, label = 'lfilter')

plt.legend()
plt.show()

os.system('rm -f original.doc filtered.doc')
