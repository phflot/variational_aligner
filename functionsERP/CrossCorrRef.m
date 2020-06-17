function [ ref ] = CrossCorrRef(inputImage,ReferenceLine)
% [ ref ] = CrossCorrRef(zz,level,original,inputImage,ReferenceLine)
% function [ ERP_al, ref ] = CrossCorrRef(zz,level,original,inputImage,ReferenceLine)
% function head if you wanna align with cross correlation decommand also
% the part in that function


% input: inputImage = the image you want to align
%        ReferenceLine = the line the cross correlation is performed to
% description:  the function performs cross correlation with respect to one
% choosen line (for example line 1) in original time domain and for
% frequency octavebands till a certain level


 %% Align all signals according to the lag to s1

 % size of inputImage
 L1 = size(inputImage,1);

 

%% cross correlataion reference line with all other lines to get the timelags 

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

% MO = mode(timeshift);
% ref = find(timeshift == MO);
ref = [];
 
for kk = 1:size(timeshift,2)
    
    if (timeshift(kk) <= mean(timeshift)+2*std(timeshift)) && ( timeshift(kk) >= mean(timeshift)-2*std(timeshift))
        
        ref = [ref, kk];
    end
end


 
 
 
 %% align all signals to the first signal s1
%  
%  original = inputImage;
%  
%  ERP_al = zeros(L1,L2);
%  ERP_al(1,:) = original(1,:);
% for ll = 1:L1-1
%     
%     if timeshift(ll) < 0
%     shift = original(ll+1,-timeshift(ll):end);
%     ERP_al(ll+1,:) = [shift zeros(1,-timeshift(ll)-1)];
%     elseif timeshift(ll) > 0
%     shift = original(ll+1,+timeshift(ll):end);  
%     ERP_al(ll+1,:) = [shift zeros(1,+timeshift(ll)-1)];
%     else % if there is no timeshift
%     ERP_al(ll+1,:) = original(ll+1,:);    
%     end
%     
%     clear shift
% end




%% plot the reference line for the cross correlation and the aligned signal

% tmp = imfilter(ERP_al, G, 'symmetric');
% figure;
% subplot(2, 2, 1);
% plot(original(ReferenceLine,:));
% title('ReferenceLine');
% subplot(2, 2, 2);
% plot(timeshift);
% grid on
% title('timelags');
% subplot(2, 2, 3);
% imagesc(inputImage);
% title('pre filtered');
% subplot(2, 2, 4);
% imagesc(tmp);
% title('pre filtered after cross correlation');
% colormap(hot);





end

