%bdSolve  Solve an initial-value problem using the Brain Dynamics Toolbox
%Usage: 
%   [sol,sox] = bdSolve(sys,tspan,@solverfun,solvertype)
%where
%   sys is a system struct describing the dynamical system
%   tspan=[0 100] is the time span of the integration (optional)
%   @solverfun is a function handle to an ode/dde/sde solver (optional)
%   solvertype is a string describing the type of solver (optional).
%
%   The tspan, @solverfun and solvertype arguments are all optional.
%   If tspan is omitted then it defaults to sys.tspan.
%   If @solverfun is omitted then it defaults to the first solver in sys.
%   If @solverfun is supplied but it is not known to the sys struct then
%   you must also supply the solvertype string ('odesolver', 'ddesolver'
%   or 'sdesolver').
%
%RETURNS
%   sol is the solution structure in the same format as that returned
%      by the matlab ode45 solver.
%   sox is a solution structure that contains any auxiliary variables
%      that the model has defined. The format is the same as sol.
%   Use the bdEval function to extract the results from sol and sox.
%
%EXAMPLE 1
%   sys = LinearODE;                % Linear system of ODEs
%   tspan = [0 10];                 % integration time domain
%   sol = bdSolve(sys,tspan);       % call the solver
%   tplot = 0:0.1:10;               % time domain of interest
%   Y = bdEval(sol,tplot);          % extract/interpolate the solution
%   plot(tplot,Y);                  % plot the result
%   xlabel('time'); ylabel('y');
%
%EXAMPLE 2 (Auxiliary variables)
%   n = 20;                         % number of oscillators
%   Kij = ones(n);                  % coupling matrix (global coupling)
%   sys = KuramotoNet(Kij);         % Kuramoto model
%   tspan = [0 100];                % integration time domain
%   [sol,sox] = bdSolve(sys,tspan); % call the solver
%   tplot = 0:1:100;                % time domain of interest
%   phi = bdEval(sox,tplot,1:n);    % extract auxiliary variables, phi
%   R = bdEval(sox,tplot,n+1);      % extract auxiliary variable, R
%   figure; plot(tplot,phi);        % plot the phi variables
%   xlabel('time'); ylabel('sin(theta)');
%   figure; plot(tplot,R);          % plot the R variable
%   xlabel('time'); ylabel('Kuramoto R');
%
%AUTHORS
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
function [sol,sox] = bdSolve(sys,tspan,solverfun,solvertype)
        % add the bdtoolkit/solvers directory to the path
        addpath(fullfile(fileparts(mfilename('fullpath')),'solvers'));

        % check the number of output variables
        if nargout>2
            error('Too many output variables');
        end
        
        % check the number of input variables
        if nargin<1
            error('Not enough input parameters');
        end
   
        % check the validity of the sys struct and fill missing fields with default values
        try
            sys = bd.syscheck(sys);
        catch ME
            throwAsCaller(ME);
        end

        % use defaults for missing input parameters
        switch nargin
            case 1      % Case of bdSolve(sys)
                % Get tspan from the sys settings. 
                tspan = sys.tspan;
                % Use the first solver found in the sys settings. 
                solvermap = bd.solverMap(sys);
                solverfun = solvermap(1).solverfunc;
                solvertype = solvermap(1).solvertype;
            case 2      % Case of bdSolve(sys,tspan)
                % Use the first solver found in the sys settings. 
                solvermap = bd.solverMap(sys);
                solverfun = solvermap(1).solverfunc;
                solvertype = solvermap(1).solvertype;
            case 3      % Case of bdSolve(sys,tspan,solverfun)
                % Determine the solvertype from the sys settings
                solvertype = bd.solverType(sys,solverfun);
        end
        
        % Call the appropriate solver
        try
            [sol,sox] = bd.solve(sys,tspan,solverfun,solvertype);
        catch ME
            throwAsCaller(ME);
        end
end
