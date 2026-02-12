clc; clear; close all;
tic

%% ==== Common Parameters ====
N = 32;
M = 64;
delta_f = 30e3;
T = 1/delta_f;
U = 16;
fc = 15e9;
c = 3e8;
lambda = c / fc;
R = 500;
v_max = 300;
fd_max = v_max / lambda;

SNR_dB = 0:2:30;
SNR = 10.^(SNR_dB/10);
num_bits_per_symbol = 2;
num_iterations = 1e5;
rician_K_dB = 5;
rician_K = 10^(rician_K_dB/10);
ZP_length = 4; 
CP_length = ZP_length;
M_mod = 4;
M_bits = log2(M_mod);

%% ==== Section 1: BER for OFDM vs OTFS ====
BER_OTFS = zeros(size(SNR_dB));
BER_OFDM = zeros(size(SNR_dB));

%% ==== Section 2: BER for OTFS LMMSE / MRC / MPA Detection ====
ber_LMMSE = zeros(length(SNR_dB), 1);
ber_MRC = zeros(length(SNR_dB), 1);
ber_MPA = zeros(length(SNR_dB), 1);

Fn = dftmtx(N)/sqrt(N);
Fm = dftmtx(M)/sqrt(M);
N_fram = 100;

for idx = 1:length(SNR_dB)
    errors_LMMSE = 0;
    errors_MRC = 0;
    errors_MPA = 0;
    total_bits = N * M * M_bits * N_fram;

    for k = 1:N_fram
        % Generate random bits & QPSK modulation
        bits = randi([0 1], N*M*M_bits, 1);
        x = qammod(bits, M_mod, 'InputType', 'bit', 'UnitAveragePower', true);
        X = reshape(x, M, N);

        % OTFS Modulation
        X_tf = Fm' * X * Fn;
        s = reshape(X_tf, [], 1);

        % DD Channel Model
        L = 6;
        h = (randn(L,1) + 1j*randn(L,1))/sqrt(2*L);
        delay = randi([0 M-1], L, 1);
        doppler = randi([-floor(N/2), floor(N/2)], L, 1);

        % Construct channel matrix H
        H = zeros(M*N);
        for l = 1:L
            H = H + h(l) * circshift(eye(M*N), delay(l) + doppler(l)*M);
        end

        % Add AWGN
        noise = sqrt(1/(2*SNR(idx))) * (randn(M*N,1) + 1j*randn(M*N,1));
        y = H * s + noise;

        % Detection Schemes
        x_hat_LMMSE = (H'*H + (1/SNR(idx))*eye(M*N)) \ (H' * y);
        x_hat_MRC = H' * y;
        x_hat_MPA = y ./ diag(H'*H);

        % OTFS Demodulation
        X_LMMSE = Fm * reshape(x_hat_LMMSE, M, N) * Fn';
        X_MRC = Fm * reshape(x_hat_MRC, M, N) * Fn';
        X_MPA = Fm * reshape(x_hat_MPA, M, N) * Fn';

        % Demodulation and BER
        bits_LMMSE = qamdemod(X_LMMSE(:), M_mod, 'OutputType', 'bit', 'UnitAveragePower', true);
        bits_MRC = qamdemod(X_MRC(:), M_mod, 'OutputType', 'bit', 'UnitAveragePower', true);
        bits_MPA = qamdemod(X_MPA(:), M_mod, 'OutputType', 'bit', 'UnitAveragePower', true);

        errors_LMMSE = errors_LMMSE + sum(bits ~= bits_LMMSE);
        errors_MRC = errors_MRC + sum(bits ~= bits_MRC);
        errors_MPA = errors_MPA + sum(bits ~= bits_MPA);
    end

    ber_LMMSE(idx) = errors_LMMSE / total_bits;
    ber_MRC(idx) = errors_MRC / total_bits;
    ber_MPA(idx) = errors_MPA / total_bits;
end

%% ==== Plots ====
figure;
semilogy(SNR_dB, ber_LMMSE, 'b-*', 'LineWidth', 2); hold on;
semilogy(SNR_dB, ber_MRC, 'r--o', 'LineWidth', 2);
semilogy(SNR_dB, ber_MPA, 'g-.s', 'LineWidth', 2);
xlabel('SNR (dB)');
ylabel('BER');
grid on;
legend('LMMSE', 'MRC', 'MPA', 'Location', 'southwest');
title('BER Performance Comparison of the Detection Schemes');


toc
