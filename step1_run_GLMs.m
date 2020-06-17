
%% 

close all; clearvars -except allses_design subj sessionstorun; clc;

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
sessionstorun = [1:15];
stimdur = 1;
tr = 2;

nses = 15;
runimgs = 37;

method = 'kendrick_pipeline_v4';

dataset = 'BOLD5000';
basedir = fullfile('/media','tarrlab','scenedata2');
eventdir = fullfile(basedir,'5000_BIDS',['sub-' subj]);
datadir = fullfile(basedir,'5000_BIDS','derivatives','fmriprep',['sub-' subj]);
savedir = fullfile(homedir,'betas',method);

opt = struct();
opt.wantlibrary=1;
opt.wantfileoutputs = [1 1 1 1];
opt.wantglmdenoise=1;
opt.wantlss=0;
opt.wantfracridge=1;

%%

for ses = sessionstorun
    
    %absolute_run = 1;
    
    if ses < 10
        sesstr = ['0' num2str(ses)];
    else
        sesstr = num2str(ses);
    end
    
    savedir = fullfile(savedir, subj, sesstr);
    
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
    
    opt.chunknum = size(img,1) * size(img,2) * size(img,3);
    opt.xvalscheme = {[1:2:length(design)] [2:2:length(design)]};
       
    results = GLMestimatesingletrial(design,data,stimdur,tr,savedir,opt);
    
end


