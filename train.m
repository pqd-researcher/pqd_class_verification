% Sample Power Quality Disturbance Recognition Matlab Application
% Three types of power signal classification is considered: Normal Sag Harmonics
% Generate synthetic signals and apply S-Transform (ST)
% 
% Input: 1D signal sample array; Output: 2D Complex Matrix
% 
% Calculate amplitude matrix and extract features
% Train neural network and 
% Save trained network and features

% Authors: X
% 15.07.2017

% Do house keeping
clear;
clc;

% Disturbance Types
% 1: 1-50: Normal
% 2: 51-100: Sag
% 3: 101-150: Harmonics

% Extracted Features
% X1: Mean of the fundamental frequency contour (50 Hz) divided by 2
% X2: Minumum value of the fundamental frequency peak values
% X3: Maximum value of the fundamental frequency peak values
% X4: Mean of the third harmonic (150 Hz)
% X5: Mean of the 5th harmonic (250 Hz)
% X6: Mean of the 7th harmonic (350 Hz)
% X7: Sum of values from 700 to 1600 Hz contours

%% Const Parameters
Fs = 10000;                   % Sampling frequency, 5 KHz Nyquist frequency
T = 1/Fs;                     % Sample time interval: 0.0001 s
L = 1000;                     % Length of signal, 5 periods
t = (0:L-1)*T;                % Time vector
A = 1;                        % Amplitude (Real Power Signal is normalized around 1 V)

% High order harmonics indexes for transient event detection
m_index = 71:5:151;

% Find peaks in absolute value of the input signal 
local_max = zeros(1, 10);

%% Harmonics exists in real power signal
% Those values are added to pure sine data to make 
% the classifier more accurate when tested against the 
% real signal data. Those values can be changed according to 
% power line conditions.

yhr = 0.056379*sin(2*pi*150*t) + 0.06528*sin(2*pi*250*t) + 0.014343*sin(2*pi*350*t) +  0.008286*sin(2*pi*450*t) ;

%% Generate signals for Neural Network training
% In this part we will generate the signals
% according to models given in the previous studies


%% Generate Signal (Pure Sine)
% y(t) = Asin(wt)

% Normal signals with harmonics added to simulate real power line condition
for i=1:50
    % [0.95, 1.05] volts: Normal condition amplitude interval
    A = 0.95 + 0.1*rand(1,1);
    
    y = A*sin(2*pi*50*t);    
    y = y + A*yhr;
    
    % Calculate peaks for each half period
    abs_signal = abs(y);

    z=1;
    for k=0:100:900
        local_max(z)=max(abs_signal((k+1:k+100)));
        z=z+1;
    end
 
    % Do full spectrum S-Transform up to 1500 Hz
    % When moving to C++ we use only frequency rows
    % which are used in feature extraction
    [st_matrix, times, frequencies] = st(y, 0, 1500, Fs);

    % |S(tau, f)|: magnitude calculation, plot contours if required
    st_power = abs(st_matrix);
    % contourf(st_power); 
    % countour(st_power);
    
    % Normalize values by dividing 2
    
    % 50 Hz contour
    mean_50 = mean(st_power(6,:))/2;
 
    min_50 = min(local_max)/2;
    
    max_50 = max(local_max)/2;
 
    mean_150 = mean(st_power(16,:));

    mean_250 = mean(st_power(26,:));

    mean_350 = mean(st_power(36,:));

    % Consider high order harmonics
    mean_700_up = mean(sum(st_power(m_index,:)));
        
    loop_features = [mean_50; min_50; max_50; mean_150; mean_250; mean_350; mean_700_up];
    
    if i==1
        features = loop_features;
        target_vector = [1; 0; 0];
    else
        features = [features loop_features];
        target_vector = [target_vector [1; 0; 0]];
    end
    
    
end

%% Voltage Sag (Dip in British English)
% Model:
% y(t) = A(1-alfa*(u(t-t1)-u(t-t2)))sinwt
% 0.1 <= alfa <= 0.9
% T <= t2-t1 <= 9T

