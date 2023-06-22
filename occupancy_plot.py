from fileinput import filename
from math import ceil, floor
import os
from os import listdir
from os.path import isfile, join

import gc
import json
import numpy as np
import h5py

import glob
import re

import matplotlib
matplotlib.use('Agg')
from matplotlib import pyplot as plt



# need to change this based on your system
basepath = os.getenv("BASEPATH")
# basepath = 'soi-sc16-l1o-scaled'
print(f"Running on basepath: {basepath}")

# valid path archive from day2 ECTB Collects
surveys = [d for d in os.listdir(path=basepath) if os.path.isdir(basepath+'/'+d)];

pattern_parse =re.compile('survey-centerfreq-(\d+)-gain-(\d+)-antenna-(\w)');

# Valid radios are 1-5
num_radios = 5
# Only channel 0 is currently collected
channel = 0

for radio_i in range(num_radios):
    fig,axes = plt.subplots(ncols=num_radios,sharex=True,sharey=True,figsize=(8*num_radios, 12), dpi=80)
    
    for capture_name in surveys:
        
        match= pattern_parse.match(capture_name);
        fc= float(match.group(0));
        gain= float(match.group(1));
        antenna= str(match.group(1));
        
        # plt.title("Snapshot FFTs (dB)")
        fname = os.path.join(basepath, capture_name, f"fft-archive-{radio_i}-{channel}-0000.sigmf-data");

        f = h5py.File(filename,'r')
        boxingResults = f.get('boxingResults')
        boxingResults = list(boxingResults)

        box_fc=[]
        for i in range(len(boxingResults)):
            


        nsamples = buff.size
        elpased = file_offset /fs

        print(f"Snapshot Duration: {elpased} s")
        reshaped = np.reshape(buff, (-1, nfft))[0:nfft]
        reshaped = np.fft.fftshift(reshaped, 1)
        reshaped_log = 20 * np.log10(reshaped + 1e-10)

        freqs = np.fft.fftshift(np.fft.fftfreq(nfft)) * fs + ifnom

        axes[radio_i].imshow(reshaped_log, aspect='auto', interpolation='none', extent=[freqs[0], freqs[-1], buff.size/nfft, 0])
        axes[radio_i].title.set_text(f"R{radio_i}")
        # print("plotted")
        
        ## calling garbage collector
        gc.collect()
            
        # plt.colorbar()
        plt.xlabel("Frequency (hz)")
        plt.ylabel("Time")

        print(f"Saving PNG: {capture_name+f'_{floor(elpased)}s.png'}")
        savefig_path = pngdir;
        plt.savefig(savefig_path+'/'+capture_name+f'_{floor(elpased)}s.png')
        fig.clf()
        
        file_offset+=count;
        cnt+=1;
        
        