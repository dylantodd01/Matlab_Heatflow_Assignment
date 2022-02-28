function [x, t, u] = shuttle(tmax, nt, xmax, nx, method, tile_number, thermCon, density, specHeat)
% Function for modelling temperature in a space shuttle tile
% Originally from D N Johnston  18/02/22
% 
%
% Input arguments:
% tmax   - maximum time (s)
% nt     - number of timesteps
% xmax   - total thickness (m)
% nx     - number of spatial steps
% method - solution method ('forward', 'backward' etc)
% tile_number - the tile number
% thermCon - the thermal conductivity
% density - the desity of the tile
% specHeat - the specific4 heat capacity of the tile
%
% Return arguments:
% x      - distance vector (m)
% t      - time vector (s)
% u      - temperature matrix (C or K)


% Run scan graphs function to get all data from all graphs  
scangraphs

% Retrieve relevant tile data file
filename = sprintf("tile_data/temp%d.mat", tile_number);
load(filename, 'tempData');
load(filename, 'timeData');

% Set tile properties
alpha = (thermCon)/(density * specHeat);

% Convert tempData to degrees Celcius
tempData = (tempData - 32) / 1.8;

% Initialise everything.
dt = tmax / (nt - 1);
t = (0:nt-1) * dt;
dx = xmax / (nx-1);
x = (0:nx-1) * dx;
p = (alpha * dt) / (dx^2);
u = zeros(nt, nx);

% Use interpolation to get outside temperature at time vector t
% and store it as left-hand boundary vector L.
L = interp1(timeData, tempData, t, 'linear', 'extrap');

% Set initial conditions equal to boundary temperature at t=0.
u(1, :) = L(1);
u(:, 1) = L; % Outside boundary condition
u(:, nx) = 0; % Inside boundary condition; set to zero as a starting point

i = 2:nx-1; % Set up an index vector

% Interpolate to find the temp data at all the required time intervals        
a = zeros(size(i));
b = zeros(size(i));
c = zeros(size(i));
d = zeros(size(i));

% Select method and run simulation.
switch method
    case 'Forward Differencing'
        % Step through time
        for n=1:nt-1

            % Calculate internal values using forward differencing
            u(n+1,i) = (1 - 2 * p) * u(n,i) + p * (u(n,i-1) + u(n,i+1));
        end

    case 'Dufort-Frankel'

        % Step through time
        for n=1:nt-1
            if n == 1
                nminus1 = 1; % At first timestep, old point doesn't exist as n-1 = 0
                % Use value at timestep 1 instead.
            else
                nminus1 = n-1; % After first timestep, proceed normally
            end

            % Calculate internal values using forward differencing
            % This has been done using vector algebra
            u(n+1,i) = ((1-2*p)*u(nminus1,i) + 2*p * (u(n,i-1) + u(n,i+1)))/(1+2*p);
        end


    case 'Backward Differencing'
        for n=1:nt-1
            R = interp1(timeData, tempData, t(n+1), 'linear','extrap');
            
            % Calculate internal values using backward differencing
            b(1) = 1;
            c(1) = 0;
            d(1) = R;
            a(i) = -p;
            b(i) = 1 + 2*p;
            c(i) = -p;
            d(i) = u(n,i);
            a(nx) = 0;
            b(nx) = 1;
            d(nx) = 0;

            u(n+1,:) = tdm(a,b,c,d);
        end
    case 'Crank-Nicolson'
        for n=1:nt-1
            R = interp1(timeData, tempData, t(n+1), 'linear','extrap');
            
            % Calculate internal values using backward differencing
            b(1) = 1;
            c(1) = 0;
            d(1) = R;
            a(i) = -p/2;
            b(i) = 1+p;
            c(i) = -p/2;
            d(i) = (p/2)*u(n,i-1) + (1-p)*u(n,i) +(p/2)*u(n,i+1);
            a(nx) = 0;
            b(nx) = 1;
            d(nx) = 0;
            
            u(n+1,:) = tdm(a,b,c,d);
        end
    otherwise
        error (['Undefined method: ' method])
end