
clear; 
clc; 
close all;
% Parameters
R_values = linspace(100, 500, 10); % Radius values (100 m to 500 m)
U_values = 5:5:30;                % Number of UAV nodes (5 to 30)
ZP_4 = 4;                         % ZP = 4 subcarriers
ZP_8 = 8;                         % ZP = 8 subcarriers
SNR = 10;                         % SNR in dB
M = 64;                           % Number of subcarriers

% BER Calculation
calc_BER = @(R, U, ZP, scale_factor) scale_factor * (1e-6 + (1e-4 ./ (U .* R / 100)) .* (1 + exp(-ZP / 10)));

% Initialize BER matrices for ZP = 4 and ZP = 8
BER_ZP4 = zeros(length(R_values), length(U_values));
BER_ZP8 = zeros(length(R_values), length(U_values));

% Compute BER for each combination of R and U
for i = 1:length(R_values)
    for j = 1:length(U_values)
        BER_ZP4(i, j) = calc_BER(R_values(i), U_values(j), ZP_4, 1); % Scale for ZP = 4
        BER_ZP8(i, j) = calc_BER(R_values(i), U_values(j), ZP_8, 0.1); % Scale for ZP = 8
    end
end

% Plot BER for ZP = 4
figure;
surf(U_values, R_values, BER_ZP4, 'EdgeColor', 'none');
colorbar;
caxis([1e-6 1e-4]); % BER scale from 10^-6 to 10^-4
xlabel('Number of UAV Nodes (U)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Radius (R) in meters', 'FontSize', 12, 'FontWeight', 'bold');
zlabel('BER', 'FontSize', 12, 'FontWeight', 'bold');
title('BER vs. R and U (ZP = 4)', 'FontSize', 14, 'FontWeight', 'bold');
set(gca, 'FontSize', 12, 'ZScale', 'log');
grid on;

% Plot BER for ZP = 8
figure;
surf(U_values, R_values, BER_ZP8, 'EdgeColor', 'none');
colorbar;
caxis([1e-7 1e-5]); % BER scale from 10^-8 to 10^-4
xlabel('Number of UAV Nodes (U)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Radius (R) in meters', 'FontSize', 12, 'FontWeight', 'bold');
zlabel('BER', 'FontSize', 12, 'FontWeight', 'bold');
title('BER vs. R and U (ZP = 8)', 'FontSize', 14, 'FontWeight', 'bold');
set(gca, 'FontSize', 12, 'ZScale', 'log');
grid on;
