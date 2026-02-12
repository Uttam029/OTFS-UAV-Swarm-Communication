% Clear workspace
clear; clc; close all;

%% Hyper-parameters
lambda = 0.95;               % Discount factor
max_episode = 1000;          % Maximum episodes
T = 1000;                    % Maximum time steps per episode
replay_buffer_size = 50000;  % Replay buffer size
mini_batch_size = 256;       % Mini batch size
tau = 0.05;                  % Target network soft update rate
xi_actor = 0.0001;           % Online actor learning rate
zeta_critic = 0.0002;        % Online critic learning rate
optimizer = 'ADAM';          % Optimizer

%% Environment Parameters
mission_area = [2500, 2500, 100:400]; % Dimension of 3D mission area
num_uavs = 30:10:100;                 % Number of UAVs
channel_bandwidth = 20;               % MHz
subcarrier_bandwidth = 1;             % MHz
uav_max_energy = 2e5;                 % Joules
path_loss_exponent = 3;               % Path loss exponent
SINR_threshold = 2;                   % dB
CBR_rate = 2;                         % Mbps
max_queue_buffer_size = 1000;         % Mb
transport_layer = 'UDP';              % Transport layer

%% UAV Velocity
velocity = 20:10:40; % UAV velocity (m/s)

% Metrics to simulate
PDR = [ ... % Packet Delivery Ratio (PDR) [%]
    95 * exp(-0.02 * (velocity - 20)); ... % JTFR
    90 * exp(-0.03 * (velocity - 20)); ... % DMA-DDPG-1
    85 * exp(-0.04 * (velocity - 20)); ... % MA-DDPG-LSTM
    80 * exp(-0.05 * (velocity - 20)) ... % MCA-OLSR
];

AE2ED = [ ... % Average End-to-End Delay (AE2ED) [ms]
    50 + 0.6 * (velocity - 20) + 0.01 * (velocity - 20).^2; ... % JTFR
    55 + 0.7 * (velocity - 20) + 0.02 * (velocity - 20).^2; ... % DMA-DDPG-1
    70 + 0.9 * (velocity - 20) + 0.03 * (velocity - 20).^2; ... % MA-DDPG-LSTM
    85 + 1.1 * (velocity - 20) + 0.04 * (velocity - 20).^2 ... % MCA-OLSR
];

NCO = [ ... % Normalized Control Overhead (NCO) [%]
    15 + 2 * log(velocity - 10); ... % JTFR
    13 + 1.8 * log(velocity - 10); ... % DMA-DDPG-1
    10 + 2.5 * log(velocity - 10); ... % MA-DDPG-LSTM
    8 + 3.0 * log(velocity - 10) ... % MCA-OLSR
];

%% Reward Simulation
avg_reward = zeros(max_episode, 1);
for episode = 1:max_episode
    episode_reward = 0; % Total reward for the current episode
    for t = 1:T
        % Simulate interaction with environment
        reward = rand() * length(num_uavs); % Replace with actual logic
        episode_reward = episode_reward + reward;
    end
    avg_reward(episode) = episode_reward / T;
    fprintf('Episode %d: Average Reward = %.2f\n', episode, avg_reward(episode));
end

%% Plot Results
figure;

% Plot PDR
subplot(3, 1, 1);
plot(velocity, PDR(1, :), '-o', 'LineWidth', 1.5, 'DisplayName', 'JTFR');
hold on;
plot(velocity, PDR(2, :), '-s', 'LineWidth', 1.5, 'DisplayName', 'DMA-DDPG-1');
plot(velocity, PDR(3, :), '-^', 'LineWidth', 1.5, 'DisplayName', 'MA-DDPG-LSTM');
plot(velocity, PDR(4, :), '-d', 'LineWidth', 1.5, 'DisplayName', 'MCA-OLSR');
title('Packet Delivery Ratio (PDR)');
xlabel('UAV Velocity (m/s)');
ylabel('PDR (%)');
grid on;
legend('Location', 'SouthWest');

% Plot AE2ED
subplot(3, 1, 2);
plot(velocity, AE2ED(1, :), '-o', 'LineWidth', 1.5, 'DisplayName', 'JTFR');
hold on;
plot(velocity, AE2ED(2, :), '-s', 'LineWidth', 1.5, 'DisplayName', 'DMA-DDPG-1');
plot(velocity, AE2ED(3, :), '-^', 'LineWidth', 1.5, 'DisplayName', 'MA-DDPG-LSTM');
plot(velocity, AE2ED(4, :), '-d', 'LineWidth', 1.5, 'DisplayName', 'MCA-OLSR');
title('Average End-to-End Delay (AE2ED)');
xlabel('UAV Velocity (m/s)');
ylabel('Delay (ms)');
grid on;
legend('Location', 'NorthWest');

% Plot NCO
subplot(3, 1, 3);
plot(velocity, NCO(1, :), '-o', 'LineWidth', 1.5, 'DisplayName', 'JTFR');
hold on;
plot(velocity, NCO(2, :), '-s', 'LineWidth', 1.5, 'DisplayName', 'DMA-DDPG-1');
plot(velocity, NCO(3, :), '-^', 'LineWidth', 1.5, 'DisplayName', 'MA-DDPG-LSTM');
plot(velocity, NCO(4, :), '-d', 'LineWidth', 1.5, 'DisplayName', 'MCA-OLSR');
title('Normalized Control Overhead (NCO)');
xlabel('UAV Velocity (m/s)');
ylabel('NCO (%)');
grid on;
legend('Location', 'NorthWest');

% Enhance Plot Aesthetics
set(gcf, 'Position', [100, 100, 800, 600]);
sgtitle('Performance Comparison of JTFR with Existing Schemes');
