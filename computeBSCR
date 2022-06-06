clear all
format bank

N = 10000000;

% BOF in base scenario
BASE
simulate_policy

BOFbase = BOF

%% Market IR
IRup
simulate_policy
dBOFup = max(BOFbase - BOF,0);

IRdw
simulate_policy
dBOFdw = max(BOFbase - BOF,0);

SCR_IR = max(dBOFdw,dBOFup)

if SCR_IR == dBOFdw
    Acorr = 0.5;
else
    Acorr = 0;
end

%% Market Equity
EQup
simulate_policy
dBOFup = max(BOFbase - BOF,0);

EQdw
simulate_policy
dBOFdw = max(BOFbase - BOF,0);

SCR_EQ = max(dBOFdw,dBOFup)

%% Mortality Risk
MORT
simulate_policy
SCR_MO = max(BOFbase - BOF,0)

%% Lapse Risk
LAup
simulate_policy
dBOFup = max(BOFbase - BOF,0);

LAdw
simulate_policy
dBOFdw = max(BOFbase - BOF,0);

BASE
simulate_policy_mass
dBOFma = max(BOFbase - BOF,0);

SCR_LA = max(max(dBOFdw,dBOFma),dBOFup)

%% Expense risk
EXPN
simulate_policy
SCR_EX = max(BOFbase - BOF,0)

%% Cat risk
CAT
simulate_policy
SCR_CA = max(BOFbase - BOF,0)

%% Life correlation

lifeCorr = [1    0    0.25 0.25;
            0    1    0.5  0.25;
            0.25 0.5  1    0.25;
            0.25 0.25 0.25 1];
tmpSCR = [SCR_MO; SCR_LA; SCR_EX; SCR_CA];
SCR_life = sqrt(tmpSCR' * lifeCorr * tmpSCR)

%% Market correlation

tmpSCR = [SCR_EQ; SCR_IR];
marketCorr = [1 Acorr;
              Acorr 1];
          
SCR_market = sqrt(tmpSCR' * marketCorr * tmpSCR)

%% BSCR
tmpSCR = [SCR_market; SCR_life];
Corr = [1 0.25;
        0.25 1];
    
BSCR = sqrt(tmpSCR' * Corr * tmpSCR)
