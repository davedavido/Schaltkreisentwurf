clear all;
close all;

LenSamples = 1e4;

x = randn(1,LenSamples);

%% Rauschsignal runden auf ganze Zahlen
x = round(x*20);

%%% Rauschsignal in Datei schreiben
dlmwrite('Matlab/noisesignal.txt',x,'delimiter','\n');

%%% Histogramm plotten
histogram(x,200)
title('Histogramm Rauschsignal')
xlabel('Amplitude')
ylabel('Count')

%%% Filter Koeffizienten festlegen
%h = [ -0.0000   -0.1611   -0.2033    0.0000    0.4118    0.8261    1.0000    0.8261    0.4118    0.0000   -0.2033   -0.1611   -0.0000];
h =  [ -0.0000   -0.1250   -0.2078   -0.1774    0.0000    0.2985    0.6351    0.8998    1.0000    0.8998    0.6351    0.2985    0.0000 -0.1774   -0.2078   -0.1250   -0.0000];

% Convert to fixed point value
h_fixed = float2fixed(h,14);
% Check conversion error
error = testAccuracy(h_fixed, h, 14, 4);
dlmwrite('Matlab/error.txt',error,'delimiter','\n');
h_fixed = dec2bin(h_fixed, 16);
dlmwrite('Matlab/filtercoeffs.txt',h_fixed, 'delimiter', '');




%%%%% Spektrum Rauschnsignal %%%%%
mypsd(x, 1024, 1, 1);
title('Spektrum Rauschsignal')

%%%% Filterimpulsantwort plotten
figure;
plot(h,'bo-','linewidth',2);
grid;
xlabel('Filter Tap Index');
ylabel('Filter Koeffizienten');

%%% Filterfrequenzgangs Plotten (logarithmische Darstellung)
mypsd(h,1024,1,1);
title('Filterfrequenzgang');

%%% Filteroperation 
y = conv(x,h);

%%% Spektrum des Filterausgangssignals plotten
mypsd(y,1024,1,1);
title('Spektrum Filterausgangssignal');


