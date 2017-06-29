# Power Quality Classification Assesment
Example study on Power Quality Disturbance Classification. Five periods of power signal is used for classification. S-transform (ST) is used for pre-processing of the signals. Distinctive features in the power signal are revelaed with ST. Then feautures are extracted from output of ST. Feed forward back propogation Artificial Neural Network (ANN) is used for classification. In this sample application three types of Power Quality Distrubance (PQD) types are considered:

1. Normal
2. Sag
3. Harmonics

For each type of distrubance, 50 random signals according to signals models specified in the literature are generated. File *train.m* is used to traing the ANN with 150 random signals (3x50). Trainedd ANN is saves as **neuro.mat**. Also features that are used for training is saved as **features.mat**.  

## ST Library
ST library is implemented by using FFTW library. A MEX file created for Matlab _st_ function. Library is tested with Matlab r2013b 64 bits on Windows 7 64 bits.

## Signal models


### Normal signal (Pure Sine):
y(t) = A.sin⁡(ωt)	 { A = 1V (p.u.) ω = 2π.50 rad/sec }

### Voltage Sag (Dip):
y(t) = A[1 - α( u(t - t<sub>1</sub> ) -u(t - t<sub>2</sub> ) )]sin(ωt) {  0.1 < α < 0.9; T < t<sub>2</sub> - t<sub>1</sub> < 5T }

