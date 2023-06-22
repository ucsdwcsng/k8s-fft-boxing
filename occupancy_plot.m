%%%%%%%%%%%%%%% 2D Occupancy Plot %%%%%%%%%%%%%%%%
addpath('searchlight/')
startup;

% need to change this based on your system
% basepath = getenv('BASEPATH');
basepath = '/home/skadaveru/Projects/scisrs/ucsd_datacollect/data';
disp("Running on basepath: " + basepath)
 
% valid path archive from day2 ECTB Collects
out=regexp(basepath,'/','split');
dirname= out{end};

surveys = dir(basepath);
surveys = surveys([surveys.isdir]);
surveys = surveys(3:end);

pattern_parse ='survey-centralfreq-(\d+)-gain-(\d+)-antenna-(\w+)';

% Valid radios are 1-5
num_radios = 1;
% Only channel 0 is currently collected
channel = 0;

box_fc_all=[];box_tc_all=[];box_bw_all=[];
for radio_i = 0:num_radios-1
    box_fc=[];box_tc=[];box_bw=[];
    for j=1:length(surveys)
        capture_name = surveys(j).name;

        match= regexp(capture_name, pattern_parse, 'tokens');
        fc= str2double(match{1}{1});
        gain= str2double(match{1}{2});
        antenna= string(match{1}{3});
        
        % plt.title("Snapshot FFTs (dB)")
        fname=sprintf("fft-archive-%d-%d-0000",radio_i,channel);
        fullfname = basepath+"/"+capture_name+"/"+'box2d'+"/"+fname+'.mat';
        
        load(fullfname, 'boxingResults');
        
        for k= 1:length(boxingResults)
            box_fc=[box_fc; boxingResults{k}.refMark(:,1)+ fc];
            box_tc=[box_tc; boxingResults{k}.refMark(:,2)];
            box_bw=[box_bw; boxingResults{k}.freqHi - boxingResults{k}.freqLo];
        end
    end
    box_fc_all=[box_fc_all; box_fc];
    box_tc_all=[box_tc_all; box_tc];
    box_bw_all=[box_bw_all; box_bw];
    
    nbins=[300,200];

    f_=figure();
    hist3(([box_fc/1e9,box_bw/1e6]),'Nbins',nbins,'CDataMode','auto','FaceColor','interp','LineStyle','none');
    % set(gca, 'YScale', 'log')
    % set(gca, 'XScale', 'log')
    colorbar;
    xlabel("Frequency (GHz)")
    ylabel("Bandwidth (MHz)")
    % view(2);
    grid off;
    
    %% calling garbage collector
    java.lang.Runtime.getRuntime().gc;
        
    savefig_file = basepath+'/'+dirname+sprintf("-%d-%d",radio_i,channel)+'.png';
    disp("Saving PNG: "+ savefig_file);
    % export_fig(savefig_file,'-m2.5','-transparent'); 
end

indx=find(box_bw_all ~= 100e6);
box_fc_all = box_fc_all(indx);
box_bw_all = box_bw_all(indx);


f_=figure();
hist3(([box_fc_all/1e9,box_bw_all/1e6]),'Nbins',nbins,'CDataMode','auto','FaceColor','interp','LineStyle','none');
% set(gca, 'YScale', 'log')
% set(gca, 'XScale', 'log')
colorbar;
xlabel("Frequency (GHz)")
ylabel("Bandwidth (MHz)")
% view(2);
grid off;

%% calling garbage collector
java.lang.Runtime.getRuntime().gc;
    
savefig_file = basepath+'/'+dirname+'_all'+'.png';
disp("Saving PNG: "+ savefig_file);
% export_fig(savefig_file,'-m2.5','-transparent'); 
