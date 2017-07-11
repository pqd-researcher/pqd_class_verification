# Power Quality Classification & Verification Assesment
Example study on Power Quality Disturbance Classification. Five periods of power signal is used for classification. S-transform (ST) is used for pre-processing of the signals. Distinctive features in the power signal are revelaed with ST. Then features are extracted from output of ST. Feed forward back propogation Artificial Neural Network (ANN) is used for classification. In this sample application three types of Power Quality Distrubance (PQD) types are considered:

1. Normal
2. Sag
3. Harmonics

For each type of distrubance, 50 random signals according to the signal models<sup>[1],[2],[3]</sup> specified in the literature are generated. Sampling rate of synthetic signals is 10 ksps. File *train.m* is used to traing the ANN with 150 random signals (3x50). Trained ANN is saved as **neuro.mat**. Also features that are used for training is saved as **features.mat**. File *confusion.m* is used to evaluate the ANN against newly created signal set with the random parameters. A confusion matrix is constructed after the validation of 150 signals.

### File versions for comparisons
Files in this folder:
* *train.m*: The neural network is trained with the synthetic signals with harmonics
* *confusion.m*: The neural network is tested against synthetic signals with harmonics

Folder **synth_vs_synth**: 
* *train.m*: The neural network is trained with the synthetic signals only
* *confusion.m*: The neural network is tested against synthetic signals only

Folder **synth_vs_harmonics**: Overall accuracy will decrease beacuse of _synthetic_ vs _synthetic with harmonics_ test 
* *train.m*: The neural network is trained with the synthetic signals only
* *confusion.m*: The neural network is tested against synthetic signals with harmonics

### Videos on Practical Applications

This is a single phase real-time PQ classification test. Classification Software is running on Raspberry Pi 3. Sag and Interruption cases are simulated by using a potentiometer connected to output of an AC power adapter.

[Raspberry Pi 3 Power Quality Classifier](http://www.dailymotion.com/video/x5skuoy)

This is a three phase real-time PQ classification test. Classification Software is running on a Notebook Computer.

[Three Phase Power Quality Classifier](http://www.dailymotion.com/video/x5scja8_real-time-power-quality-classifier-application_tech)

## ST Library
ST library is implemented by using FFTW library. A MEX file created for Matlab _st_ function. Library is tested with Matlab r2013b 64 bits on Windows 7 64 bits.

## Signal models

#### Normal signal (Pure Sine):
y(t) = Asin⁡(ωt)

* A = 1V (p.u.)
* ω = 2π.50 rad/sec

#### Voltage Sag (Dip):
y(t) = A[1 - α( u(t - t<sub>1</sub> ) - u(t - t<sub>2</sub> ) )]sin(ωt)

* 0.1 < α < 0.9
* T < t<sub>2</sub> - t<sub>1</sub> < 5T
* T = 20 ms

#### Harmonics:

y(t) = α<sub>1</sub>sin(ωt)+α<sub>3</sub>sin(3ωt)+α<sub>5</sub>sin(5ωt)+α<sub>7</sub>sin(7ωt) 

* 0.05 < α<sub>3</sub> < 0.15
* 0.05 < α<sub>5</sub> < 0.15
* 0.05 < α<sub>7</sub> < 0.15
* ∑α<sub>i</sub><sup>2</sup> = 1
* Calculate α<sub>1</sub> by using the equation above

## References

1. N. C. F. Tse, “Practical application of wavelet to power quality analysis (Published Conference Proceedings style)” in Proc. IEEE PES Gen. Meeting, Montreal, 2006, pp. 1–5.
2. R. Kumar, B. Singh, D. T. Shahani, A. Chandra and K. Al-Haddad, “Recognition of power quality disturbances using S-Transform-Based ANN classifier and rule-based Decision tree”, IEEE Transactions on Industry Applications, vol. 51 no. 2, pp. 1249-1258, Mar. 2015.
3. R. Hooshmand and A. Enshaee, “Detection and classification of single and combined power quality disturbances using fuzzy systems oriented by particle swarm optimization algorithm”, Electric Power Systems Research, vol. 80, no. 12, pp. 1552-1561, Jul. 2010.
