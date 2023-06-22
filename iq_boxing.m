%%%%%%%%%%%%%%% FFT Boxing 2D %%%%%%%%%%%%%%%%
addpath('searchlight/')
startup;

% basepath = getenv('BASEPATH');
% time_slice=str2double(getenv('TIME_SLICE')); % sec

basepath = '/home/skadaveru/Projects/scisrs/ucsd_datacollect/data';
time_slice=0.1; % sec

% Channelizer properties
Nch = 1024;
Nproto = 16;
detAlgo='conv';

tmp=dir(basepath);
tmp=tmp([tmp.isdir]);
archives=tmp(3:end);

for i_k = 1:length(archives)

    archive=archives(i_k).name;
    archive='survey-centralfreq-2475000000-gain-65-antenna-RX2';
    archive_path=basepath+'/'+archive;
    disp("Running on dir: " + archive)

    % Valid radios are 1-5
    num_radios = 1;
    % Only channel 0 is currently collected
    channel = 0;

    boxdir= archive_path+'/'+"box2d";
    if ~exist(boxdir, 'dir')
        mkdir(boxdir);
    end

    datafile = dir(archive_path+'/'+'fft-archive-0-0-0000.16sc');
    metadata= jsondecode(char(fread(fopen(archive_path+'/'+'fft-archive-0-0-0000.sigmf-meta'),inf)'));

    fs = metadata.global.core_sample_rate;
    ifnom = metadata.captures.core_frequency;

    total_samples = datafile.bytes/4;

    for radio_i=0:num_radios-1
        filename=sprintf("fft-archive-%d-%d-0000", radio_i,channel);
        fp = archive_path+'/'+filename+'.16sc';
        fid = fopen(fp);
        
        disp("Running file: " + string(filename))

        count = ceil(time_slice*fs);
        
        start=0;

        nChunk=ceil(total_samples/count);
        boxingResults = cell(nChunk, 1);
        for iChunk=1:nChunk
            % fseek(fid,file_offset,'bof');
            
            dataiq=read_complex_binary16(fp,count,start);
            start=start+count;

            elapsed = (iChunk-1)*count / fs;
            disp("Elapsed " + string(elapsed) +"s");
            
            P = PolyphaseChannelizer(Nch, fs, Nproto);
            gpuDataIQ = single(gpuArray(dataiq))/(2^15-1);
            meta_iq = processTestbedData(gpuDataIQ, P, detAlgo, true);

            boxingResults{iChunk} = meta_iq;

            boxingResults{iChunk}.channelizerData=[];
            java.lang.Runtime.getRuntime().gc;
        end
        save(boxdir+'/'+filename+'.mat','boxingResults','-v7.3');
    end
end