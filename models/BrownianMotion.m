% BrownianMotion  SDE model of Geometric Brownian motion
%   Ito Stochastic Differential Equation (SDE)
%        dy(t) = mu*y(t)*dt + sigma*y(t)*dW(t)
%   decribing geometric Brownian motion. The Brain Dynamics toolbox
%   requires the determeinstic and stochastic parts of the SDE to be
%   implemented separately. In this case, the deterministic coefficient is  
%        F(t,y) = mu*y(t)
%   and the stochastic coefficient is
%        G(t,y) = sigma*y(t)
%   The toolbox numerically integrates the combined equations using the
%   fixed step Euler-Maruyama method. Specifically, each step is computed as
%        dy(t) = F(t,y)*dt + G(t,y)*sqrt(dt)*randn()
%   where F(t,y) is implemented by sys.odefun(t,y,a,b)
%   and G(t,y) is implemented by sys.sdefun(t,y,a,b).
%
% Example 1: Using the Brain Dynamics GUI
%   sys = BrownianMotion();       % construct the system struct
%   gui = bdGUI(sys);             % open the Brain Dynamics GUI
% 
% Example 2: Using the Brain Dynamics command-line solver
%   sys = BrownianMotion();                           % system struct
%   sys.pardef = bdSetValue(sys.pardef,'mu',-0.1);    % 'mu' parameter
%   sys.pardef = bdSetValue(sys.pardef,'sigma',0.1);  % 'sigma' parameter
%   sys.vardef = bdSetValue(sys.vardef,'Y',rand);     % 'Y' initial value
%   sys.tspan = [0 10];                               % time domain
%   sol = bdSolve(sys);                               % solve
%   t = sol.x;                                        % time steps
%   Y = sol.y;                                        % solution variables
%   dW = sol.dW;                                      % Wiener increments
%   ax = plotyy(t,Y, t,dW);                           % plot the result
%   xlabel('time');
%   ylabel(ax(1),'Y');
%   ylabel(ax(2),'dW');
%
% Example 3: Using pre-generated (fixed) random values
%   sys = BrownianMotion();                       % construct system struct
%   sys.sdeoption.randn = randn(1,101);           % standard normal values
%   sys.tspan = [0 10];                           % time domain
%   sol1 = bdSolve(sys);                          % solve
%   sol2 = bdSolve(sys);                          % solve (again)
%   plotyy(sol1.x,sol1.y, sol1.x,sol1.dW);        % plot 1st result
%   hold on
%   plotyy(sol2.x,sol2.y, sol2.x,sol2.dW);        % plot 2nd result
%   hold off                                      
%   std(sol1.y - sol2.y)                          % results are identical
%
% Authors
%   Stewart Heitmann (2016a,2017a)

% Copyright (C) 2016,2017 QIMR Berghofer Medical Research Institute
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions
% are met:
%
% 1. Redistributions of source code must retain the above copyright
%    notice, this list of conditions and the following disclaimer.
% 
% 2. Redistributions in binary form must reproduce the above copyright
%    notice, this list of conditions and the following disclaimer in
%    the documentation and/or other materials provided with the
%    distribution.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
% "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
% LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
% FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
% COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
% INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
% BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
% LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
% CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
% LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
% ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.
function sys = BrownianMotion()
    % Handles to our SDE functions
    sys.sdeF   = @sdeF;                 % deterministic coefficients
    sys.sdeG   = @sdeG;                 % stochastic coefficints

    % Our SDE parameters
    sys.pardef = [ struct('name','mu',    'value',-0.1);
                   struct('name','sigma', 'value', 0.1) ];
               
    % Our SDE variables
    sys.vardef =  struct('name','Y', 'value',5);
    
    % Default time span
    sys.tspan = [0 10];
              
   % Specify SDE solvers and default options
    sys.sdesolver = {@sdeEM};           % Relevant SDE solvers
    sys.sdeoption.InitialStep = 0.01;   % SDE solver step size (optional)
    sys.sdeoption.NoiseSources = 1;     % Number of driving Wiener processes

    % Include the Latex (Equations) panel in the GUI
    sys.panels.bdLatexPanel.title = 'Equations'; 
    sys.panels.bdLatexPanel.latex = {'\textbf{SDEdemo1}';
        '';
        'An Ito Stochastic Differential Equation describing geometric Brownian motion';
        '\qquad $dY = \mu\,Y\,dt + \sigma\,Y\,dW_t$';
        'where';
        '\qquad $Y(t)$ is the dynamic variable,';
        '\qquad $\mu$ and $\sigma$ are scalar constants.'};
    
    % Include the Time Portrait panel in the GUI
    sys.panels.bdTimePortrait = [];

    % Include the Solver panel in the GUI
    sys.panels.bdSolverPanel = [];
    
    % Handle to this function. The GUI uses it to construct a new system. 
    sys.self = str2func(mfilename);
end

% The deterministic coefficient function.
function F = sdeF(~,Y,a,~)  
    F = a*Y;
end

% The noise coefficient function.
function G = sdeG(~,Y,~,b)  
    G = b*Y;
end
