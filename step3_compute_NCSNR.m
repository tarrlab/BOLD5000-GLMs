

%% goal: compute NCSNR for a given beta version

%%

addpath(genpath('SNRutils'))
counter = 0;
betadir = '/media/tarrlab/scenedata2/BOLD5000_GLMs/git/betas/assume_hrf/CSI2/';

subdims = [72 92 70];

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

rep_betas = zeros(subdims(1), subdims(2), subdims(3), size(allixs,1), size(allixs,2),'single');
% step 1: load repeated img data for a given subject, z-scoring session
% data before extracting repeats
% size of matrix should be (X, Y, Z, reps, imgs)

for ses = 1:15
    sesstr = sprintf('ses-%02d',ses);
    disp(sesstr)
    fn = fullfile(betadir,['sessions_' num2str(ses)],'TYPEB_FITHRF.mat');
    temp = load(sprintf('%s',fn));
    betas = single(temp.modelmd);
    betas = calczscore(betas,4,[],[],0);  % invalid voxels become NaN
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

% step 2: compute the mean standard deviation of each voxel's responses
% over repeated images.

 vmetric = nanmean(std(rep_betas,[],4),5);  % we ignore NaNs that seep in
 snr = translatevmetric(vmetric);
% zscore is over the img dimension within a session

% after zscoring, the dims will be (X, Y, Z, 1, imgs)

% after taking the mean, dims will be (X, Y, Z, 1, 1)

% then call translatevmetric on the resulting matrix to get the snr values



%vmetric = nanmean(std(
%reshape( % input to std is X, Y, Z, reps, imgs
%betas(:,:,:,flatten(allixs)),size(betas,1),size(betas,2),size(betas,3),3,[])
%,[],4),5);  % we ignore NaNs that seep in

% the result of std is X, Y, Z, , imgs i think?

%%

reliability = zeros(subdims(1),subdims(2),subdims(3));

for i = 1:subdims(1)
    disp(i)
    for j = 1:subdims(2)
        for k = 1:subdims(3)
            a = squeeze(rep_betas(i,j,k,:,:));
            if sum(isnan(a(:))) == 0
                b = (pdist(a,'correlation') - 1) * -1;
                reliability(i,j,k) = mean(b);
            else
                reliability(i,j,k) = nan;
            end
        end
    end
end

figure; montage(reliability,'DisplayRange',[]); colormap(jet(256)); colorbar
