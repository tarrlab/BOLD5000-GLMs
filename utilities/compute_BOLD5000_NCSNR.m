function [] = compute_BOLD5000_NCSNR(betadir, version)

tic

overwrite = 1;
%betadir = '/media/tarrlab/scenedata2/BOLD5000_GLMs/git/betas/07_27_20_one-sess_assume/CSI2';
%betadir = '/media/tarrlab/scenedata2/BOLD5000_GLMs/git/z-Old/assume_hrf/CSI2';
%version = 'TYPEB_FITHRF';

disp(['path:'  betadir])
disp(['version: ' version])

%% get event info

homedir = pwd;
cd(homedir)

bidsdir = fullfile('/media','tarrlab','scenedata2','5000_BIDS');
savedir = fullfile(betadir, version, 'metrics');

if ~isdir(savedir)
    mkdir(savedir)
end

subj = strsplit(betadir,'/'); subj = subj{end};

assert(ismember(subj, {'CSI1','CSI2','CSI3'}))

eventdir = fullfile(bidsdir,['sub-' subj]);

[~, allses_design, labels] = load_BOLD5000_design(eventdir, 1);

%% get subdirectory names and session groupings

subdirs = struct2table(dir(betadir));

session_groups = [];
valid_subdirs = [];

for i = 1:size(subdirs,1)
    fn = subdirs{i,1}{1};
    if contains(fn,'session')
        valid_subdirs = [valid_subdirs; {fn}];
        ses = strsplit(fn,'_');
        session_groups = [session_groups; cell2mat(cellfun(@str2num,ses(2:end),'UniformOutput',0))];
    end
    
end

n = size(session_groups,1);

%% get repeat indices

% experimental design stuff
ord = labels;
ordU = unique(ord);
allixs = [];
for qq=1:length(ordU)
    ix = find(ord==ordU(qq));
    if length(ix)==4
        allixs(:,end+1) = ix(:);
    end
end

%%

% step 1: load repeated img data for a given subject, z-scoring session
% data before extracting repeats
% size of matrix should be (X, Y, Z, reps, imgs)

if ~isfile(fullfile(savedir,'rep_betas.mat'))
    
    disp('rep_betas file does not exist. computing...')
    
    session_betas = cell(1,length(allses_design));
    
    for i = 1:n
        
        disp(['session group: ' num2str(session_groups(i,:))])
        subdir = valid_subdirs{i};
        X = load(fullfile(betadir,subdir,[version '.mat']));
        
        if i == 1
            subdims = size(X.R2);
            rep_betas = zeros(subdims(1), subdims(2), subdims(3), size(allixs,1), size(allixs,2),'single');
        end
        
        nruns = [];
        for r = 1:size(session_groups,2)
            nruns = [nruns length(allses_design{session_groups(i,r)})];
        end
        
        betas = single(X.modelmd);
        %betas = calczscore(betas, 4, [], [], 0); % zscore here or later?
        
        assert(size(betas,4) == sum(nruns)*37)
        
        % populate array of session betas from the (potentially grouped)
        % saved files
        idx = [];
        c = 1;
        for j = 1:size(session_groups,2)
            if nruns(j) == 10
                idx = [idx; ones(370,1).*c];
            elseif nruns(j) == 9
                idx = [idx; ones(333,1).*c];
            end
            c = c+1;
        end
        
        assert(length(idx) == size(betas,4))
        
        for j = 1:size(session_groups,2)
            session_betas{session_groups(i,j)} = betas(:,:,:,idx==j);
        end
    end
    
    
    
    %% populate array of repeated betas
    
    counter = 0;
    
    for ses = 1:15
        disp(ses)
        betas = session_betas{ses};
        betas = calczscore(betas,4,[],[],0);  % zscore here or earlier??
        n = size(betas,4);
        
        for i = 1:n
            
            counter = counter + 1;
            
            if ismember(counter, allixs)
                [r,c] = find(allixs == counter);
                assert(length(r) + length(c) == 2)
                rep_betas(:,:,:,r,c) = betas(:,:,:,i);
            end
        end
    end
    
    %% save rep betas (if necessary)
    disp('saving...')
    
    save(fullfile(savedir, 'rep_betas.mat'), 'rep_betas')
    
    
else
    disp('rep_beta file exists. loading...')
    load(fullfile(savedir, 'rep_betas.mat'));
    subdims = size(rep_betas(:,:,:,1,1));
    
end

if ~isfile(fullfile(savedir, 'vmetric.mat')) || overwrite == 1
    
    disp('computing vmetric, snr, ncsnr, and split-half reliability')
    
    %% compute vmetric
    
    % vmetric_ = nanmean(std(rep_betas,[],4),5);  % OLD METHOD
    vmetric = sqrt(nanmean(nanstd(rep_betas,[],4).^2,5));
    
    %% compute SNR
    
    snr = translatevmetric(vmetric);
    
    %snr(snr>10) = NaN; include?
    
    %% convert to percentage of noise ceiling (NCSNR)
    
    k = 4; % num repeats in BOLD5000
    ncsnr = (100 .* (snr.^2)) ./ (snr.^2 + 1/k);
    
    %ncsnr(ncsnr == 100) = NaN; necessary?
    
    %% compute split half reliability
    
    reliability = zeros(subdims(1),subdims(2),subdims(3));
    
    for i = 1:subdims(1)
        disp(i)
        for j = 1:subdims(2)
            for k = 1:subdims(3)
                a = squeeze(rep_betas(i,j,k,:,:));
                if sum(isnan(a(:))) == 0
                    b = corr(nanmean(a(1:2:end,:))', nanmean(a(2:2:end,:))'); % average every other repeat, and corr
                    %b = 1 - pdist(a,'correlation'); % corr all repeats to each other, and average
                    reliability(i,j,k) = b;
                else
                    reliability(i,j,k) = nan;
                end
            end
        end
    end
    
    %% save outputs
    
    disp('saving metric volumes')
    save(fullfile(savedir,'vmetric.mat'), 'vmetric')
    save(fullfile(savedir,'snr.mat'), 'snr')
    save(fullfile(savedir,'ncsnr.mat'), 'ncsnr')
    save(fullfile(savedir,'reliability.mat'), 'reliability')
    
else
    disp('files already exist and overwrite is false. done')
end

toc

end

