function f = translatevmetric(x)

% function f = translatevmetric(x)
%
% <x> is a matrix of "v metric" values
%
% Use the simulation results to map the <x> values
% to SNR units. We carefully handle corner cases (see code).

% load simulation results
b1 = load('noiseceilingsimulations.mat');

%b1.vmetricFINAL = rescale(b1.vmetricFINAL, prctile(x(:),5), prctile(x(:),95));

% handle corner cases
isbad = ~isfinite(x);
islow  = x < b1.vmetricFINAL(1);
ishigh = x > b1.vmetricFINAL(end);

% do the interpolation
f = interp1(b1.vmetricFINAL,b1.snrFINAL,x,'pchip');
f(isbad) = NaN;
f(islow) = 100;
f(ishigh) = 0;
