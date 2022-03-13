% Time Stability Script

tile_number = 597;

% Initialise tile properties
thermCon = 0.0577;
density = 144;
specHeat = 1262;

% Initialise thickness and no. spacial steps
nx = 21;
thick = 0.05;

tmax = 4000;
i = 0;
for nt = 41:20:1001
    % Calculate new dt value and add it to dt vector
    i = i + 1;
    dt(i) = tmax/(nt-1);
    
    %disp(['nt = ' num2str(nt) ', dt = ' num2str(dt(i)) ' s'])
    
    [~, ~, u] = shuttle(tmax, nt, thick, nx, 'Forward Differencing', ...
        tile_number, thermCon, density, specHeat);
    uf(i) = u(end, nx);
    
    [~, ~, u] = shuttle(tmax, nt, thick, nx, 'Dufort-Frankel', ...
        tile_number, thermCon, density, specHeat);
    ud(i) = u(end, nx);
    
    [~, ~, u] = shuttle(tmax, nt, thick, nx, 'Backward Differencing', ...
        tile_number, thermCon, density, specHeat);
    ub(i) = u(end, nx);
    
    [~, ~, u] = shuttle(tmax, nt, thick, nx, 'Crank-Nicolson', ...
        tile_number, thermCon, density, specHeat);
    uc(i) = u(end, nx);
end
plot(dt, [uf; ud; ub; uc]);
grid on
xlim([0 100])
ylim([250 450])
xlabel('Time Step dt (s)')
ylabel('Inner Surface Temperature (K)')
legend('Forward', 'Dufort-Frankel', 'Backward Differencing', 'Crank-Nicolson')