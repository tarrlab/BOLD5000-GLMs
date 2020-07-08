load('~/nsd/nsddata/templates/noiseceilingsimulations.mat');

figureprep; hold on;
plot(vmetricFINAL,snrFINAL,'ro');
xx = linspace(min(vmetricFINAL),max(vmetricFINAL),10000);
plot(xx,interp1(vmetricFINAL,snrFINAL,xx,'pchip'),'g-');
xlabel('vmetricFINAL');
ylabel('snrFINAL');
figurewrite('noiseceilingsimulations',[],-1,'~/Desktop');
