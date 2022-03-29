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
uf = [];
ud = [];
ub = [];
uc = [];
for nx = 2:2:40
    % Calculate new dt value and add it to dt vector
    i = i + 1;
    dx(i) = thick/(nx-1);
    
    disp(['nx = ' num2str(nt) ', dx = ' num2str(dx(i)) ' m'])
    
    [~, ~, u] = shuttle(tmax, nt, thick, nx, 'Forward Differencing', ...
        tile_number, thermCon, density, specHeat);
    uf(end+1) = u(end, nx);
    
    [~, ~, u] = shuttle(tmax, nt, thick, nx, 'Dufort-Frankel', ...
        tile_number, thermCon, density, specHeat);
    ud(end+1) = u(end, nx);
    
    [~, ~, u] = shuttle(tmax, nt, thick, nx, 'Backward Differencing', ...
        tile_number, thermCon, density, specHeat);
    ub(end+1) = u(end, nx);
    
    [~, ~, u] = shuttle(tmax, nt, thick, nx, 'Crank-Nicolson', ...
        tile_number, thermCon, density, specHeat);
    uc(end+1) = u(end, nx);

end
plot(dx, [uf; ud; ub; uc]);
grid on
xlim([0 0.01])
ylim([300 380])
xlabel('Spacial Step dx (m)')
ylabel('Inner Surface Temperature (K)')
legend('Forward', 'Dufort-Frankel', 'Backward Differencing', 'Crank-Nicolson')