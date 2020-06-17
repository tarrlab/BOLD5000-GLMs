% notes:
% - only consider cases of 3 trials
% - use all the data
% - be careful about missing data (invalid voxels)
% - translate the vmetric to SNR

% load and define
%a1 = load('~/nsd/nsddata/experiments/nsd/nsd_expdesign.mat');
nsess = [40 40]; %40 40 32 30 40 32 40 30];
%hemis = {'lh' 'rh'};

% define
% Subject 1	[145 186 148]	[81 104 83]	227021	226601
% Subject 2	[146 190 150]	[82 106 84]	239633	239309
% Subject 3	[145 190 146]	[81 106 82]	240830	243023
% Subject 4	[152 177 143]	[85 99 80]	228495	227262
% Subject 5	[141 173 139]	[79 97 78]	197594	198908
% Subject 6	[152 202 148]	[85 113 83]	253634	259406
% Subject 7	[139 170 145]	[78 95 81]	198770	200392
% Subject 8	[143 184 139]	[80 103 78]	224364	224398
nslices1pt8 = [70];%83 84 82 80 78 83 81 78];
%nslices1pt0 = [148 150 146 143 139 148 145 139];

% do it
for subjix=2%:8
  fprintf('*** subject %d\n',subjix);
  dir0 = sprintf('~/nsddata_betas/ppdata/subj%02d',subjix);

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

  % func1pt8mm
  bdirs = matchfiles([dir0 '/func1pt8mm/betas_*']);
  for pp=1:length(bdirs)
    fprintf('***** bdir %s\n',bdirs{pp}); tic;
    chunks = chunking(1:nslices1pt8(subjix),10);
    snr = single([]);
    for cc=1:length(chunks), fprintf('cc=%d,',cc);
      betas = single([]);
      for qq=nsess(subjix):-1:1, fprintf('qq=%d,',qq);     % backwards so we get the memory allocation
        % invalid voxels are all 0
        temp = h5read(sprintf('%s/betas_session%02d.hdf5',bdirs{pp},qq),'/betas',[1 1 chunks{cc}(1) 1],[Inf Inf range(chunks{cc})+1 Inf]);
        betas(:,:,:,:,qq) = single(temp);  % = cat(5,betas,single(temp));  % no need to /300
      end
      betas = calczscore(betas,4,[],[],0);  % invalid voxels become NaN
      vmetric = nanmean(std(reshape(betas(:,:,:,flatten(allixs)),size(betas,1),size(betas,2),size(betas,3),3,[]),[],4),5);  % we ignore NaNs that seep in
      snr = cat(3,snr,translatevmetric(vmetric));
    end
    nsd_savenifti(snr,[1.8 1.8 1.8],sprintf('%s/ncsnr.nii.gz',bdirs{pp}),4/3);
    toc;
  end
   % for ech subject
     % for each chunk of the brain
       % for each session of betas
         % accumulate betas into X, Y, Z, imgs, session
    %
 

end
