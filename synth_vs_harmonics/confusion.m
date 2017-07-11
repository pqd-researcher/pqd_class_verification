% Sample application for the verification of the  pre-tained 
% Power Quality Classifier Neural Network Test

% 1: Load pre-trained network
% 2: Generate signals according to pre-defined models
% 3: Apply S-Transform
% 4: Extract Features
% 5: Update confusion matrix

% This code is a cross validation for 3 types of
% power quality diturbance types: Normal, Sag & Harmonics


% Do Housekeeping
clear all;
clc;

% Features
% X1: Mean of the fundamental frequency contour (50 Hz) divided by 2
% X2: Minumum value of the fundamental frequency peak values
% X3: Maximum value of the fundamental frequency peak values
% X4: Mean of the third harmonic (150 Hz)
% X5: Mean of the 5th harmonic (250 Hz)
% X6: Mean of the 7th harmonic (350 Hz)
% X7: Sum of values from 700 to 1600 Hz contours

% 1: 1-50: Normal
% 2: 51-100: Sag
% 3: 101-150: Harmonics


%% Const Parameters
Fs = 10000;                   % Sampling frequency, 5 KHz Nyquist frekansý
T = 1/Fs;                     % Sample time, 0,0001
L = 1000;                     % Length of signal, five periods
t = (0:L-1)*T;                % Time vector
A = 1;                        % Amplitude

% High order harmonics order
m_index = 71:5:151;

% Samples count to be used as input (for each disturbance)
sc = 50;

% Find every positive half period local maximum
local_max = zeros(1, 10);

%% Harmonics exists in real power signal
yhr = 0.056379*sin(2*pi*150*t) + 0.06528*sin(2*pi*250*t) + 0.014343*sin(2*pi*350*t) +  0.008286*sin(2*pi*450*t) ;

% Load pre-trained neural-network
load('neuro.mat');

% Confusion Matrix
% 3x3 Matrix Accuracy Table
acc_table = zeros(3, 3);
    
%% Generate Signal (Pure Sine)
% y(t) = Asin(wt) + yhr

for i=1:50

    A = 0.95 + 0.1*rand(1,1);
    
    y = A*sin(2*pi*50*t);
    
    y = y + A*yhr;
   
    % Local Max for interruption
    abs_signal = abs(y);

    z=1;
    for k=0:100:900
        local_max(z)=max(abs_signal((k+1:k+100)));
        z=z+1;
    end

    [st_matrix, times, frequencies] = st(y, 0, 1500, Fs);

    st_power = abs(st_matrix);
    % contourf(st_power); 
    % countour(st_power);
    

    % 50 Hz contour
    mean_50 = mean(st_power(6,:))/2;
 
    min_50 = min(local_max)/2;
    
    max_50 = max(local_max)/2;
 
    mean_150 = mean(st_power(16,:));

    mean_250 = mean(st_power(26,:));

    mean_350 = mean(st_power(36,:));

    % mean_700 = mean(st_power(72,:));
    mean_700_up = mean(sum(st_power(m_index,:)));
        
    input_vector = [mean_50; min_50; max_50; mean_150; mean_250; mean_350; mean_700_up];
    
    % Apply input vector to pre-trained neural network
    dist = pq_net(input_vector);
    
    % Calculate maximum output value
    [max1, index] = max(dist);
    
    % Update confison matrix
    acc_table(1, index) = acc_table(1, index) + 1;
    
end


%% Voltage Sag (Dip in British English)
% y(t) = A(1-alfa*(u(t-t1)-u(t-t2)))sinwt
% 0.1 <= alfa <= 0.9
% T <= t2-t1 <= 9T

% t1 = 0.02;
% t2 = 0.05;

% alfa = 0.98;

% Constant Parameter
t1 = 0.02;

for i=1:40

    t2 = 2*t1 + 0.02*floor(4*rand(1,1));

    alfa = 0.1 + 0.8*rand(1,1);

    y1 = A*(1-alfa*((t-t1>=0)-(t-t2>=0))).*sin(2*50*pi*t);
    
    y1 = y1+ (1-alfa)*yhr;
   
    [st_matrix, times, frequencies] = st(y1, 0, 1500, Fs);
  
    st_power = abs(st_matrix);
   
    abs_signal = abs(y1);

    z=1;
    for k=0:100:900
        local_max(z)=max(abs_signal((k+1:k+100)));
        z=z+1;
    end
   
    % 50 Hz contour
    mean_50 = mean(st_power(6,:))/2;

    min_50 = min(local_max)/2;
    
    max_50 = max(local_max)/2;

    mean_150 = mean(st_power(16,:));

    mean_250 = mean(st_power(26,:));

    mean_350 = mean(st_power(36,:));
    
    mean_700_up = mean(sum(st_power(m_index,:)));       
       
    input_vector = [mean_50; min_50; max_50; mean_150; mean_250; mean_350; mean_700_up];
    
    dist = pq_net(input_vector);
    
    [max1, index] = max(dist);
    
    acc_table(2, index) = acc_table(2, index) + 1;

