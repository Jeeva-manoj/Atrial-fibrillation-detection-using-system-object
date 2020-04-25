classdef atrfib < matlab.System
    % Untitled Add summary here
    %
    % This template includes the minimum set of functions required
    % to define a System object with discrete state.

    % Public, tunable properties
    properties
        Signal;
        SamplesPerFrame=1;
        SignalEndAction=0;

    end

    properties(Nontunable)
        
    end

    properties(DiscreteState)

    end

    % Pre-computed constants
    properties(Access = private)

    end

    methods(Access = protected)
        function setupImpl(obj)
            % Perform one-time calculations, such as computing constants
        end

        function y = stepImpl(obj,ecg)
            % Implement algorithm. Calculate y as a function of input u and
            % discrete states.
            f_s=250;
N=length(ecg);
t=[0:N-1]/f_s;
w=50/(250/2);
bw=w;
[num,den]=iirnotch(w,bw); % notch filter implementation 
ecg_notch=filter(num,den,ecg);
[e,f]=wavedec(ecg_notch,10,'db6');% Wavelet implementation
g=wrcoef('a',e,f,'db6',8); 
ecg_wave=ecg_notch-g; % subtracting 10th level aproximation signal
                       %from original signal                  
ecg_smooth=smooth(ecg_wave); % using average filter to remove glitches
                             %to increase the performance of peak detection
N1=length(ecg_smooth);
t1=(0:N1-1)/f_s;
hh=ecg_smooth;
 j=[];           %loop initialing, having all the value zero in the array
time=0;          %loop initialing, having all the value zero in the array
th=0.45*max(hh);  %thresold setting at 45 percent of maximum value
 
for i=2:N1-1 % length selected for comparison  
    % deopping first ie i=1:N-1  point because hh(1-1) 
   % in the next line  will be zero which is not appreciable in matlab 
    if((hh(i)>hh(i+1))&&(hh(i)>hh(i-1))&&(hh(i)>th))  
% condition, i should be> then previous(i-1),next(i+1),thrsold point;
        j(i)=hh(i);                                   
%if condition satisfy store hh(i)in place of j(i)value whichis initially 0;
       
        time(i)=[i-1]/250;           %position stored where peak value met;              
      
    end
end
 j(j==0)=[];               % neglect all zeros from array;
 time(time==0)=[];     % neglect all zeros from array;
m=(time)';               % converting rows in column;
k=length(m);
rr2=m(2:k);     %second array from 2nd to last point;
rr1=m(1:k-1);   %first array from 1st to 2nd last point;
% rr2 & rr1 is of equall length now;
rr3=rr2-rr1;
sq = diff(rr3).^2;
rms = sqrt(mean(sq)); % RMSSD,
disp(['RMSSD = ' num2str(rms)]); 
y=rms;
if(y>0.5)
    disp('Atrial fibrillation detected');
end
        end

        function resetImpl(obj)
            % Initialize / reset discrete-state properties
        end
    end
end
