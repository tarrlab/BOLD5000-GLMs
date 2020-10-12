clc; clear all; close all;

addpath('utilities')
homedir = pwd;
bidsdir = fullfile('/media','tarrlab','scenedata2','5000_BIDS');

%%

date = '08_24_20';
groupings = {'five-sess'};
versions = {'TYPEA_ASSUMEHRF', 'TYPEB_FITHRF','TYPEC_FITHRF_GLMDENOISE','TYPED_FITHRF_GLMDENOISE_RR'};
subjs = {'CSI1','CSI2','CSI3'};
nses = 15;
numreps = 4;
nrunimgs = 37;
overwrite = 0;

maxses = 15;

for g = 1:length(groupings)
    
    grouping = groupings{g};
    
    for v = 1:length(versions)
        
        version = versions{v};
        
        if contains(version,'ASSUME')
            grouping0 = [grouping '_assume'];
            version0 = 'TYPEB_FITHRF';
        else
            grouping0 = grouping;
            version0 = version;
        end
        
        for s = 1:length(subjs)
            
            subj = subjs{s};
            disp([grouping ' ' subj ' ' version])
            
            if strcmp(subj,'CSI4')
                maxses = 9;
            end
            
            betadir = fullfile(homedir,'betas',[date '_' grouping0], subj);
            assert(isfolder(betadir))
            
            nifti_savedir = fullfile('/media','tarrlab','scenedata','BOLD5000_GLMsingle','betas',[date '_' grouping],subj,version);
            if ~isfolder(nifti_savedir)
                mkdir(nifti_savedir)
            end
                        
            subdirs = struct2table(dir(betadir));
            ses_subdirs = subdirs.name;
            ses_subdirs = ses_subdirs(contains(ses_subdirs,'session'));
            
            session_betas = cell(1,nses);
            
            %%
            
            eventdir = fullfile(bidsdir,['sub-' subj]);
            
            [~, allses_design, labels, ~] = load_BOLD5000_design(eventdir, 1);
            
            %%
            
            for i = 1:length(ses_subdirs)
                
                sesstrs = strsplit(ses_subdirs{i},'_');
                sesnums = str2double(cellstr(sesstrs(2:end)));
                
                X = load(fullfile(betadir, ses_subdirs{i}, [version0 '.mat']));
                
                betas = X.modelmd;
                
                idx = 1;
                for ss = 1:length(sesnums)
                    
                    nruns = length(allses_design{sesnums(ss)});
                    nimgs = nrunimgs * nruns;
                    betas0 = betas(:,:,:,idx:idx+nimgs-1);
                    
                    assert(size(betas0,4) == nimgs)
                    
                    session_betas{sesnums(ss)} = betas0;
                  
                    idx = idx+nimgs;
                    
                end
                
                assert(idx-1 == size(betas,4))
                
            end
            
            clear X
              
            %% assert correct number of trials
            
            n = cell2mat(cellfun(@size, session_betas,'UniformOutput',false));
            n = sum(n(4:4:end));
            assert(n == length(labels))
            
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
            
            %% save each session's betas as nifti
            
            for se = 1:maxses
                
                if se < 10
                    sesstr = ['0' num2str(se)];
                else
                    sesstr = num2str(se);
                end
                
                % save volumes
                fn = fullfile(nifti_savedir,['betas_session' sesstr '.nii']);
                
                % create nifti
                voxsize = [2 2 2];
                datatype = 16;
                nii = make_nii(single(session_betas{se}), voxsize, [], datatype);
                
                % save and gzip
                disp('saving')
                save_nii(nii, fn);
                clear nii
                disp('gzipping')
                gzip(fn)
                disp('deleting .nii file')
                delete(fn)
                
            end  
        end
    end
end

