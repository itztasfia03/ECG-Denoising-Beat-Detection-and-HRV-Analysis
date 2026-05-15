***ECG Denoising, R-Peak Detection, and HRV Analysis***



This project implements a complete ECG signal processing pipeline using classical biomedical signal processing techniques. The workflow includes ECG preprocessing, R-peak detection using the Pan–Tompkins algorithm, performance evaluation against expert annotations, and heart rate variability (HRV) analysis in both time and frequency domains.



No machine learning techniques are used in this project.





\## Dataset



The ECG data were obtained from the MIT-BIH Arrhythmia Database available on PhysioNet.



\- Record used: 101  

\- Sampling frequency: 360 Hz  

\- ECG lead: Lead II  

\- Annotation file: `101\_atr.csv` (expert-labeled R-peaks)



PhysioNet link:  

https://physionet.org/content/mitdb/1.0.0/





\## Data Conversion (PhysioNet to CSV)



The original MIT-BIH ECG files (`.dat`, `.hea`, and `.atr`) were downloaded from PhysioNet and converted to CSV format prior to MATLAB analysis. The conversion was performed using the Python `wfdb` library in Visual Studio Code.



The conversion process involved:

\- Reading ECG signal and annotation files using `wfdb`

\- Extracting Lead II ECG samples

\- Exporting ECG samples and annotation indices to CSV files



This step was performed solely for data preparation. All signal processing, analysis, and visualization were conducted in MATLAB.



\*Note: Python scripts used for data conversion are not included, as they were used only for file format preparation and not for signal analysis.\*





**## Files Description**



**### main\_ecg\_analysis.m**

Main script that executes the complete ECG processing pipeline. The script performs:

\- ECG data loading and normalization

\- Segmentation (10 s, 60 s, and full ECG)

\- Noise removal and preprocessing

\- R-peak detection using the Pan–Tompkins algorithm

\- Heart rate computation

\- Performance evaluation (TP, FP, FN, Sensitivity, PPV)

\- Time-domain and frequency-domain HRV analysis

\- Visualization of ECG signals, detected R-peaks, and HRV metrics







**### preprocess\_ecg.m**

Function that performs ECG preprocessing. The following steps are applied sequentially:

1\. DC offset removal  

2\. High-pass filtering at 0.5 Hz (baseline wander removal)  

3\. Notch filtering at 60 Hz (power-line interference removal)  

4\. Band-pass filtering from 5–45 Hz (QRS complex enhancement)



Zero-phase filtering is applied using forward–backward filtering to prevent phase distortion.







**### pan\_tompkins.m**

Implementation of the classical Pan–Tompkins QRS detection algorithm. The function includes:

\- Differentiation

\- Squaring

\- Moving window integration

\- Adaptive thresholding

\- Refractory period enforcement

\- Local peak search for accurate R-peak localization



The function returns the sample indices of detected R-peaks.





**### 101.csv**

ECG signal data (Lead II) converted from the original PhysioNet format.





**### 101\_atr.csv**

Annotation file containing expert-labeled R-peak locations used for performance evaluation.





**## How to Run the Code**



1\. Open MATLAB.

2\. Set the working directory to the folder containing the code files.

3\. Ensure the following files are present in the directory:

&nbsp;  - main\_ecg\_analysis.m

&nbsp;  - preprocess\_ecg.m

&nbsp;  - pan\_tompkins.m

&nbsp;  - 101.csv

&nbsp;  - 101\_atr.csv

4\. Run the main script:

&nbsp;  MATLAB

&nbsp;  main\_ecg\_analysis



