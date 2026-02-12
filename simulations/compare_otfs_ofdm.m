clc;
clear all;
close all;

% Run OTFS and OFDM simulations
[SNR_dB_OTFS, BER_OTFS] = OTFS_BER();
[SNR_dB_OFDM, BER_OFDM] = OFDM_BER();

% Plot BER vs. SNR for both OTFS and OFDM
figure;
semilogy(SNR_dB_OFDM, BER_OFDM, 'ro-', 'LineWidth', 2, 'MarkerSize', 8); hold on;
semilogy(SNR_dB_OTFS, BER_OTFS, 'bs--', 'LineWidth', 2, 'MarkerSize', 8);
hold off;

xlabel('SNR (dB)');
ylabel('Bit Error Rate (BER)');
title('BER vs. SNR for OTFS and OFDM');
legend('OFDM', 'OTFS');
grid on;
