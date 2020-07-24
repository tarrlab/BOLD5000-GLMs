
%%  exploring BOLD5000 design

% goals: 
% (1) plot number of repeated stimuli in each session
% (1b) identify best way to combine sessions to maximize repeats
% (2) compare meanvol values between sessions within subject to understand
%     how much drift there is
% (3) test out normalization method and see how that changes the data

dbstop if error

addpath('utilities')
addpath('GLMdenoise')
addpath('GLMdenoise/utilities')
addpath('fracridge/matlab')
addpath('nifti_tools')


%% hyperparameters 

subjs = {'CSI1', 'CSI2', 'CSI3'};
sessionstorun = 1:15;

homedir = pwd;
bidsdir = fullfile('/media','tarrlab','scenedata2','5000_BIDS');

%% directory and path management
close all;
figure;

subj_allses_design = [];

for i = 1:length(subjs)

    subj = subjs{i};
    
    cd(homedir)
    
    eventdir = fullfile(bidsdir,['sub-' subj]);
    datadir = fullfile(bidsdir,'derivatives','fmriprep',['sub-' subj]);
    
    assert(isdir(eventdir))
    assert(isdir(datadir))
    
    % load design matrix
    
    [design, allses_design] = load_BOLD5000_design(eventdir, sessionstorun);
        
    subj_allses_design = [subj_allses_design; allses_design];
    
    % plot number of repeats in each session
    within_run_repeats = cell(1,length(design));
    within_ses_repeats = cell(1,length(allses_design));
    
    ses_rep_instances = zeros(1,length(allses_design));
    
    for ses = sessionstorun
        d = allses_design{ses};
        reps = zeros(1,4916);
        counts = zeros(1,5);
        
        % sum up the run design matrices from the session along the TR axis
        for r = 1:length(d)
            reps = reps + sum(d{r},1);
        end
        
        % count the number of repeated conditions
        for j = 0:4
            counts(j+1) = sum(reps == j);
        end
        
        % assert correct number of trials
        if r == 10
            assert(counts(2) + counts(3)*2 + counts(4)*3 + counts(5)*4 == 370)
        elseif r == 9
            assert(counts(2) + counts(3)*2 + counts(4)*3 + counts(5)*4 == 333)
        end
        
        within_ses_repeats{ses} = counts;
        ses_rep_instances(ses) = counts(3) + counts(4)*2 + counts(5)*3;
              
    end
    
    subplot(1,3,i)
    bar(ses_rep_instances)
    ylim([0 10])
    title([subj ' # instances of' newline 'img reps within' newline 'each session'])
    
end

%%

nreps = 100;

scheme_lengths = [3 5];

subj_overall_winners = [];

for i = 1:length(subjs)
    allses_design = subj_allses_design(i,:);
    
    overall_winners = [];
    
    
    for sl = scheme_lengths
        
        summary = [];
        
        for rep = 1:nreps
            
            order = randperm(15);
            
            scheme = [];
            for q = 1:15/sl
                low = sl * (q-1) + 1;
                high = sl * (q-1) + sl;
                
                scheme = [scheme {sort(order(low:high))}];
            end
            
            ses_repeats = zeros(length(scheme),1);
            
            for s = 1:length(scheme)
                
                scheme_design = [];
                for d = 1:length(scheme{1})
                    scheme_design = [scheme_design allses_design{scheme{s}(d)}];
                end
                %scheme_design = [ allses_design{scheme{s}(2)} allses_design{scheme{s}(3)}];
                
                rep_counts = zeros(size(scheme_design{1}));
                
                for run = 1:length(scheme_design)
                    
                    rep_counts = rep_counts + scheme_design{run};
                    
                end
                
                ses_repeats(s) = sum(sum(rep_counts,1) > 1);
                
            end
            
            summary = [summary; {scheme sum(ses_repeats) ses_repeats}];
            
        end
        
        [maxreps,winner] = max(cell2mat(summary(:,2)));
        
        winning_scheme = summary{winner,1};
        winning_sesreps = summary{winner,3};
        
        for i = 1:length(winning_scheme)
            disp(winning_scheme{i})
        end
        
        overall_winners = [overall_winners; {sl maxreps winning_scheme winning_sesreps}];
        
    end

    subj_overall_winners = [subj_overall_winners; overall_winners];
    
end
%%

figure;
mapping = [1 3 5 2 4 6];
subjs_ = [subjs subjs];
for i = 1:6
    subplot(2,3,i)
    bar(subj_overall_winners{mapping(i),4})
    ylim([0 60])
    xticklabels(cellfun(@num2str,subj_overall_winners{mapping(i),3}, 'UniformOutput', 0))
    xtickangle(45)
    ylabel('nreps')
    title([subjs_{i} ' optimal' newline 'ses combos' newline num2str(subj_overall_winners{mapping(i),2}) ' reps total']);
