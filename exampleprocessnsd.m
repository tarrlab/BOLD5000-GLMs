% skeleton of a script..


addpath('utilities')
addpath('GLMdenoise')
addpath('GLMdenoise/utilities')
addpath('fracridge/matlab')
addpath('nifti_tools')

debug_mode = 1;

subjix = str2num(subj);  % 1-8
sessix = str2num(sess);  % 1-10
subj = ['subj0' num2str(subjix)];
nruns = 12;

if sessix < 10
    sesstr = ['0' num2str(sessix)];
else
    sesstr = num2str(sessix);
end

% load data (12 runs)
datadir = ['/lab_data/tarrlab/common/datasets/NSD/nsddata_timeseries/ppdata/' subj '/func1pt8mm/timeseries/'];
assert(isdir(datadir))

data = [];

for run = 1:nruns
    if run < 10
        runstr = ['0' num2str(run)];
    else
        runstr = num2str(run);
    end
    fn = fullfile(datadir,['timeseries_session' sesstr '_run' runstr '.nii.gz'])
    assert(isfile(fn))
    nii = load_compressed_nii(fn);
    img = single(nii.img);
    data{run} = img;
    
    if debug_mode == 1
        subslices = 50; %floor(dims(3)*29/60):floor(dims(3)*31/60);
        data{run} = data{run}(:,:,subslices,:);
    end
    
    disp(size(data{run}))
end

a1 = load('NSDdesign.mat');
design = a1.alldesign{subjix,sessix};

assert(length(design) == length(data))

%
stimdur = 3;
tr = 4/3;  % for the 1.8mm prep, 1.333-s TR -> 3 volumes per stimulus trial (4s)

% ??? customize??
clear opt;
opt.fracs = [];  %fliplr([.05:.05:.90 .91:.01:1]);  % so we have finer grain at the non-regularized end
opt.xvalscheme = [];  % {[1 2] [3 4] [5 6] [7 8] [9 10] [11 12]};
opt.wantlibrary=1;
opt.wantfileoutputs = [1 1 1 1];
opt.wantglmdenoise=1;
opt.wantlss=0;
opt.wantfracridge=1;
opt.wantmemoryoutputs=[0 0 0 0];

tic
results = GLMestimatesingletrial(design,data,stimdur,tr,'/home/jacobpri/git/BOLD5000-GLMs/betas/nsdtest-opt-v2/',opt);
toc
