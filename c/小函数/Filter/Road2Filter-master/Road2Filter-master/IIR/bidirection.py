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

w = fc/fs
b, a = signal.butter(4, w, 'low')

sgf1 = signal.lfilter(b, a, sgo)
sgf1 = sgf1[ : : -1]
sgf1 = signal.lfilter(b, a, sgf1)
sgf1 = sgf1[ : : -1]

plt.plot(t, sgo, label = 'original')
plt.plot(t, sga, label = 'f = 2')
plt.plot(t, sgf1, 'r-', linewidth = 3, label = 'bidirectional')

sgf2 = signal.filtfilt(b, a, sgo)
sgf3 = signal.lfilter(b, a, sgo)
plt.plot(t, sgf2, label = 'filtfilt')
plt.plot(t, sgf3, 'k-', linewidth = 1.5, label = 'lfilter')

plt.legend()
plt.show()
