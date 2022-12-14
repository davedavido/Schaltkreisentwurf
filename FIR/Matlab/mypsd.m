
function [res, reslin, faxis] = mypsd (x, numfft, fsample_Hz, flagplot)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Function to plot log10(Abs()^2) Spectrum of given signal vector x 
% Variables input:
% x - given signal vector
% numfft - fftsize
% fsample_Hz - sample rate of x in Hz
% flagplot - if set to 1 (true) the spectrum plot will be generated
%
% output variables:
% res - result spectrum vector log-Domain
% reslin - result spectrum linear
% faxis - frequenc axis of given spectrum
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(size(x,1) == 1)
    x = (x.');
end

numtapper   = floor(length(x)/numfft);
temp        = zeros(numfft,1);
if numtapper > 0
    for it = 1:numtapper
        xtemp = x((it-1)*numfft+1:it*numfft);
        temp = temp + abs(fft(hanning(length(xtemp)).*xtemp)).^2;
    end
    res = fftshift(10.*log10(temp));
    reslin = fftshift(temp);
else
    
    res =  fftshift(10.*log10(abs(fft(x,numfft)).^2));
    reslin = fftshift(abs(fft(x,numfft)).^2);
end

df = 1/numfft;
f = -0.5:df:0.5-df;
faxis = fsample_Hz.*f;
res = res - max(res);
if flagplot == 1
    
    figure
    plot(faxis,res);
    
    grid
    xlabel('Frequency[MHz]')
    ylabel('PSD normiert [dB]');
    
end


%res = res - max(res);

