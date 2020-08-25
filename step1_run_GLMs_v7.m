
function [] = run_GLMs(subj, sess, GLM_method)

date = '08_24_20';
debug_mode = 0;

dbstop if error

disp(['running for subject: ' subj])
disp(['running for session: ' sess])
disp(['running for method: ' GLM_method])
disp('begin setup...')
tic

%% hyperparameters 

homedir = pwd;
bidsdir = fullfile('/lab_data','tarrlab','common','datasets','BOLD5000','BIDS');

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

opt.subj = subj;
opt.sessionstorun = cellfun(@str2num,(strsplit(sess,'_')));
opt.loocv = 1;
opt.k = 2;

opt.chunknum = 125000;
opt.numpcstotry = 12;

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

% define
stimdur = 1;
tr = 2;

method = opt.method;

%% directory and path management

cd(homedir)

eventdir = fullfile(bidsdir,['sub-' subj]);
datadir = fullfile(bidsdir,'derivatives','fmriprep',['sub-' subj]);
savedir = fullfile(homedir,'betas',method, subj,['sessions_' strrep(strrep(strrep(num2str(opt.sessionstorun),' ','_'),'__','_'),'__','_')]);

if debug_mode == 1
    savedir = [savedir '_debug'];
end

disp(['savedir: ' savedir])

assert(isdir(bidsdir))
assert(isdir(eventdir))
assert(isdir(datadir))

addpath('utilities')
addpath('GLMdenoise')
addpath('GLMdenoise/utilities')
addpath('fracridge/matlab')
addpath('nifti_tools')


%% load design matrix

[design, ~] = load_BOLD5000_design(eventdir, opt.sessionstorun);

%% load data

data = load_BOLD5000_data(subj, datadir, opt.sessionstorun);

if debug_mode == 1
    for i = 1:length(data)
        dims = size(data{i});
        subslices = 25; %floor(dims(3)*29/60):floor(dims(3)*31/60);
        data{i} = data{i}(:,:,subslices,:);
    end
end

% check sanity
assert(length(data) == length(design))

disp('finished setup')
toc

%% run GLMs

disp(['running GLM for sessions ' num2str(opt.sessionstorun)])

tic;

results = GLMestimatesingletrial(design,data,stimdur,tr,savedir,opt);

disp('done with call to GLMestimatesingletrial')

toc;

end


