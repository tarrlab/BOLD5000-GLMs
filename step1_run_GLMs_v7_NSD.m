% skeleton of a script..

function [] = run_GLMs(subj, sess, GLM_method)

date = '09_08_20_one-sess_NSD';

addpath('utilities')
addpath('GLMdenoise')
addpath('GLMdenoise/utilities')
addpath('fracridge/matlab')
addpath('nifti_tools')

debug_mode = 0;

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

subjix = str2num(subj);  % 1-8
sessix = str2num(sess);  % 1-10
subj = ['subj0' subj];
nruns = 12;

if sessix < 10
    sesstr = ['0' sess];
else
    sesstr = sess;
end

% load data (12 runs)
datadir = ['/lab_data/tarrlab/common/datasets/NSD/nsddata_timeseries/ppdata/' subj '/func1pt8mm/timeseries/'];
assert(isdir(datadir))

homedir = pwd;
savedir = fullfile(homedir,'betas',opt.method,subj,['session' sesstr]);

if debug_mode == 1
    savedir = [savedir '_debug'];
end

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

opt.numpcstotry = 12;
opt.chunknum = 100000;

tic
results = GLMestimatesingletrial(design,data,stimdur,tr,savedir,opt);
toc

end
