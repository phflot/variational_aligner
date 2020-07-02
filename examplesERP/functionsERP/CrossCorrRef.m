function [ ref ] = CrossCorrRef(inputImage,ReferenceLine)
% Author: David Thinnes
% date:  06/27/2020
% Copyright 2020 by David Thinnes, All rights reserved.

% input: inputImage = the image you want to align
%        ReferenceLine = the line the cross correlation is performed to

% description:  the function performs cross correlation with respect to one
% choosen reference line (for example line/trial 1)

 %% Align all signals according to the lag to s1

 % size of inputImage
 L1 = size(inputImage,1);

% cross correlataion reference line with all other lines to get the timelags 
 s1 = inputImage(ReferenceLine,:);        % reference signal in ERPimage
  
  timeshift = zeros(1, L1);
  timeshift(1) = 0;
  Mall = zeros(1, L1);
  Iall = zeros(1, L1);
 
 for ii = 1: L1

[C,lag] = xcorr(inputImage(ii,:),s1);
Call(ii,:) = C/max(C);
lagall(ii,:) = lag;
[M,I] = max(Call(ii,:));
Mall(ii) = M;
Iall(ii) = I;

timeshift(ii) = lag(I) ;
clear C lag M I
 end

 
 %% find most dominant timeshift in the timelag data
ref = [];
 
for kk = 1:size(timeshift,2)
    
    if (timeshift(kk) <= mean(timeshift)+2*std(timeshift)) && ( timeshift(kk) >= mean(timeshift)-2*std(timeshift))
        
        ref = [ref, kk];
    end
end

end

