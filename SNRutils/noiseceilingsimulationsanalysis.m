% define
sessnums = [40]  % 32 30];
signalmn = 100;
signalsd = 1;
noisesds = 10.^([-2:.2:-1 -.9:0.1:.9 1:.2:2 5]);
nrep = 100;

%%

% load
a1 = load('~/nsddata/experiments/nsd/nsd_expdesign.mat');

% init
vmetric = [];

% repeat for each number of sessions
for pp=1:length(sessnums), pp

  % basic experimental design stuff
  ord = a1.masterordering(1:750*sessnums(pp));
  ordU = unique(ord);

  % repeat for each noise level
  for qq=1:length(noisesds), qq
  
    % generate noiseless signal for up to 10,000 images
    signal = signalmn + signalsd*randn(nrep,10000);
    
    % generate simulated data (trial-wise responses)
    truesignal = zeros(nrep,length(ord));
    for rr=1:length(ord)
      truesignal(:,rr) = signal(:,ord(rr));
    end
    truenoise = noisesds(qq)*randn(nrep,length(ord));
    data = truesignal + truenoise;

    % perform data preparation on the simulated data
    data0 = reshape(data,nrep,750,[]);
    mn0 = mean(data0,2);
    sd0 = std(data0,[],2);
    data0 = reshape((data0 - repmat(mn0,[1 750 1])) ./ repmat(sd0,[1 750 1]),nrep,[]);
    % no need to add the constant back in since it won't change the answer for vmetric
    
    % compute the v metric for the prepared simulated data
    rec = [];
    for im=1:length(ordU)
      ix = find(ord==ordU(im));
      if length(ix) >= 3
        rec = [rec std(data0(:,ix),[],2)];
      end
    end
    vmetric(pp,qq,:) = mean(rec,2);

  end
    
end

%%

snr = signalsd./noisesds;

ix = 1:length(snr);
ix(end-2:end-1) = [];

vmetricFINAL = mean(vmetric,3);
vmetricFINAL = vmetricFINAL(ix);
snrFINAL = snr(ix);

s% save
save('~/Dropbox/KKTEMP/noiseceilingsimulations.mat','vmetricFINAL','snrFINAL');

% put into ~/nsd/ppdata/

%%%%%%%%%%%%%%%%%%%% JUNK BELOW

NCsingle = 1./(1+1./snr.^2) * 100;

figure; hold on;
scatter(vmetricA(1,:),vmetricB(2,:));


figure; hold on;
plot(vmetricA(1,:),ncA(1,:),'ro-');
plot(vmetricA(2,:),ncA(2,:),'go-');
plot(vmetricA(3,:),ncA(3,:),'bo-');
xlabel('v metric');
ylabel('NC');
straightline([0 100],'h','k-');

plot(0:.01:1,interp1(vmetricA(1,:),ncA(1,:),0:.01:1,'pchip'),'m-');

ncA = mean(nc,3);

% % cal
% nreps = zeros(3,3);  % 1/2/3 counts x 3 session numbers
% for pp=1:length(sessnums)
%   ord = a1.masterordering(1:750*sessnums(pp));
%   ordU = unique(ord);
%   for qq=1:length(ordU)
%     nreps(sum(ord==ordU(qq)),pp) = nreps(sum(ord==ordU(qq)),pp) + 1;
%   end
% end

    % perform trial-averaging    
    avgdata = zeros(nrep,length(ordU));
    for im=1:length(ordU)
      avgdata(:,im) = mean(data(:,ord==ordU(im)),2);
    end

    % compute noise ceiling as the R^2 between the signal and the trial-averaged data
    nc(pp,qq,:) = calccod(signal(:,ordU),avgdata,2);
    
