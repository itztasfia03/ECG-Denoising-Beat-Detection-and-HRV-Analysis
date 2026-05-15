function [ecg_dc, ecg_hp, ecg_notch, ecg_filt] = preprocess_ecg(ecg, fs)

    %dc offset
    ecg_dc = ecg - mean(ecg);
    %high pass filtering of 0.5Hz
    [b_hp,a_hp] = butter(4, 0.5/(fs/2), 'high');
    ecg_hp = filtfilt(b_hp,a_hp,ecg_dc);
    %notch filtering of 60Hz powerline intereference
    wo = 60/(fs/2);
    bw = wo/30;
    [b_notch,a_notch] = iirnotch(wo,bw);
    ecg_notch = filtfilt(b_notch,a_notch,ecg_hp);
    %bandpass filtering(5 to 40Hz)
    [b_bp,a_bp] = butter(4, [5 45]/(fs/2), 'bandpass');
    ecg_filt = filtfilt(b_bp,a_bp,ecg_notch);

end
