clc;
close all;

ASPI_Array = table2array(ASP);
ASPI_Double = str2double(ASPI_Array);
S11LPDA
S11_Double = table2array(S11LPDA)

%  PLot S11
S11_Double(:,1) = S11_Double(:,1)/10^9;
S11_Double(:,2) = S11_Double(:,2) - max(S11_Double(:,2));
plot(S11_Double(:,1),S11_Double(:,2));
title("S11 Measurement");
xlabel("Frequency (GHz)");
ylabel("Magnitude (dB)");
minFreq = min(S11_Double(:,1));
maxFreq = max(S11_Double(:,1));
xlim([minFreq maxFreq]);
%xlim([0.7 2]);

% Plot ASPI
%181 Samples per Freq
figure;
n = (14)-1;
vector = 1+(n*181):1:(181+n*181);
ASPI_Double(1+n*181,1)
ASPI_Double(vector,4) = ASPI_Double(vector,4) - max(ASPI_Double(vector,4));
plot(ASPI_Double(vector,3),ASPI_Double(vector,4));
title("Antenna Spread (1.18GHz)");
xlabel("Azimuth (Degrees)")
ylabel("Magnitude (dB)");
xlim([-180 180]);