end

% 
for i=1:10

    t2 = 2*t1 + 0.02*floor(4*rand(1,1));

    alfa = 0.11 + 0.8*rand(1,1);

    y1 = (1-alfa)*sin(2*50*pi*t);   
    
    y1 = y1 + (1-alfa)*yhr; 

    [st_matrix, times, frequencies] = st(y1, 0, 1500, Fs);

    % |S(tau, f)|, magnitude hesabi, Countour olarak cizdir.
    st_power = abs(st_matrix);
  
    % Divide all values by 2
    % st_power = st_power./2;      
        
    % Local Max for interruption
    abs_signal = abs(y1);

    z=1;
    for k=0:100:900
        local_max(z)=max(abs_signal((k+1:k+100)));
        z=z+1;
    end
     
    % 50 Hz contour
    mean_50 = mean(st_power(6,:))/2;

    % min_50 = min(st_power(6,:))/2;
    min_50 = min(local_max)/2;
    
    max_50 = max(local_max)/2;

    mean_150 = mean(st_power(16,:));

    mean_250 = mean(st_power(26,:));

    mean_350 = mean(st_power(36,:));
    
    % mean_700 = mean(st_power(72,:));
    mean_700_up = mean(sum(st_power(m_index,:)));
          
    input_vector = [mean_50; min_50; max_50; mean_150; mean_250; mean_350; mean_700_up];
    
    dist = pq_net(input_vector);
    
    [max1, index] = max(dist);
    
    acc_table(2, index) = acc_table(2, index) + 1;

end

%% Harmonics
% Model: 
% y(t) = A[alfa1*sin(wt)+alfa3*sin(3wt)+alfa5*sin(5wt)+alfa7*sin(7wt)]
% 0.05 <= alfa3,5,7 <= 0.15 ; alfa1^2 + alfa3^2 + alfa5^2  + alfa7^2 = 1

for i=1:sc
       
    alfa3 = 0.05 + 0.1*rand(1,1);
    alfa5 = 0.05 + (0.1-alfa3^2)*rand(1,1);
    alfa7 = 0.05 + (0.1-alfa3^2-alfa5^2)*rand(1,1);

    alfa1 = sqrt(1-(alfa3^2+alfa5^2+alfa7^2));

    yh = A*( alfa1*sin(2*pi*50*t) + alfa3*sin(2*pi*150*t) +  alfa5*sin(2*pi*250*t) + alfa7*sin(2*pi*350*t));

    [st_matrix, times, frequencies] = st(yh, 0, 1500, Fs);

    % |S(tau, f)|
    st_power = abs(st_matrix);
      
    % Local Max for interruption
    abs_signal = abs(yh);

    z=1;
    for k=0:100:900
        local_max(z)=max(abs_signal((k+1:k+100)));
        z=z+1;
    end
    
    % 50 Hz contour
    mean_50 = mean(st_power(6,:))/2;
 
    min_50 = min(local_max)/2;
    
    max_50 = max(local_max)/2;

    mean_150 = mean(st_power(16,:));

    mean_250 = mean(st_power(26,:));

    mean_350 = mean(st_power(36,:));
    
    mean_700_up = mean(sum(st_power(m_index,:)));
         
    input_vector = [mean_50; min_50; max_50; mean_150; mean_250; mean_350; mean_700_up];
    
    dist = pq_net(input_vector);
    
    [max1, index] = max(dist);
    
    acc_table(3, index) = acc_table(3, index) + 1;    
    
end

disp('Accuracy (Confison Matrix) for three types of disturbances')
disp('Re-run program to see how it changes')

fprintf('\r\n');
fprintf('%15s%10s%15s\r', 'Normal', 'Sag', 'Harmonics');

fprintf('%s %6d %10d %13d\r', 'Normal', acc_table(1,1), acc_table(1, 2), acc_table(1, 3));
fprintf('%s %9d %10d %13d\r', 'Sag',     acc_table(2,1), acc_table(2, 2), acc_table(2, 3));
fprintf('%s %3d %10d %13d\r', 'Harmonics',   acc_table(3,1), acc_table(3, 2), acc_table(3, 3));

%% Calculate overall accuracy

acq_table = acc_table;

for i=1:3
    acq_table(i, i) = 0;
end

total = sum(acq_table(:));

accuracy = 100 - total/sum(acc_table(:))*100;

fprintf('\r\nOverall Accuracy: %7.2f%%\r\n', accuracy);





