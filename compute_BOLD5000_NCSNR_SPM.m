clc; clear all; close all;

addpath('utilities')
homedir = pwd;
bidsdir = fullfile('/media','tarrlab','scenedata2','5000_BIDS');

%%

subjs = {'CSI1','CSI2','CSI3'};
nses = 15;
numreps = 4;
nrunimgs = 37;
overwrite = 0;

for s = 1:length(subjs)
    
    subj = subjs{s};
    disp(subj)
    
    if strcmp(subj,'CSI4')
        nses = 9;
    end
    
    betadir = fullfile('/media','tarrlab','scenedata2','spmAnalysis','WholeBrain-BIDS','derivatives','spm',['sub-' subj]);
    assert(isfolder(betadir))
    
    metric_savedir = fullfile('/media','tarrlab','scenedata2','spmAnalysis','WholeBrain-BIDS','metrics',['sub-' subj]);
    if ~isfolder(metric_savedir)
        mkdir(metric_savedir)
    end
    
    repbeta_savedir = fullfile('/media','tarrlab','scenedata2','spmAnalysis','WholeBrain-BIDS','rep_betas',['sub-' subj]);
    if ~isfolder(repbeta_savedir)
        mkdir(repbeta_savedir)
    end
    
    repbeta_savefn = fullfile(repbeta_savedir,[subj '_SPM_rep_betas.mat']);
    
    if ~isfile(repbeta_savefn) || overwrite == 1
        
        disp('recomputing rep-betas');
        
        session_betas = [];
        
        %%
        
        eventdir = fullfile(bidsdir,['sub-' subj]);
        
        [~, allses_design, labels, ~] = load_BOLD5000_design(eventdir, 1);
        
        %%
        
        for i = 1:nses
            
            disp(['loading ses ' num2str(i)])
            if i < 10
                sesstr = ['0' num2str(i)];
            else
                sesstr = num2str(i);
            end
                        
            X = load_compressed_nii(fullfile(betadir,['sub-' subj '_ses-' sesstr '_WholeBrain-TR34.nii.gz']));
            
            betas = X.img;
                  
            if i == 1
                session_betas = calczscore(betas, 4, [], [], 0);
            else
                session_betas(:,:,:,end+1:end+size(betas,4)) = calczscore(betas, 4, [], [], 0);
            end
            
        end
        
        clear X
        subdims = [size(betas,1) size(betas,2) size(betas,3)];
        
        %% assert correct number of trials
        
        assert(size(session_betas,4) == length(labels))
        
        %% get repeat indices
        
        % experimental design stuff
        ord = labels;
        ordU = unique(ord);
        allixs = [];
        for qq=1:length(ordU)
            ix = find(ord==ordU(qq));
            if length(ix)==numreps
                allixs(:,end+1) = ix(:);
            end
        end
        
        for i = 1:size(allixs,2)
            assert(all(labels(allixs(:,i))==labels(allixs(1,i))))
        end
       
        
        %%
        rep_betas = zeros(subdims(1), subdims(2), subdims(3), size(allixs,1), size(allixs,2),'single');
        
        for r = 1:size(allixs,1)
            for c = 1:size(allixs,2)
                beta0 = session_betas(:,:,:,allixs(r,c));
                rep_betas(:,:,:,r,c) = beta0;
            end
        end
        
        save(repbeta_savefn,'rep_betas')
        
    else
        disp(['rep beta file already exists, skipping'])
        %continue
        load(repbeta_savefn)
    end
    
    subdims = [size(rep_betas,1) size(rep_betas,2) size(rep_betas,3)];
    
    % compute vmetric from repeated betas
    vmetric = sqrt(mean(std(rep_betas,[],4).^2,5));
    
    % compute SNR from vmetric
    snr = translatevmetric(vmetric);
    
    % compute percentage of noise ceiling
    ncsnr = (100 .* (snr.^2)) ./ (snr.^2 + 1/numreps);
    
    reliability = zeros(subdims(1),subdims(2),subdims(3));
    
    for ii = 1:subdims(1)
        for jj = 1:subdims(2)
            for kk = 1:subdims(3)
                aa = squeeze(rep_betas(ii,jj,kk,:,:));
                if sum(isnan(aa(:))) == 0
                    bb0 = corr(mean(aa([1 2],:))', mean(aa([3 4],:))');
                    bb1 = corr(mean(aa([1 3],:))', mean(aa([2 4],:))');
                    bb2 = corr(mean(aa([1 4],:))', mean(aa([2 3],:))');
                    reliability(ii,jj,kk) = mean([bb0 bb1 bb2]);
                else
                    reliability(ii,jj,kk) = NaN;
                end
            end
        end
    end
    
    disp('saving metric volumes')
    save(fullfile(metric_savedir,[subj '_SPM_vmetric.mat']), 'vmetric')
    save(fullfile(metric_savedir,[subj '_SPM_snr.mat']), 'snr')
    save(fullfile(metric_savedir,[subj '_SPM_ncsnr.mat']), 'ncsnr')
    save(fullfile(metric_savedir,[subj '_SPM_reliability.mat']), 'reliability')
    
end


function f = translatevmetric(x)

f = 1 - x.^2;

f(f<0) = 0;

f = sqrt(f) ./ x;

f(isinf(f)) = NaN;

end