clear all
close all
clc

% load('FULL_filtered_reducedfft.mat')

load('FULL_filtered_reducedfft_second_test.mat')


%FULL_filtered_reducedfft(24,34,3) - (s,fr,LC)- (i.e. subject x frequency-bin x Light-condition)

%Reshape power for each of the 3 light conditions into a vector
LC1=reshape(FULL_filtered_reducedfft(:,:,1),24*34,1);
LC2=reshape(FULL_filtered_reducedfft(:,:,2),24*34,1);
LC3=reshape(FULL_filtered_reducedfft(:,:,3),24*34,1);
%Join the 3 vectors into a "Power" vector:
Power=[LC1;LC2;LC3];
clear LC1 LC2 LC3
%Make a corresponding ID vector for the Power vector
ID=repmat([1:24],1,34*3)';
%Make a corresponding vector indicating Light Condition 
Light=[repmat(1,816,1); repmat(2,816,1); repmat(3,816,1)];
%Make a corresponding vector "Fr" for the frequency bin (2:35)
current=1;
clear Fr
for i=2:35
    Fr(current:current+(length(repmat(i,24,1))-1))=repmat(i,24,1);
    current=current+length(repmat(i,24,1));
end
Fr=[Fr,Fr,Fr]';
FFT_for_R=[ID,Light,Fr,Power]; 

%Save for import into R
csvwrite (['FFT_for_R.csv'],FFT_for_R)%ID,Light,Fr,Power
