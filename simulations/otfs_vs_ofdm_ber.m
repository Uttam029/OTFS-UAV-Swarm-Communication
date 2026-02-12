clc;
clear;
close all;
tic

% **Simulation Parameters**
N = 32;              % Number of OTFS time symbols
M = 64;              % Number of OTFS subcarriers
delta_f = 30e3;      % Subcarrier spacing (30 kHz)
T = 1/delta_f;       % Symbol duration
U = 16;              % Number of UAVs
fc = 15e9;           % Carrier frequency (15 GHz)
c = 3e8;             % Speed of light (m/s)
R = 500;             % UAV swarm radius (m)
SNR_dB = 0:2:30;     % SNR range in dB
SNR = 10.^(SNR_dB/10);     % Linear SNR values
num_bits_per_symbol = 2;   % QPSK (2 bits per symbol)
num_iterations = 1e5;      % Monte Carlo iterations
rician_K_dB = 5;           % Rician K-factor in dB
rician_K = 10^(rician_K_dB/10); % Convert to linear scale
ZP = 4;                    % Zero Padding for OTFS

% **Channel Delay and Doppler Resolutions**
delay_resolution = 1/(M*delta_f); % Delay resolution (Δτ)
doppler_resolution = delta_f/N;   % Doppler resolution (Δν)

% **Maximum Delay & Doppler Spread**
tau_max = R/(2*c);
if T < tau_max
    error('Symbol duration T is too small. Increase N or decrease Δf.');
end

% **Maximum Doppler shift (assuming UAV speed = 50 m/s)**
v_max = 50;
doppler_max = (fc * v_max) / c;
if (delta_f / 2) < doppler_max
    error('Subcarrier spacing Δf is too small. Increase Δf.');
end

% **CP/ZP length**
ZP_length = ceil(tau_max * delta_f * M);
CP_length = ZP_length; 

% **BER Initialization**
BER_OTFS = zeros(size(SNR_dB));
BER_OFDM = zeros(size(SNR_dB));

for snr_idx = 1:length(SNR_dB)
    bit_errors_OTFS = 0;
    bit_errors_OFDM = 0;
    
    for iter = 1:num_iterations
        % **Generate QPSK Symbols for OTFS and OFDM**
        x_DD = (2*randi([0 1], M, N) - 1) + 1j * (2*randi([0 1], M, N) - 1); % OTFS
        x_OFDM = (2*randi([0 1], M, N) - 1) + 1j * (2*randi([0 1], M, N) - 1); % OFDM

        % **Apply OTFS Modulation (ISFFT + Heisenberg Transform)**
        X_TF_OTFS = ifft(ifft(x_DD, [], 1), [], 2);  % ISFFT
        s_t_OTFS = reshape(X_TF_OTFS, [], 1);  % Convert to time domain

        % **Apply Zero Padding (ZP) to OTFS**
        s_t_OTFS = [s_t_OTFS; zeros(ZP_length,1)];

        % **Apply OFDM Modulation (IFFT)**
        s_t_OFDM = reshape(ifft(x_OFDM, [], 1), [], 1);  % OFDM signal

        % **Apply Cyclic Prefix (CP) to OFDM**
        s_t_OFDM = [s_t_OFDM(end-CP_length+1:end); s_t_OFDM];

        % **Generate Rician Fading Channel for UAV**
        h_LOS = sqrt(rician_K / (rician_K + 1)); % LOS component
        h_NLOS = sqrt(1 / (rician_K + 1)) * (randn(U, 1) + 1j * randn(U, 1)) / sqrt(2); % NLOS component
        h_rician = h_LOS + h_NLOS; % Rician Fading Channel

        % **Apply Channel to OTFS and OFDM**
        r_t_OTFS = h_rician(1) * s_t_OTFS; % Applying first UAV channel
        r_t_OFDM = h_rician(1) * s_t_OFDM;

        % **Add AWGN Noise**
        noise_var = 1/(2*SNR(snr_idx));
        noise_OTFS = sqrt(noise_var) * (randn(size(r_t_OTFS)) + 1j * randn(size(r_t_OTFS)));
        noise_OFDM = sqrt(noise_var) * (randn(size(r_t_OFDM)) + 1j * randn(size(r_t_OFDM)));
        
        r_t_OTFS = r_t_OTFS + noise_OTFS;
        r_t_OFDM = r_t_OFDM + noise_OFDM;

        % **OTFS Demodulation (Wigner Transform + SFFT)**
        Y_TF_OTFS = reshape(r_t_OTFS(1:M*N), M, N); % Remove ZP
        x_DD_est_OTFS = fft(fft(Y_TF_OTFS, [], 1), [], 2);  % SFFT

        % **OFDM Demodulation (FFT)**
        r_t_OFDM = r_t_OFDM(CP_length+1:end); % Remove CP
        x_DD_est_OFDM = fft(reshape(r_t_OFDM, M, N), [], 1);

        % **Hard Decision for QPSK Detection**
        x_DD_est_real_OTFS = real(x_DD_est_OTFS) > 0;
        x_DD_est_imag_OTFS = imag(x_DD_est_OTFS) > 0;
        x_DD_real_OTFS = real(x_DD) > 0;
        x_DD_imag_OTFS = imag(x_DD) > 0;

        x_DD_est_real_OFDM = real(x_DD_est_OFDM) > 0;
        x_DD_est_imag_OFDM = imag(x_DD_est_OFDM) > 0;
        x_DD_real_OFDM = real(x_OFDM) > 0;
        x_DD_imag_OFDM = imag(x_OFDM) > 0;

        % **Compute BER**
        bit_errors_OTFS = bit_errors_OTFS + sum(sum(x_DD_real_OTFS ~= x_DD_est_real_OTFS)) + sum(sum(x_DD_imag_OTFS ~= x_DD_est_imag_OTFS));
        bit_errors_OFDM = bit_errors_OFDM + sum(sum(x_DD_real_OFDM ~= x_DD_est_real_OFDM)) + sum(sum(x_DD_imag_OFDM ~= x_DD_est_imag_OFDM));
    end

    total_bits = M * N * num_bits_per_symbol * num_iterations;
    BER_OTFS(snr_idx) = bit_errors_OTFS / total_bits;
    BER_OFDM(snr_idx) = bit_errors_OFDM / total_bits;
end

% * Plot BER vs. SNR (OTFS first, then OFDM)**
figure;
semilogy(SNR_dB, BER_OTFS, 'bo-', 'LineWidth', 2); % OTFS first
hold on;
semilogy(SNR_dB, BER_OFDM, 'rs--', 'LineWidth', 2); % OFDM second
xlabel('SNR (dB)');
ylabel('BER');
title('BER vs. SNR: OTFS vs. OFDM in UAV Swarm Communication');
legend('OTFS BER', 'OFDM BER'); % **Legend order corrected**
grid on;
toc;
