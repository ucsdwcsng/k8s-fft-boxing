%%%%%%%%%%%%%%% 2D Occupancy Plot %%%%%%%%%%%%%%%%
addpath('searchlight/')
startup;
cd ../DummyNomad
addpath('./')
startup;


DBName="SCISRS";
database_ip="scisrs_athenaeum";
database_port=6379;

disp('Event Listener Setup')
event_listener = Comm.sigEnergyBurstsDetected("SUB",database_ip,database_port);

disp('Reader Setup')
reader = Writer.rediSQLInterface(DBName, database_ip,database_port);

TableName = "Energy"; % Name of th e SQL Table to populate

count=0;
nbins=[300,200];
N = zeros(nbins(1),nbins(2),1);

th_c = 200;
eps = 1e-6;
th_p=0.01;

f_min=2350e6;f_max=2550e6;
bw_min=0;bw_max=30e6;

X_edge = f_min:(f_max-f_min)/nbins(1):f_max;
Y_edge = bw_min:(bw_max-bw_min)/nbins(2):bw_max;

box_fc_all=[];box_tc_all=[];box_bw_all=[];
while (true)
    disp('Listening for Event EnergyBurstsDetected')
    EnergyNames = event_listener.listen();

    box_fc=[];box_tc=[];box_bw=[];
    for i = 1:length(EnergyNames{1})
        Name = string(EnergyNames{1}{i});

        response=reader.read(TableName,{'FreqLo','FreqHi','TimeLo','TimeHi'},"Name="+strquote(Name));
        % print(response)
        fc = (str2double(response{1}{2}) + str2double(response{1}{1}))/2;
        tc = (str2double(response{1}{3}) + str2double(response{1}{4}))/2;
        bw = str2double(response{1}{2}) - str2double(response{1}{1});
        box_fc=[box_fc; fc];
        box_tc=[box_tc; tc];
        box_bw=[box_bw; bw];
    end
    box_fc_all=[box_fc_all; box_fc];
    box_tc_all=[box_tc_all; box_tc];
    box_bw_all=[box_bw_all; box_bw];

    N_=histcounts2(box_fc,box_bw,X_edge,Y_edge);    
    if count < th_c
        disp(num2str(count) + ": Learning Distribution")
        N = cat(3,N,N_);
    end
    if count == th_c
        disp(num2str(count) + ": Computing PDF")
        pdf_N = cell(nbins);
        pdf_bins = cell(nbins);
        for i = 1:nbins(1)
            for j = 1:nbins(2)
                [pdf_N{i,j},pdf_bins{i,j}] = histcounts(N(i,j,:));
                pdf_N{i,j} = pdf_N{i,j}/size(N,3);
            end
        end
        save('/tmp/N.mat');
        break;
    end
    if count > th_c
        disp(num2str(count) + ": Predicting probabiltiy of event")
        p=zeros(nbins);
        for i = 1:nbins(1)
            for j = 1:nbins(2)
                bin_indx = find(pdf_bins{i,j} < N_(i,j),1,'last');
                if isempty(bin_indx) || bin_indx > length(pdf_N{i,j})
                    p(i,j) = eps;
                else 
                    p(i,j) = pdf_N{i,j}(bin_indx);
                end
            end
        end
        event_prob = prod(  p,'all');
        rare_event_prob = p(p < th_p);
        if(any(p < th_p, 'all'))
            disp("anomaly detected")
            event_prob
            rare_event_prob
            [x,y] = ind2sub(nbins,find(p<th_p));
            
            for i_=1:length(x)
                disp("("+num2str(X_edge(x(i_)))+","+num2str(Y_edge(y(i_)))+")");
            end        
        end
    end


    %% calling garbage collector
    java.lang.Runtime.getRuntime().gc;
    count = count + 1;    
end
%%
I=zeros(nbins);
for i = 1:nbins(1)
    for j = 1:nbins(2)
        I(i,j) = -1*sum(pdf_N{i,j}.*log2(pdf_N{i,j}));
    end
end
%%
f_=figure();
%imshow(imresize(mean(N,3),[256, 512],'nearest'));
imagesc(sum(N,3)','CDataMode','auto')
% set(gca, 'YScale', 'log')
% set(gca, 'XScale', 'log')
title("Total Occupancy")
colorbar;
xlabel("Frequency (GHz)")
ylabel("Bandwidth (MHz)")
%set(gca,'YDir','reverse');
% view(2);
grid off;
%%
f_=figure();
%imshow(imresize(mean(N,3),[256, 512],'nearest'));
imagesc(mean(N,3)','CDataMode','auto')
% set(gca, 'YScale', 'log')
% set(gca, 'XScale', 'log')
title("Mean Occupancy")
colorbar;
xlabel("Frequency (GHz)")
ylabel("Bandwidth (MHz)")
%set(gca,'YDir','reverse');
% view(2);
grid off;
%%
f_=figure();
imagesc(std(N,0,3)');
% set(gca, 'YScale', 'log')
% set(gca, 'XScale', 'log')
title("Occupancy Standard Deviation")
colorbar;
xlabel("Frequency (GHz)")
ylabel("Bandwidth (MHz)")
% view(2);
grid off;
%%
f_=figure();
imagesc(I');
% set(gca, 'YScale', 'log')
% set(gca, 'XScale', 'log')
title("Information Content")
colorbar;
xlabel("Frequency (GHz)")
ylabel("Bandwidth (MHz)")
% view(2);
grid off;
