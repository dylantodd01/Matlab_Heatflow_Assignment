% Spacial Stability Script

tile_number = 597;

% Initialise tile properties
thermCon = 0.0577;
density = 144;
specHeat = 1262;

% Initialise thickness and no. spacial steps
nt = 501;
tmax = 4000;

thick = 0.05;
i = 0;
for nx = 2:2:30
    % Calculate new dt value and add it to dt vector
    i = i + 1;
    dx(i) = thick/(nx-1);
    
    disp(['nx = ' num2str(nt) ', dx = ' num2str(dx(i)) ' m'])
    
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
xlim([0 30])
ylim([300 400])
xlabel('Spacial Step dx (m)')
ylabel('Inner Surface Temperature (K)')
legend('Forward', 'Dufort-Frankel', 'Backward Differencing', 'Crank-Nicolson')