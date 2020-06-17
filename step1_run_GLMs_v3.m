%%

close all; clear; clc;

opt = struct();
opt.wantlibrary=1;
opt.wantfileoutputs = [1 1 0 0];
opt.wantglmdenoise=0;
opt.wantlss=0;
opt.wantfracridge=0;
opt.wantmemoryoutputs=[0 0 0 0];

opt.subj = 'CSI3';
opt.method = 'test2';
opt.sessionstorun = {[1,10,15]};
opt.k = 2;

results = run_GLMs(opt);

%%

function [results] = run_GLMs(opt)

homedir = '/media/tarrlab/scenedata2/BOLD5000_GLMs/git/';
cd(homedir)

addpath(genpath('GLMdenoise'))
addpath(genpath('vistasoft'))
addpath(genpath('knkutils'))
addpath(genpath('fracridge'))

%% hyperparameters

subj = opt.subj;

% define
stimdur = 1;
tr = 2;

nses = 15;
runimgs = 37;

method = opt.method;

dataset = 'BOLD5000';
basedir = fullfile('/media','tarrlab','scenedata2');
eventdir = fullfile(basedir,'5000_BIDS',['sub-' subj]);
datadir = fullfile(basedir,'5000_BIDS','derivatives','fmriprep',['sub-' subj]);
savedir = fullfile(homedir);

% define
sessionstorun = opt.sessionstorun; %{[2,4,10]};%,[3,5,15],[8,11,12],[1,7,13],[6,9,14]};
k = opt.k;
%sessionstorun = {[6,7,9,10,12]};%,[1,3,5,11,14],[2,4,8,13,15]};
%sessionstorun = overall_winners{1,3}; %[1:15]; num2cell(1:15);%

normalize = 0;


%%

allses_events = [];

ses_event_table = [];

ses_nruns = [];

for ses = 1:15
    
    
    absolute_run = 1;
    
    if ses < 10
        sesstr = ['0' num2str(ses)];
    else
        sesstr = num2str(ses);
    end
    
    disp(['loading session ' sesstr])
    
    subeventdir = fullfile(eventdir,['ses-' sesstr],'func');
    
    eventfiles = struct2table(dir(subeventdir));
    eventfiles = eventfiles(~eventfiles.isdir,:).name;
    eventfiles = eventfiles(contains(eventfiles,'events.tsv') & ~contains(eventfiles,'localizer'));
    
    ses_nruns(ses) = length(eventfiles);
    
    events = cell(1,length(eventfiles));
    design = cell(1,length(eventfiles));
    
    nconditions = runimgs * length(design);
    
    for i = 1:length(eventfiles)
        
        % load event info, compute onset TRs
        rundur = 194; %size(events{i},4);
        events{i} = tdfread(fullfile(subeventdir,eventfiles{i}));
        events{i}.ImgType = cell(size(events{i}.ImgType,1),1);
        ses_event_table = [ses_event_table; struct2table(events{i})];
        onsetTRs = round(events{i}.onset./tr)+1;
        
        % for now, treat each image as its own condition
        conds = events{i}.Trial + (runimgs * (absolute_run-1));
        
        % sanity
        assert(length(onsetTRs) == length(conds))
        
        % populate design matrix for that run
        design{i} = sparse(rundur, nconditions);
        
        for j = 1:runimgs
            design{i}(onsetTRs(j), conds(j)) = 1; % important, for single trial every entry gets its cond
        end
        
        absolute_run = absolute_run + 1;
        
    end
    
    tmp = [];
    for k = 1:length(events)
        tmp = [tmp; events{k}.ImgName];
    end
    
    allses_events{ses} = tmp;
    
end


%%

reps = zeros(size(ses_event_table,1),1);
idx = 1;
labels = zeros(size(ses_event_table,1),1);
seen_imgs = {};

for i = 1:size(ses_event_table,1)
    
    curr = ses_event_table(i,:).ImgName;
    
    if i > 1 && ismember(curr,seen_imgs)
        repidx = find(ismember(seen_imgs,curr),1);
        labels(i) = repidx;
        reps(repidx) = reps(repidx) + 1;
    else
        labels(i) = idx;
        reps(idx) = reps(idx) + 1;
        idx = idx + 1;          
    end
    
    if i == 1
        seen_imgs = {curr};
    else
        seen_imgs = [seen_imgs; curr];
    end
   
