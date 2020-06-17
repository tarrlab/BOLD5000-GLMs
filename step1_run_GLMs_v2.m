%%

close all; clearvars -except allses_design subj sessionstorun overall_winners labels; clc;

%%

homedir = '/media/tarrlab/scenedata2/BOLD5000_GLMs/git/';
cd(homedir)

addpath(genpath('GLMdenoise'))
addpath(genpath('vistasoft'))
addpath(genpath('knkutils'))
addpath(genpath('fracridge'))

%% hyperparameters

subj = 'CSI2';

% define
sessionstorun = {[2,4,10]};%,[3,5,15],[8,11,12],[1,7,13],[6,9,14]};
k = 2;
%sessionstorun = {[6,7,9,10,12],[1,3,5,11,14],[2,4,8,13,15]};
%sessionstorun = overall_winners{1,3}; %[1:15]; num2cell(1:15);%
stimdur = 1;
tr = 2;

nses = 15;
runimgs = 37;

method = 'testing_xval_v3';

dataset = 'BOLD5000';
basedir = fullfile('/media','tarrlab','scenedata2');
eventdir = fullfile(basedir,'5000_BIDS',['sub-' subj]);
datadir = fullfile(basedir,'5000_BIDS','derivatives','fmriprep',['sub-' subj]);
savedir = fullfile(homedir,'betas',method);

normalize = 0;

opt = struct();
opt.wantlibrary=0;
opt.wantfileoutputs = [1 0 0 0];
opt.wantglmdenoise=0;
opt.wantlss=0;
opt.wantfracridge=0;
opt.wantmemoryoutputs=[0 0 0 0];

%%

for c = 1:length(sessionstorun)
    
    data_scheme = [];
    design_scheme = [];
    
    sessions = sessionstorun{c};
    
    savedir = fullfile(homedir,'betas',method, subj,['sessions_' strrep(strrep(num2str(sessions),' ','_'),'__','_')]);
    
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

%%
