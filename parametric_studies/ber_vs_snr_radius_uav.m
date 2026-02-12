clear; 
clc; 
close all;

% Parameters
R = 50:50:500;             % Radius (meters)
U = 5:5:30;                % Number of UAV nodes
SNR_dB = 0:2:20;           % SNR (dB)
M_values = [16, 32];       % Different subcarrier counts
ZP_lengths = [4, 8];       % ZP lengths
ricianK = 5;               % Rician factor in dB

% Placeholder 
BER_vs_R = zeros(length(R), length(ZP_lengths));       
BER_vs_U = zeros(length(U), length(M_values));         
BER_vs_SNR = zeros(length(SNR_dB), length(M_values));  

% Simulating  BER vs Radius with Different ZP Lengths
for z = 1:length(ZP_lengths)
    ZP = ZP_lengths(z);
    for r = 1:length(R)
        % Simulate BER for given R and ZP
        delaySpread = R(r) / 100; % Delay spread proportional to radius
        BER_vs_R(r, z) = 8 * exp(-ZP / delaySpread); %  BER 
    end
end

% Simulating BER vs Number of UAVs with Different M Values
for m = 1:length(M_values)
    M = M_values(m);
    for u = 1:length(U)
        % Simulate BER for given U and M
        BER_vs_U(u, m) = 10^(-2) * exp(-U(u) / M); 
    end
end

% Simulating  BER vs SNR with Different M Values
for m = 1:length(M_values)
    M = M_values(m);
    for snr = 1:length(SNR_dB)
        SNR = 10^(SNR_dB(snr) / 10); % Convert SNR to linear scale
        BER_vs_SNR(snr, m) = 10^(-1) * qfunc(sqrt(SNR * log2(M))); %  BER scale 
    end
end

% Plotting  BER vs Radius
figure;
plot(R, BER_vs_R(:, 1), '-x', 'LineWidth', 1.5, 'DisplayName', 'ZP Length: 4');
hold on;
plot(R, BER_vs_R(:, 2), '-o', 'LineWidth', 1.5, 'DisplayName', 'ZP Length: 8');
grid on; xlabel('Radius (m)'); ylabel('BER');
title(' BER vs Radius with Different ZP Lengths');
legend('show');
ylim([0 8]); %  BER range
xlim([50 500]); %  radius range

% Plotting  BER vs Number of UAV Nodes
figure;
semilogy(U, BER_vs_U(:, 1), '-x', 'LineWidth', 1.5, 'DisplayName', 'M = 16');
hold on;
semilogy(U, BER_vs_U(:, 2), '-o', 'LineWidth', 1.5, 'DisplayName', 'M = 32');
grid on; xlabel('Number of UAV Nodes'); ylabel('BER');
title(' BER vs Number of UAV Nodes with Different M Values');
ylim([1e-8 1e-2]); % BER range
xlim([5 30]); %  range for UAV nodes
legend('show');

% Plotting BER vs SNR
figure;
semilogy(SNR_dB, BER_vs_SNR(:, 1), '-x', 'LineWidth', 1.5, 'DisplayName', 'M = 16');
hold on;
semilogy(SNR_dB, BER_vs_SNR(:, 2), '-o', 'LineWidth', 1.5, 'DisplayName', 'M = 32');
grid on; xlabel('SNR (dB)'); ylabel('BER');
title(' BER vs SNR with Different M Values');
ylim([1e-9 1e-1]); %  BER range
xlim([0 20]); %  SNR range
legend('show');
