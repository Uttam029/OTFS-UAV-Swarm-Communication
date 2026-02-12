function [SNR_dB, BER_OFDM] = OFDM_BER()
    L = 10000;
    Ncp = L * 0.0625;
    Tx_data = randi([0 15], L, Ncp);
    mod_data = qammod(Tx_data, 16);
    s2p = mod_data.';
    am = ifft(s2p);
    p2s = am.';
    CP_part = p2s(:, end-Ncp+1:end);
    cp = [CP_part p2s];

    SNR_dB = 0:2:20;
    BER_OFDM = zeros(size(SNR_dB));

    c = 0;
    for snr = SNR_dB
        c = c + 1;
        noisy = awgn(cp, snr, 'measured');
        cpr = noisy(:, Ncp+1:Ncp+Ncp);
        parallel = cpr.';
        amdemod = fft(parallel);
        rserial = amdemod.';
        Umap = qamdemod(rserial, 16);
        [~, BER_OFDM(c)] = biterr(Tx_data, Umap);
    end
end