% 0.1 .. 0.9 volts considered as sag
% 0.0 .. 0.1 volts considered as interruption 

% Constant Parameter
t1 = 0.02;

for i=1:40

    t2 = 2*t1 + 0.02*floor(4*rand(1,1));

    alfa = 0.1 + 0.8*rand(1,1);

    ys = A*(1-alfa*((t-t1>=0)-(t-t2>=0))).*sin(2*50*pi*t);
    
    ys = ys + (1-alfa)*yhr;
   
    [st_matrix, times, frequencies] = st(ys, 0, 1500, Fs);


    st_power = abs(st_matrix);        

    abs_signal = abs(ys);

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
       
    loop_features = [mean_50; min_50; max_50; mean_150; mean_250; mean_350; mean_700_up];
      
    features = [features loop_features];
    target_vector = [target_vector [0; 1; 0]];

end

% 10 signal with all periods are sag
% Otherwise its observed that Neural Network can classify this case as NORMAL
for i=1:10

    t2 = 2*t1 + 0.02*floor(4*rand(1,1));

    alfa = 0.11 + 0.8*rand(1,1);

    y1 = (1-alfa)*sin(2*50*pi*t);   
    
    y1 = y1 + (1-alfa)*yhr; 

    [st_matrix, times, frequencies] = st(y1, 0, 1500, Fs);
    
    st_power = abs(st_matrix);    
        
    % Local Max for interruption
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
       
    loop_features = [mean_50; min_50; max_50; mean_150; mean_250; mean_350; mean_700_up];
      
    features = [features loop_features];
    target_vector = [target_vector [0; 1; 0]];

end


%% Harmonics
% Model:
% y(t) = A[alfa1*sin(wt)+alfa3*sin(3wt)+alfa5*sin(5wt)+alfa7*sin(7wt)]
% 0.05 <= alfa3,5,7 <= 0.15 ; alfa1^2 + alfa3^2 + alfa5^2  + alfa7^2 = 1

for i=1:50
    
    alfa3 = 0.05 + 0.1*rand(1,1);
    alfa5 = 0.05 + (0.1-alfa3^2)*rand(1,1);
    alfa7 = 0.05 + (0.1-alfa3^2-alfa5^2)*rand(1,1);

    alfa1 = sqrt(1-(alfa3^2+alfa5^2+alfa7^2));

    % Do not add harmonics in this turn
    yh = A*( alfa1*sin(2*pi*50*t) + alfa3*sin(2*pi*150*t) +  alfa5*sin(2*pi*250*t) + alfa7*sin(2*pi*350*t));

    [st_matrix, times, frequencies] = st(yh, 0, 1500, Fs);
    
    st_power = abs(st_matrix);

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
       
    loop_features = [mean_50; min_50; max_50; mean_150; mean_250; mean_350; mean_700_up];
      
    features = [features loop_features];
    target_vector = [target_vector [0; 0; 1]];   
    
end

% Train with gradient decent, hidden layer count equals 2*num_inputs+1
pq_net = feedforwardnet(2*7+1, 'traingd');

% Gradient descent convergences too slow; Levenberg-Marquadt can be used
% for backpropagation
% pq_net = feedforwardnet(2*7+1, 'trainlm');

pq_net.layers{1}.transferFcn= 'tansig';
pq_net.layers{2}.transferFcn= 'purelin';

pq_net.trainParam.epochs = 100000;
pq_net.trainParam.goal = 0.01;
pq_net.trainParam.lr =  0.07;

% Do not processing on inputs and outputs
% to simplify weights exportation
pq_net.inputs{1}.processFcns = {};
pq_net.outputs{2}.processFcns = {};

[pq_net tr] = train(pq_net, features, target_vector);

% Save both features and trained net with performance plot
save('features.mat','features');
save('neuro.mat', 'pq_net');
save('perfplot.mat', 'tr');

