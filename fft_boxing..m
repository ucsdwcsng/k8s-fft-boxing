%%%%%%%%%%%%%%% FFT Boxing 2D %%%%%%%%%%%%%%%%
addpath('searchlight/')
startup;

basepath = getenv('BASEPATH');
time_slice=getenv('TIME_SLICE'); % sec

files=dir(basepath);
is_dir=[files.isdir];
dirs=files(is_dir);

survey={dirs(3:end).name};


for i=1:length(survey)
    
    archive=survey{i};

    archive_path=basepath+'/'+archive;

    disp("Running on dir: " + archive)
    
    % Valid radios are 1-5
    num_radios = 5
    % Only channel 0 is currently collected
    channel = 0
    
    boxdir= archive_path+'/'+"box2d"
    if ~exists(boxdir, 'dir'):
        mkdir(boxdir)
    end
    
    datafile = dir(archive_path+'/'+'fft-archive-0-0-0000.sigmf-data');
    metafile_json = jsondecode(char(fread(fopen(archive_path+'/'+'fft-archive-0-0-0000.sigmf-meta'),inf)'));

    nfft = metadata.global.scisrs_fft_size;
    fs = metadata.global.core_sample_rate;
    ifnom = metadata.captures.core_frequency;
    
    total_samples = datafile.bytes/4;
    
    for radio_i=1:num_radios:
        filename=sprintf("fft-archive-%d-%d-0000", radio_i,channel);
        fp = archive_path+'/'+filename+'.sigmf-data';
        fid = fopen(fp);
        
        count = ceil(time_slice*fs/nfft)*nfft;
        
        nChunk=ceil(total_samples/count)
        boxingResults = cell(nChunk, 1);
        for iChunk=1:nChunk
            % fseek(fid,file_offset,'bof');
            
            data=fread(fid,count,'float')
            data = reshape(data, nfft, []).';
            data = fftshift(data, 2);
            
            elapsed = (iChunk-1)*count / fs
            disp("Elapsed " + str(elapsed) +"s")
            
            dataChan = ChannelizerData(data, fs/nfft, getIJVector(nfft, 1, fs/nfft), elapsed);
            dataChan.isAlreadyPower = true;
            c = ConvContextualize(dataChan);
            c.process;
            c.plotFinalBoxes;
            boxingResults{iChunk} = BoxingResults(dataChunk, ...
                c.centerArray_Hz - c.widthArray_Hz/2, ...
                c.centerArray_Hz + c.widthArray_Hz/2, ...
                c.centerArray_s - c.heightArray_s/2, ...
                c.centerArray_s + c.heightArray_s/2, ...
                c.aboveNoiseFloorRaw_dB, ...
                c.aboveNoiseFloorProcessed_dB);
        end
        save(boxdir+'/'+filename+'.mat','boxingResults');
    end
end