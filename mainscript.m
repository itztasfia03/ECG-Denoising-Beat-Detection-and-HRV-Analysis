clc;
clear;
close all;

data = readmatrix('101.csv.xlsx');
val  = data(:,2);

fs = 360;
G  = 200;
B  = 1024;

ecg = (val - B)/G;
ecg = ecg - mean(ecg);
ecg = ecg / max(abs(ecg));

N = length(ecg);
t = (0:N-1)/fs;

%% SEGMENTATION 
durations = [10 60];
start_idx = 5*fs;

ecg_seg = cell(length(durations),1);
t_seg   = cell(length(durations),1);

for k = 1:length(durations)
    i = durations(k);
    end_idx = start_idx + i*fs - 1;

    ecg_seg{k} = ecg(start_idx:end_idx);
    t_seg{k}   = t(start_idx:end_idx);
end

%% TASK1-RAW ECG PLOTS 
figure;
for k = 1:length(durations)
    subplot(length(durations),1,k)
    plot(t_seg{k}, ecg_seg{k})
    title(sprintf('%d s Raw ECG Segment', durations(k)))
    xlabel('Time (s)')
    ylabel('Amplitude')
    grid on
end

%% TASK-2 PREPROCESSING 
[ecg10_dc, ecg10_hp, ecg10_notch, ecg10_filt] = preprocess_ecg(ecg_seg{durations==10}, fs);
[ecg60_dc, ecg60_hp, ecg60_notch, ecg60_filt] = preprocess_ecg(ecg_seg{durations==60}, fs);
[ecgF_dc,  ecgF_hp,  ecgF_notch,  ecgF_filt ] = preprocess_ecg(ecg, fs);

t10 = t_seg{durations==10};
t60 = t_seg{durations==60};

%% DC OFFSET REMOVAL PLOTS 
figure;
subplot(3,1,1), plot(t10, ecg10_dc), title('10 s – DC Offset Removed'), grid on
subplot(3,1,2), plot(t60, ecg60_dc), title('60 s – DC Offset Removed'), grid on
subplot(3,1,3), plot(t,   ecgF_dc ), title('Full ECG – DC Offset Removed'), grid on

%% HIGH-PASS FILTER PLOTS 
figure;
subplot(3,1,1), plot(t10, ecg10_hp), title('10 s – After HPF (0.5 Hz)'), grid on
subplot(3,1,2), plot(t60, ecg60_hp), title('60 s – After HPF (0.5 Hz)'), grid on
subplot(3,1,3), plot(t,   ecgF_hp ), title('Full ECG – After HPF (0.5 Hz)'), grid on

%%  NOTCH FILTER PLOTS 
figure;
subplot(3,1,1), plot(t10, ecg10_notch), title('10 s – After Notch (60 Hz)'), grid on
subplot(3,1,2), plot(t60, ecg60_notch), title('60 s – After Notch (60 Hz)'), grid on
subplot(3,1,3), plot(t,   ecgF_notch ), title('Full ECG – After Notch (60 Hz)'), grid on

%%  BANDPASS FILTER PLOTS
figure;
subplot(3,1,1), plot(t10, ecg10_filt), title('10 s – After Bandpass (5–40 Hz)'), grid on
subplot(3,1,2), plot(t60, ecg60_filt), title('60 s – After Bandpass (5–40 Hz)'), grid on
subplot(3,1,3), plot(t,   ecgF_filt ), title('Full ECG – After Bandpass (5–40 Hz)'), grid on

%%  PAN–TOMPKINS 

locs_R_60   = pan_tompkins(ecg60_filt, fs);
locs_R_full = pan_tompkins(ecgF_filt,  fs);

%%  R-PEAK PLOTS 
figure;


% -------- 60 s ECG --------
subplot(2,1,1)
plot(t60, ecg60_filt, 'b'); hold on
plot(t60(locs_R_60), ecg60_filt(locs_R_60), ...
     'r.', 'MarkerFaceColor','r', 'MarkerSize',8)
xlim([5 65])
title('R-Peak Detection (60 s)', ...
      'FontSize', 14, 'FontWeight','bold')
xlabel('Time (s)')
ylabel('Amplitude')
grid on

% -------- Full ECG --------
subplot(2,1,2)
plot(t, ecgF_filt, 'b'); hold on
plot(t(locs_R_full), ecgF_filt(locs_R_full), ...
     'r.', 'MarkerFaceColor','r', 'MarkerSize',4)
title('R-Peak Detection (Full ECG)', ...
      'FontSize', 14, 'FontWeight','bold')
xlabel('Time (s)')
ylabel('Amplitude')
grid on


%% HEART RATE 
RR_samples = diff(locs_R_full);
RR_sec = RR_samples / fs;
HR_inst = 60 ./ RR_sec;
HR_avg = mean(HR_inst);

fprintf('Average Heart Rate = %.2f bpm\n', HR_avg);
%% TASK3 PERFORMANCE EVALUATION  

