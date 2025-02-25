function [varargout] = deepcopy(varargin)

% DEEPCOPY makes a deep copy of an array, and returns a pointer to
% the copy. A deep copy refers to a copy in which all levels of data
% are copied. For example, a deep copy of a cell-array copies each
% cell, and the contents of the each cell (if any), and so on.
%
% Example
%   clear a b c
%   a = 1;
%   b = a;            % this is a regular copy
%   c = deepcopy(a);  % this is a deep copy
%   increment(a);     % increment the value of a with one, using pass by reference
%   disp(a);
%   disp(b);
%   disp(c);

% Copyright (C) 2012, Donders Centre for Cognitive Neuroimaging, Nijmegen, NL
%
% This file is part of FieldTrip, see http://www.fieldtriptoolbox.org
% for the documentation and details.
%
%    FieldTrip is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    FieldTrip is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with FieldTrip. If not, see <http://www.gnu.org/licenses/>.
%
% $Id$

% remember the original working directory
pwdir = pwd;

% determine the name and full path of this function
funname = mfilename('fullpath');
mexsrc  = [funname '.c'];
[mexdir, mexname] = fileparts(funname);

try
    % try to compile the mex file on the fly
    warning('trying to compile MEX file from %s', mexsrc);
    cd(mexdir);
    mex(mexsrc);
    cd(pwdir);
    success = true;

catch
    % compilation failed
    disp(lasterr);
    error('could not locate MEX file for %s', mexname);
    cd(pwdir);
    success = false;
end

if success
    % execute the mex file that was just created
    funname   = mfilename;
    funhandle = str2func(funname);
    [varargout{1:nargout}] = funhandle(varargin{:});
end

                                                                                                                                                                                                                                                                                                                                                                                                                                                                               ceived a copy of the GNU General Public License
%    along with FieldTrip. If not, see <http://www.gnu.org/licenses/>.
%
% $Id$

if nargin==1
    if isa(x, 'config')
        % formally no conversion is needed, but a copy will be made in which the counters are reset
        y = deepcopy(x);
        key = fieldnames(x);
        for i=1:length(key)
            setzero(y.assign   .(key{i}));      % reset the counter to zero
            setzero(y.reference.(key{i}));      % reset the counter to zero
            setzero(y.original .(key{i}));      % first set to zero and then increment with one,
            increment(y.original.(key{i}));   % since all fields were present in the original
        end
    elseif isa(x, 'struct')
        % convert the input structure into a config object
        key = fieldnames(x);
        for j=1:numel(x)
            val = {};
            for i=1:length(key)
                try
                    val{i} = x(j).(key{i});
                catch
                    val{i} = [];
                end
                % use recursion to let some other part of the code handle the remainder
                if isa(val{i}, 'struct')
                    val{i} = config(val{i});
                end
            end
            tmp           = struct();
            tmp.value     = struct();
            tmp.assign    = struct();
            tmp.reference = struct();
            tmp.original  = struct();
            tmp.hidden    = struct(); % this contains hidden fields which are not tracked
            for i=1:length(key)
                tmp.value.(key{i})     = val{i};
                tmp.assign.(key{i})    = deepcopy(0); % ensure that a unique scalar is created for each counter
                tmp.reference.(key{i}) = deepcopy(0); % ensure that a unique scalar is created for each counter
                tmp.original.(key{i})  = deepcopy(1); % ensure that a unique scalar is created for each counter
            end
            y(j) = class(tmp,'config');
        end
        if numel(x)
            y = reshape(y, size(x));
        else
            y = config;
        end
    else
        error('Unsupported input class ''%s'' for constructing a config object', class(x));
    end

elseif nargin>1
    if mod(nargin,2)
        error('Incorrect number of input arguments (should be key-value pairs)')
    end
    varargin = {x varargin{:}};
    key = varargin(1:2:end);
    val = varargin(2:2:end);

    % When having y.assign and y.reference point to the same scalars, there is
    % a side effect in the increment function that reveals that the scalars
    % representing the different counters all point to the same physical
    % memory address. Therefore I have to ensure that there is a unique
    % scalar for each individual counter.
    assign    = {};
    reference = {};
    original  = {};
    for i=1:length(key)
        assign   {end+1} = key{i};
        reference{end+1} = key{i};
        original {end+1} = key{i};
        assign   {end+1} = deepcopy(0);  % ensure that a unique scalar is created for each counter
        reference{end+1} = deepcopy(0);  % ensure that a unique scalar is created for each counter
        original {end+1} = deepcopy(1);  % ensure that a unique scalar is created for each counter
    end

    for i=1:length(val)
        if isa(val{i}, 'struct')
            % use recursion to convert sub-structures into sub-configs
            val{i} = config(val{i});
        end
    end

    y.value     = struct(varargin{:});
    y.assign    = struct(assign{:});
    y.reference = struct(reference{:});
    y.original  = struct(original{:});
    y.hidden    = struct();  % this contains hidden fields which are not tracked
    y = class(y,'config');

else
    % create an empty config object
    y           = struct();
    y.value     = struct();
    y.assign    = struct();
    y.reference = struct();
    y.original  = struct();
    y.hidden    = struct(); % this contains hidden fields which are not tracked
    y = class(y,'config');

end

end