end

%%

ses_meanvols = [];

subj = 'CSI3';

for ses = 1:15
    
    datadir = fullfile(bidsdir,'derivatives','fmriprep',['sub-' subj]);
    data =  load_BOLD5000_data(subj, datadir, ses);
    dims = size(data{1});
    meanvol = zeros(dims(1), dims(2), dims(3));
    for run = 1:length(data)
        meanvol = meanvol + mean(data{run},4);  
    end
     
    ses_meanvols = [ses_meanvols; {meanvol ./ length(data)}];
      
end    
    
%%
close all
figure('Color',[ 1 1 1], 'Position', [0 0 2000 1200]);
n = length(ses_meanvols);
c = 1;
for i = 1:3:n
    for j = 1:3:n
    
        p = polyfit(ses_meanvols{i}(:), ses_meanvols{j}(:), 1);
        f = polyval(p, ses_meanvols{i}(:));
        subplot(n/3,n/3,c)
        scatter(ses_meanvols{i}(:), ses_meanvols{j}(:), 1, 'k.','MarkerFaceAlpha',0.4,'MarkerEdgeAlpha',0.4);
        xlim([0 1500])
        ylim([0 1500])
        yticks([])
        axis square
        hold on
        plot([0:1500],[0:1500],'r','LineWidth',0.5)
        plot(ses_meanvols{i}(:), f, 'g', 'LineWidth',2);
        title(['y = ' num2str(p(1),4) 'x + ' num2str(p(2),4)])
        ylabel(['ses ' num2str(j)])
        xlabel(['ses ' num2str(i)])
        c = c+1;
    end
    
end

%%

mvs = zeros(dims(1)*dims(2)*dims(3),15);

for i = 1:length(ses_meanvols)
    mvs(:,i) = reshape(ses_meanvols{i}, [dims(1)*dims(2)*dims(3), 1]);
end

%%

gmv = mean(mvs,2);

for p = 1:size(mvs,2)
   a = mvs(:,p);
   
   sc = mvs(:,p)\gmv;
   mvs(:,p) = sc*mvs(:,p);
   b = mvs(:,p);
   
end

%%

close all
figure('Color',[ 1 1 1], 'Position', [0 0 2000 1200]);
n = length(ses_meanvols);
c = 1;
for i = 1:3:n
    for j = 1:3:n
    
        p = polyfit(mvs(:,i), mvs(:,j), 1);
        f = polyval(p, mvs(:,i));
        subplot(n/3,n/3,c)
        scatter(mvs(:,i), mvs(:,j), 1, 'k.','MarkerFaceAlpha',0.4,'MarkerEdgeAlpha',0.4);
        xlim([0 1500])
        ylim([0 1500])
        yticks([])
        axis square
        hold on
        plot([0:1500],[0:1500],'r','LineWidth',0.5)
        plot(mvs(:,i), f, 'g', 'LineWidth',2);
        title(['y = ' num2str(p(1),4) 'x + ' num2str(p(2),4)])
        ylabel(['ses ' num2str(j)])
        xlabel(['ses ' num2str(i)])
        c = c+1;
    end
    
end

%%

coefsA = zeros(n,n);
coefsB = zeros(n,n);

for i = 1:n
    for j = 1:n
        pA = polyfit(ses_meanvols{i}(:), ses_meanvols{j}(:), 1);
        pB = polyfit(mvs(:,i), mvs(:,j), 1);
        
        coefsA(i,j) = pA(1);
        coefsB(i,j) = pB(1);
        
    end
end

figure('Color',[1 1 1], 'Position',[0 0 2000 1200])
subplot(121)
imagesc(coefsA,[.9 1.1])
colorbar
axis square
xlabel('session')
ylabel('session')
title(['LR slope relating voxel intensities' newline 'between sessions'])

subplot(122)
imagesc(coefsB,[0.9 1.1])
colorbar
axis square
xlabel('session')
ylabel('session')
title(['LR slope relating voxel intensities' newline 'between sessions (with rescaling)'])

%%

coefsA = zeros(n,n);
coefsB = zeros(n,n);

for i = 1:n
    for j = 1:n
        pA = std(ses_meanvols{i}(:)) - std(ses_meanvols{j}(:));
        pB = std(mvs(:,i)) -  std(mvs(:,j));
        
        coefsA(i,j) = pA;
        coefsB(i,j) = pB;
        
    end
end

figure('Color',[1 1 1], 'Position',[0 0 2000 1200])
subplot(121)
imagesc(coefsA,[-20 20])
colorbar
axis square
xlabel('session')
ylabel('session')
title(['difference in whole-brain std. dev' newline 'between sessions'])

subplot(122)
imagesc(coefsB, [-20 20])
colorbar
axis square
xlabel('session')
ylabel('session')
title(['difference in whole-brain std. dev' newline 'between sessions (with rescaling)'])



