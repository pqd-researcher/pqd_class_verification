# Power Quality Classification Assesment
Example study on Power Quality Disturbance Classification. Five periods of power signal is used for classification. S-transform (ST) is used for pre-processing of the signals. Distinctive features in the power signal are revelaed with ST. Then feautures are extracted from output of ST. Feed forward back propogation Neural Network is used for classification. In this sample application three types of Power Quality Distrubance (PQD) types are considered:

1. Normal
2. Sag
3. Harmonics

For each type of distrubance, 50 random signals according to signals models specified in the literature are generated.

## ST Library
ST library is implemented by using FFTW library. A MEX file created for Matlab _st_ function. Library is tested with Matlab r2013b 64 bits on Windows 7 64 bits.

## Signal models

### Normal signal (Pure Sine):
y(t) = A.sin⁡(ωt)	 { A = 1V (p.u.) ω = 2π.50 rad/sec }


