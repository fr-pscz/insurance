%% Generate simulations
clear all
load('riskfree.mat')
load('survProb.mat')

M = 50;
N = 100;
RD = 2/100;
x = 60;
fixedFees = 50;
inflation = 2/100;
sigma = 0.25;
probLapse = 0.15;
% N simulations, M time steps
g      = randn(N,M);
lapse  = rand(N,M);
lapse  = lapse <= probLapse;
deaths = rand(N,M);
deaths = buildDeathMatrix(deaths, survProb(x:x+M-1)');

F0 = 100000;
T = 1:M;
dT = ones(1,M);
riskfree = riskfree(1:M)';
discounts = exp(-riskfree.*T);

F = zeros(N,M);
F(:,1) = F0*exp((riskfree(1) - sigma^2/2) + sigma.*g(:,1))*(1-RD) - fixedFees*(1+inflation);

for ii = 2:M
    F(:,ii) = F(:,ii-1).*exp((riskfree(ii) - sigma^2/2) + sigma.*g(:,ii))*(1-RD) - fixedFees*(1+inflation)^ii;
end

mean(payoff(F0, F, lapse, deaths, discounts))