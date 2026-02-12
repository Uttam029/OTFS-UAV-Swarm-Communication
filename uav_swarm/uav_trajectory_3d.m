% UAV Swarm Parameters
numUAVs = 10;                % Number of UAVs
missionArea = [2500, 2500];  % Area dimensions (m x m)
altitudeRange = [100, 400];  % Altitude range (m)
vmax = 20;                   % Maximum speed (m/s)
amax = 5;                    % Maximum acceleration (m/s^2)
simulationTime = 1000;       % Total simulation time (s)
deltaT = 1;                  % Time step (s)

% Initialize UAV positions and velocities
positions = rand(numUAVs, 3) .* [missionArea(1), missionArea(2), diff(altitudeRange)] + [0, 0, altitudeRange(1)];
velocities = zeros(numUAVs, 3); % Initial velocities

% Trajectory Control 
for t = 1:simulationTime/deltaT
    % Random accelerations within limits
    accelerations = (2*rand(numUAVs, 3) - 1) * amax;
    % Update velocities and positions
    velocities = velocities + accelerations * deltaT;
    velocities = max(min(velocities, vmax), -vmax); % Limit speeds
    positions = positions + velocities * deltaT;
    
    % Ensure UAVs stay within the mission area and altitude range
    positions(:,1:2) = mod(positions(:,1:2), missionArea); % Wrap around edges
    positions(:,3) = max(min(positions(:,3), altitudeRange(2)), altitudeRange(1));
    
    % Visualization
    scatter3(positions(:,1), positions(:,2), positions(:,3), 50, 'filled');
    xlim([0, missionArea(1)]); ylim([0, missionArea(2)]); zlim(altitudeRange);
    title(['UAV Positions at Time ', num2str(t * deltaT), ' s']);
    xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)');
    grid on; pause(0.01);
end
