%%

function [] = run_GLMs(subj, sess, GLM_method)

dbstop if error

disp(['running for subject: ' subj])
disp(['running for session: ' sess])
disp(['running for method: ' GLM_method])

homedir = pwd;
basedir = fullfile('/media','tarrlab','scenedata2','5000_BIDS');

date = '07_13_20_v2';

opt = struct();

if strcmp(GLM_method,'assume')
    opt.wantlibrary=0;
    opt.wantfileoutputs = [1 1 0 0];
    opt.wantglmdenoise=0;
    opt.wantlss=0;
    opt.wantfracridge=0;
    opt.wantmemoryoutputs=[0 0 0 0];
    opt.method = [date '_assume'];
elseif strcmp(GLM_method, 'optimize')
    opt.wantlibrary=1;
    opt.wantfileoutputs = [1 1 1 1];
    opt.wantglmdenoise=1;
    opt.wantlss=0;
    opt.wantfracridge=1;
    opt.wantmemoryoutputs=[0 0 0 0];
    opt.method = date;
end

opt.chunknum = 100000;

opt.subj = subj;
opt.sessionstorun = {[str2num(sess)]};
opt.loocv = 1;
opt.k = 2;

cd(homedir)

eventdir = fullfile(basedir,['sub-' subj]);
datadir = fullfile(basedir,'derivatives','fmriprep',['sub-' subj]);
savedir = fullfile(homedir);

assert(isdir(basedir))
assert(isdir(eventdir))
assert(isdir(datadir))
assert(isdir(savedir))

disp('adding utility folders to path...')
tic;
%addpath(genpath
addpath('GLMdenoise')
addpath('GLMdenoise/utilities')
addpath('fracridge/matlab')
addpath('knkutils/io')
addpath('knkutils/mri')
addpath('knkutils/programming')
addpath('knkutils/stats')
addpath('knkutils/timeseries')
addpath('knkutils/string')
addpath('knkutils/pt')
addpath('knkutils/math')
addpath('knkutils/matrix')
addpath('knkutils/imageprocessing')
addpath('knkutils/graphic')
addpath('knkutils/figure')
addpath('knkutils/external')
addpath('knkutils/colormap')
addpath('knkutils/indexing')
addpath('vistasoft/external/NIfTI_Shen')

disp('done')
toc;

%% more hyperparameters

tic;

% define
stimdur = 1;
tr = 2;

nses = 15;
runimgs = 37;
runtrs = 194;

method = opt.method;

% define
sessionstorun = opt.sessionstorun;

%% Accumulate event info for all sessions

disp('accumulating event info...')

allses_events = [];

ses_event_table = [];

ses_nruns = [];

for ses = 1:nses
    
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
        rundur = runtrs; %size(events{i},4);
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


%% get indices of repeated images

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

%% create design matrices where each image is its own condition (4916 total)
% note: repeats do not get their own condition ID

allses_design = [];

for ses = 1:nses
    
    output_design = [];
    
    n = ses_nruns(ses);
    
    for i = 1:n
        
        runidx = ses_event_table.Sess == ses & ses_event_table.Run == i;
        
        conds = labels(runidx);
        
        % load event info, compute onset TRs
        rundur = runtrs; 
        
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

disp('done')

%% load data from all sessions

for c = 1:length(sessionstorun)
    
    data_scheme = [];
    design_scheme = [];
    
    sessions = sessionstorun{c};
    
    disp(['loading data for sessions ' num2str(sessions)])
    
    savedir = fullfile(homedir,'betas',method, subj,['sessions_' strrep(strrep(strrep(num2str(sessions),' ','_'),'__','_'),'__','_')]);
    
    disp(['savedir: ' savedir])
    
    for ses = sessions
        
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
        
            disp('need to unzip data files...')
            
            targetdir = fullfile('bold',['sub-' subj],['ses-' sesstr]);
            
            if ~isdir(targetdir)
                mkdir(targetdir)
            end
            
            files0 = matchfiles(fullfile(subdatadir,'*run*_preproc.nii.gz'));
            maskfiles0 = matchfiles(fullfile(subdatadir,'*_brainmask.nii.gz'));
            if length(files0) == 0
                disp(subdatadir)
                error('no files found.')
            end
            
            % unzip files and put .nii data into bold dir, if necessary
            for p=1:length(files0)
                fn = files0{p};
                fn = strsplit(fn,'/');
                fn = fn{end};
                fn = fn(1:end-3);
                disp(['file is ' fn '. checking for existence in ' targetdir])
                if ~exist(fullfile(targetdir,fn),'file')
                    disp('file does not exist. gunzipping')
                    disp(['unzipping file ' num2str(p) ' to ' targetdir])
                    gunzip(files0{p},targetdir);
                    gunzip(maskfiles0{p},targetdir);
                else
                    disp('file exists. skipping gunzip')
                end
            end
            
            subdatadir = targetdir;
            
            disp('finished unzipping data files...')
        end
        
        files0 = matchfiles(fullfile(subdatadir,'*run*_preproc.nii'));
        maskfiles0 = matchfiles(fullfile(subdatadir,'*_brainmask.nii'));
        
        disp('loading data...')
        % load data
        data = {};
        for p=1:length(files0)
            disp(p)
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
        disp('done loading data')
        
        % check sanity
        design = allses_design{ses};
        
        assert(length(data)==length(design));
        
        data_scheme = [data_scheme data];
        design_scheme = [design_scheme design];
        
    end
    
    disp(['running GLM for sessions ' num2str(sessions)])

    disp('chunknum:')
    disp(opt.chunknum)
    
    if opt.loocv == 0
    
        opt.xvalscheme = [];

        k = opt.k;
        for x = 1:k
            opt.xvalscheme = [opt.xvalscheme {[x:k:length(design_scheme)]}];
        end

        disp('xvalscheme:')
        disp(opt.xvalscheme)
    else
        disp('using leave-one-run-out cv')
    end
    
    toc;
    disp('finished setup')
    tic;
    
    results = GLMestimatesingletrial(design_scheme,data_scheme,stimdur,tr,savedir,opt);
    
    disp('done with call to GLMestimatesingletrial')
end

disp('done with all GLMs.')

toc;

end

%%