annData = readtable('101_atr.csv');
true_peaks = annData.sample; % Ground truth R-peak locations
detected = locs_R_full;%r peaks from Pan-Tompkins
% Tolerance window (±100 ms)
tol = round(0.1 * fs);
TP = 0; 
FP = 0; 
FN = 0;

% True Positive & False Negative 
for a = 1:length(true_peaks)
    if any(abs(detected - true_peaks(a)) <= tol)
        TP = TP + 1;
    else
        FN = FN + 1;
    end
end

% False Positive
for d = 1:length(detected)
    if ~any(abs(true_peaks - detected(d)) <= tol)
        FP = FP + 1;
    end
end

% Performance Metrics
Sensitivity = TP / (TP + FN + eps);
PPV         = TP / (TP + FP+ eps);

fprintf('\n===R-PEAK DETECTION PERFORMANCE (FULL ECG) ===\n');
fprintf('True Positives (TP): %d\n', TP);
fprintf('False Positives (FP): %d\n', FP);
fprintf('False Negatives (FN): %d\n', FN);
fprintf('Sensitivity: %.4f\n', Sensitivity);
fprintf('Positive Predictive Value (PPV): %.4f\n', PPV);

%%  TASK 4: HRV ANALYSIS 

RR_samples = diff(locs_R_full);
RR = RR_samples / fs;        
RR_clean = RR;
RR_clean(RR_clean < 0.3 | RR_clean > 2.0) = [];
RR_med = median(RR_clean);
RR_clean(abs(RR_clean - RR_med) > 0.2 * RR_med) = [];


RR_clean = medfilt1(RR_clean, 5);
RR_ms = RR_clean * 1000;

Mean_RR = mean(RR_ms);
SDNN    = std(RR_ms);
RMSSD   = sqrt(mean(diff(RR_ms).^2));
pNN50   = sum(abs(diff(RR_ms)) > 50) / (length(RR_ms)-1) * 100;

fprintf('\n==HRV TIME-DOMAIN METRICS===\n');
fprintf('Mean RR (ms): %.2f\n', Mean_RR);
fprintf('SDNN (ms): %.2f\n', SDNN);
fprintf('RMSSD (ms): %.2f\n', RMSSD);
fprintf('pNN50 (%%): %.2f\n', pNN50);


t_rr = cumsum(RR_clean);    

fs_interp = 4;% standard HRV interpolation rate
t_uniform = 0:1/fs_interp:t_rr(end);

RR_interp = interp1(t_rr, RR_ms, t_uniform, 'pchip'); 
RR_interp = RR_interp - mean(RR_interp);


[pxx,f] = pwelch(RR_interp, hamming(256), 128, 1024, fs_interp);

LF_band = [0.04 0.15];
HF_band = [0.15 0.40];

LF = bandpower(pxx, f, LF_band, 'psd');
HF = bandpower(pxx, f, HF_band, 'psd');
LF_HF_ratio = LF / HF;

fprintf('\n===== HRV FREQUENCY-DOMAIN METRICS =====\n');
fprintf('LF power (0.04–0.15 Hz): %.4f\n', LF);
fprintf('HF power (0.15–0.40 Hz): %.4f\n', HF);
fprintf('LF/HF ratio: %.4f\n', LF_HF_ratio);



figure('Color','w','Position',[100 100 900 700]);

%(1) RR Interval Series 
subplot(3,1,1)
plot(t_rr, RR_ms, 'LineWidth', 1.3, 'Color', [0 0.45 0.74])
xlabel('Time (s)','FontSize',11,'FontWeight','bold')
ylabel('RR Interval (ms)','FontSize',11,'FontWeight','bold')
title('RR Interval Series (Cleaned)','FontSize',13,'FontWeight','bold')
grid on
set(gca,'FontSize',10,'LineWidth',1)
ylim([min(RR_ms)-50 max(RR_ms)+50])

%(2)Tachogram
subplot(3,1,2)
HR = 60 ./ RR_clean;
plot(t_rr, HR, 'LineWidth', 1.3, 'Color', [0.85 0.33 0.10])
xlabel('Time (s)','FontSize',11,'FontWeight','bold')
ylabel('Heart Rate (BPM)','FontSize',11,'FontWeight','bold')
title('Tachogram (Cleaned RR)','FontSize',13,'FontWeight','bold')
grid on
set(gca,'FontSize',10,'LineWidth',1)
ylim([min(HR)-5 max(HR)+5])

%(3) HRV Power Spectral Density 
subplot(3,1,3)
plot(f, pxx, 'LineWidth', 1.5, 'Color', [0.49 0.18 0.56])
xlim([0 0.4])
xlabel('Frequency (Hz)','FontSize',11,'FontWeight','bold')
ylabel('Power Spectral Density','FontSize',11,'FontWeight','bold')
title('HRV Power Spectral Density (Welch)','FontSize',13,'FontWeight','bold')
grid on
set(gca,'FontSize',10,'LineWidth',1)

