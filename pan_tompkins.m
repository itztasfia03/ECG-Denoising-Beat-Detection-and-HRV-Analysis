function locs_R = pan_tompkins(ecg_filt, fs)
    d = diff(ecg_filt);
    d(end+1) = d(end);

    sq = d.^2;
    win = round(0.12*fs);
    mwi = movmean(sq, win);

    SPKI = 0.1*max(mwi);
    NPKI = 0.05*max(mwi);
    threshold = NPKI + 0.25*(SPKI - NPKI);

    refrac = round(0.3*fs);
    last_peak = -inf;
    locs_R = [];

    for i = 2:length(mwi)-1
        if mwi(i)>mwi(i-1) && mwi(i)>mwi(i+1)
            if (i-last_peak) > refrac
                if mwi(i) > threshold
                    SPKI = 0.125*mwi(i) + 0.875*SPKI;
                    search = i-round(0.05*fs):i+round(0.05*fs);
                    search = search(search>0 & search<=length(ecg_filt));
                    [~,idx] = max(ecg_filt(search));
                    locs_R(end+1) = search(idx);
                    last_peak = i;
                else
                    NPKI = 0.125*mwi(i) + 0.875*NPKI;
                end
                threshold = NPKI + 0.25*(SPKI - NPKI);
            end
        end
    end
    locs_R = unique(locs_R);
end
