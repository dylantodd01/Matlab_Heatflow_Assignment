function minTileThickness = shootingMethod(maxAllowableTemp, tile_number)
% SHOOTINGMETHOD calculates the minimum tile thickness needed for the
%   internal tile temperature not to exceed the space shuttle melting
%   temperature
%   maxAllowableTemp = the melting point of the space shuttle 
%   tileThickness = the minimum required tile thickness

% Initialise initial conditions
thermCon = 0.0577;
density = 144;
specHeat = 1262;
nt = 501;
tmax = 4000;
nx = 21;

% First guesses
G1 = 0.001;
G2 = 0.1;
guesses = [G1, G2];

% Calculate max temp values from initial guesses
[~, ~, u] = shuttle(tmax, nt, G1, nx, 'Crank-Nicolson', ...
        tile_number, thermCon, density, specHeat);
temp1 = max(u(:,end));
[~, ~, u] = shuttle(tmax, nt, G2, nx, 'Crank-Nicolson', ...
        tile_number, thermCon, density, specHeat);
temp2 = max(u(:,end));

% Calculate errors for first two guesses
e1 = maxAllowableTemp - temp1;
e2 = maxAllowableTemp - temp2;

% Set max allowable error and max number of guesses
maxError = 1;
n = 1;
maxGuesses = 15;

% Run until value is reached or has exceeded max guesses
while (abs(e2) > maxError && n < maxGuesses)
    
    % Calculate value of third guess
    G3 = G2 - ((G2 - G1)/(e2 - e1)) * e2;

    [~, ~, u] = shuttle(tmax, nt, G3, nx, 'Crank-Nicolson', ...
        tile_number, thermCon, density, specHeat);
    temp3 = max(u(:,end));
    e3 = maxAllowableTemp - temp3;
    
    % Reset for next iteration
    G1 = G2;
    G2 = G3;
    e1 = e2;
    e2 = e3;
    
    n = n + 1;
    
end  

minTileThickness = G3;

end