%%%%%%%%%%%%%%% FFT Boxing 2D %%%%%%%%%%%%%%%%
addpath('searchlight/')
startup;

basepath = getenv('BASEPATH');
time_slice=str2double(getenv('TIME_SLICE')); % sec

% basepath = '/tmp/soi-sc16-lo-scaled';
% time_slice=0.1; % sec

tmp=split(basepath, '/');
archive=tmp(end);
archive_path=basepath;
disp("Running on dir: " + archive)

% Valid radios are 1-5
num_radios = 5;
% Only channel 0 is currently collected
channel = 0;

boxdir= archive_path+'/'+"box2d";
if ~exist(boxdir, 'dir')
    mkdir(boxdir);
end

datafile = dir(archive_path+'/'+'fft-archive-0-0-0000.sigmf-data');
metadata= jsondecode(char(fread(fopen(archive_path+'/'+'fft-archive-0-0-0000.sigmf-meta'),inf)'));

nfft = metadata.global.scisrs_fft_size;
fs = metadata.global.core_sample_rate;
ifnom = metadata.captures.core_frequency;

total_samples = datafile.bytes/4;

for radio_i=0:num_radios-1
    filename=sprintf("fft-archive-%d-%d-0000", radio_i,channel);
    fp = archive_path+'/'+filename+'.sigmf-data';
    fid = fopen(fp);
    
    disp("Running file: " + string(filename))

    count = ceil(time_slice*fs/nfft)*nfft;
    
    nChunk=ceil(total_samples/count);
    boxingResults = cell(nChunk, 1);
    for iChunk=1:nChunk
        % fseek(fid,file_offset,'bof');
        
        data=fread(fid,count,'float');
        data = reshape(data, nfft, []).';
        data = fftshift(data, 2);
        
        elapsed = (iChunk-1)*count / fs;
        disp("Elapsed " + string(elapsed) +"s");
        
        dataChan = ChannelizerData(data, fs/nfft, getIJVector(nfft, 1, fs/nfft), elapsed);
        dataChan.isAlreadyPower = true;
        c = ConvContextualize(dataChan);
        c.process;
        % c.plotFinalBoxes;
        boxingResults{iChunk} = BoxingResults(dataChan, ...
            c.centerArray_Hz - c.widthArray_Hz/2, ...
            c.centerArray_Hz + c.widthArray_Hz/2, ...
            c.centerArray_s - c.heightArray_s/2, ...
            c.centerArray_s + c.heightArray_s/2, ...
            c.aboveNoiseFloorRaw_dB, ...
            c.aboveNoiseFloorProcessed_dB);         

        boxingResults{iChunk}.channelizerData=[];
        java.lang.Runtime.getRuntime().gc;
    end
    save(boxdir+'/'+filename+'.mat','boxingResults','-v7.3');
end