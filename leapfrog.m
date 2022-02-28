% leapfrog.m
% ME20021 
%
% MATLAB script to calculate temperature along a rod or through a plate,
% with a triangular initial temperature profile and fixed temperatures at 
% the ends.
% The leap-frog method is used.
%
% D N Johnston  02/02/2021
%
% Exercises: 
% Try different values of p.
% Modify this to use duFort-Frankel method.

clear

% set grid sizes, and create matrices etc
nx = 21;
nt = 101;
xmax = 1;
dx = xmax / (nx-1);
dt = 0.05;
tmax = dt * (nt-1);
x = (0:nx-1)*dx;
t = (0:nt-1)*dt; 
u = zeros(nt, nx);

% set initial conditions.  
u(1,:) = min(x, xmax-x); % triangle profile

% create dialog box for entering value of p
answer = inputdlg('Enter the value of p');

% convert from string to number
p = str2num(answer{1});

%create a graph and show initial conditions. h is a 'handle' to the graph,
%for later use.
figure(1);
h = plot(x,u(1,:), 'x-');

% set y axis range
ylim([-1 1])
% set labels. Note: \it gives italics, \rm gives normal text.
xlabel('\itx\rm - m')
ylabel('\itu\rm - deg C')
title(['Leapfrog, \itp\rm = ' num2str(p)])

% Set vector of indices for internal values.
i=2:nx-1;

% set boundary conditions for all timesteps 
% ([1 nx] specifies both boundaries)
u(:, [1 nx]) = 0;

%now loop through time
for n=1:nt-1
    % Refresh graph
    drawnow
    
    % wait one timestep to give roughly real time display
    pause(dt)
    
    % set index for 'old' point
    if n == 1
        nminus1 = 1; % at first timestep, old point doesn't exist as n-1 = 0.
                     % Use value at timestep 1 instead.
    else
        nminus1 = n-1; % after first timestep, proceed normally.
    end
    % calculate internal values using Leapfrog method
    u(n+1,i) = u(nminus1,i) + 2 * p * (u(n,i-1) - 2 * u(n,i) + u(n,i+1));
    
    % update graph with new values
    set(h,'YData', u(n+1,:));
end

%finally, draw a 3D plot
figure (2);
surf(x, t, u);

% this gives a better appearance
shading interp

% rotate plot. 
view(140,30)

xlabel('\itx\rm - m');
ylabel('\itt\rm - s');
zlabel('\itu\rm - deg C');
title(['Leapfrog, \itp\rm = ' num2str(p)])
