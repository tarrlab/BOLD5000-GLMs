function [data] = load_BOLD5000_data(subj, datadir, sessionstorun)

tic 

%% load data from all sessions

disp(['loading data for sessions ' num2str(sessionstorun)])

data = [];

for ses = sessionstorun
    
    if ses < 10
        sesstr = ['0' num2str(ses)];
    else
        sesstr = num2str(ses);
    end
    
    disp(['loading session ' sesstr])
    
    subdatadir = fullfile(datadir,['ses-' sesstr],'func');
    
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
    else
        disp('no issue with nifti zipping. continuing...')
    end
    
    files0 = matchfiles(fullfile(subdatadir,'*run*_preproc.nii'));
    maskfiles0 = matchfiles(fullfile(subdatadir,'*_brainmask.nii'));
    
    disp('loading data...')
    % load data
    ses_data = {};
    for p=1:length(files0)
        disp(p)
        a1 = load_nii(files0{p});
        img = single(a1.img);
        
        if sum(isnan(img(:))) > 0
            error('volume contains nans')
        end
        
        % load brain mask
        mask = load_nii(maskfiles0{p});
        for i=1:size(img,4)
            thisimg = squeeze(img(:,:,:,i));
            thisimg(mask.img==0) = 0;
            img(:,:,:,i) = thisimg;
        end
        ses_data{p} = img;
    end
    clear a1;
    
        
    data = [data ses_data];
    
end

disp('done loading data')

toc

end

