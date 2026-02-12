function [SNR_dB, BER_OTFS] = OTFS_BER()
    % OTFS parameters
    N = 2;  
    M = 8;  
    M_mod = 4;  
    M_bits = log2(M_mod);  
    eng_sqrt = (M_mod==2) + (M_mod~=2) * sqrt((M_mod-1)/6*(2^2));
    N_syms_perfram = N * M;
    N_bits_perfram = N * M * M_bits;
    
    SNR_dB = 0:2:20;
    SNR = 10.^(SNR_dB/10);
    noise_var_sqrt = sqrt(1 ./ SNR);
    sigma_2 = abs(eng_sqrt * noise_var_sqrt).^2;

    N_fram = 10^4;
    err_ber = zeros(length(SNR_dB), 1);

    for iesn0 = 1:length(SNR_dB)
        for ifram = 1:N_fram
            data_info_bit = randi([0,1], N_bits_perfram, 1);
            data_temp = bi2de(reshape(data_info_bit, N_syms_perfram, M_bits));
            x = qammod(data_temp, M_mod, 'gray');
            x = reshape(x, N, M);
            
            s = OTFS_modulation(N, M, x);
            [taps, delay_taps, Doppler_taps, chan_coef] = OTFS_channel_gen(N, M);
            r = OTFS_channel_output(N, M, taps, delay_taps, Doppler_taps, chan_coef, sigma_2(iesn0), s);
            y = OTFS_demodulation(N, M, r);
            x_est = OTFS_mp_detector(N, M, M_mod, taps, delay_taps, Doppler_taps, chan_coef, sigma_2(iesn0), y);
            
            data_demapping = qamdemod(x_est, M_mod, 'gray');
            data_info_est = reshape(de2bi(data_demapping, M_bits), N_bits_perfram, 1);
            errors = sum(xor(data_info_est, data_info_bit));
            err_ber(iesn0) = err_ber(iesn0) + errors;
        end
    end

    BER_OTFS = err_ber / (N_bits_perfram * N_fram);
end