end

%%

allses_design = [];

for ses = 1:15
    
    output_design = [];
    
    n = ses_nruns(ses);
    
    for i = 1:n
        
        runidx = ses_event_table.Sess == ses & ses_event_table.Run == i;
        
        conds = labels(runidx);
        
        % load event info, compute onset TRs
        rundur = 194; %size(events{i},4);
        
        onsetTRs = round(ses_event_table(runidx,:).onset./tr)+1;
        
        % sanity
        assert(length(onsetTRs) == length(conds))
        
        % populate design matrix for that run
        output_design{i} = sparse(rundur, length(unique(labels)));
        
        for j = 1:length(conds)
            output_design{i}(onsetTRs(j), conds(j)) = 1; % important, for single trial every entry gets its cond
        end
        
    end
    
    allses_design{ses} = output_design;
    
end


%%

for c = 1:length(sessionstorun)
    
    data_scheme = [];
    design_scheme = [];
    
    sessions = sessionstorun{c};
    
    savedir = fullfile(homedir,'betas',method, subj,['sessions_' strrep(strrep(strrep(num2str(sessions),' ','_'),'__','_'),'__','_')]);
    
    for ses = sessions
        
        %absolute_run = 1;
        
        if ses < 10
            sesstr = ['0' num2str(ses)];
        else
            sesstr = num2str(ses);
        end
        
        disp(['loading session ' sesstr])
        
        subdatadir = fullfile(datadir,['ses-' sesstr],'func');
        subeventdir = fullfile(eventdir,['ses-' sesstr],'func');
        
        datafiles = struct2table(dir(subdatadir));
        datafiles = datafiles(~datafiles.isdir,:).name;
        datafiles = datafiles(contains(datafiles,'_preproc.nii.gz') & ~contains(datafiles,'localizer'));
        
        % figure out runs
        files0 = matchfiles(fullfile(subdatadir,'*run*_preproc.nii'));
        maskfiles0 = matchfiles(fullfile(subdatadir,'*_brainmask.nii'));
        
        if size(files0,1) == 0 || size(maskfiles0,1) == 0
            files0 = matchfiles(fullfile(subdatadir,'*run*_preproc.nii.gz'));
            maskfiles0 = matchfiles(fullfile(subdatadir,'*_brainmask.nii.gz'));
            for p=1:length(files0)
                gunzip(files0{p});
                gunzip(maskfiles0{p});
            end
        end
        
        files0 = matchfiles(fullfile(subdatadir,'*run*_preproc.nii'));
        maskfiles0 = matchfiles(fullfile(subdatadir,'*_brainmask.nii'));
        
        % load data
        data = {};
        for p=1:length(files0)
            a1 = load_nii(files0{p});
            img = single(a1.img);
            
            % load brain mask
            mask = load_nii(maskfiles0{p});
            for i=1:size(img,4)
                thisimg = squeeze(img(:,:,:,i));
                thisimg(mask.img==0) = 0;
                img(:,:,:,i) = thisimg;
            end
            data{p} = img;
        end
        clear a1;
        
        % check sanity
        design = allses_design{ses};
        
        assert(length(data)==length(design));
        
        data_scheme = [data_scheme data];
        design_scheme = [design_scheme design];
        
    end
    
    
    
    if normalize == 1
        ses_means = [];
        ses_stds = [];
        for i = 1:length(data_scheme)
            ses_means = [ses_means; nanmean(data_scheme{i}(:))];
            ses_stds = [ses_stds; nanstd(data_scheme{i}(:))];
        end
        
        allses_mean = nanmean(ses_means);
        allses_std = nanmean(ses_stds);
        
        for i = 1:length(data_scheme)
            curr_mean = nanmean(data_scheme{i}(:));
            curr_std = nanstd(data_scheme{i}(:));
            data_scheme{i} = (data_scheme{i}-curr_mean) .* (allses_std/curr_std) + allses_mean;
        end
    end
    opt.chunknum = ceil(size(img,1) * size(img,2) * size(img,3) / (length(sessions)));
    
    opt.xvalscheme = [];
    
    for x = 1:k
        opt.xvalscheme = [opt.xvalscheme {[x:k:length(design_scheme)]}];
    end
    
    results = GLMestimatesingletrial(design_scheme,data_scheme,stimdur,tr,savedir,opt);
    
end

end

%%
