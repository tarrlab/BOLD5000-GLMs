

%%

R2 = results{4}.R2;

%%

close all
figure('Color',[1 1 1])
montage(R2,'DisplayRange',[20 60]);
colormap(hot(256))
colorbar
%%

betas = mean(results{4}.modelmd,4);

%%

close all
figure('Color',[1 1 1])
montage(betas,'DisplayRange',[-5 5]);
colormap(parula(256))
colorbar

%%

results_v2 = load('/media/tarrlab/scenedata2/BOLD5000_GLMs/git/betas/kendrick_pipeline_v3/TYPEB_FITHRF.mat');


%%


R2_diff = R2 - results_v2.R2;

close all
figure('Color',[1 1 1])
montage(R2_diff,'DisplayRange',[-5 5]);
colormap(jet(256))
colorbar

%%

beta_diff = betas - mean(results_v2.modelmd,4);

close all
figure('Color',[1 1 1])
montage(beta_diff,'DisplayRange',[-0.1 0.1]);
colormap(jet(256))
colorbar
