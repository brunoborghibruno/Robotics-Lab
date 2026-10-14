% countInBins: multi-D histogram w/fast integer bin sorting
% SYNTAX:   [counts,binLimits,binCenters] = countInBins(X,nBins,minMax)
% INPUTS:   X           rows of multidimensional values, cols are dimension
%           nBins       (optional) # equally-spaced bins, for counting
%           minMax      lower(row1) & upper(row2) bin limits, cols=dims   
% OUTPUTS:  counts      counts at each bin
%           binLimits   delimiting values of all bins, cols=dims
%           binCenters  center values of all bins, cols=dims
%% ~~~~~~~~~~~~~~~~~~~~~~~~~BEGIN FUNCTION: ~~~~~~~~~~~~~~~~~~~~~~~~~~
function [counts,binLimits,binCenters] = countInBins(X,nBins,minMax)
if ~exist('nBins','var'), nBins=10, end       % default if not given
if ~exist('minMax','var'),                    % if not passed 
  mins=min(X); ranges=range(X);               % set to points min and max
else
  mins=minMax(1,:); ranges=range(minMax);
end       
[N,nDim]=size(X);                             % find dimensions 
if N<=2, fprintf('X: >2 rows.'); return; end 
fprintf('\n Sorting (%d points, %d dimensions, %d Bins)...',N,nDim,nBins); 
xb=NaN*X;                                     % init
for dim=1:nDim                                % each column is a dimension
  x=X(:,dim);                                 % get this dimension's data
  MIN=mins(dim);  R=ranges(dim);              % stats on it                                   
  xFractOfRange=(x-MIN)/(R+R*eps);            % fraction, alter2include all  
  xb(:,dim) = uint8(nBins*xFractOfRange +.5); % Xform2binSpace&makeInteger
  binLimits(:,dim)=(MIN)+R/nBins*[0:nBins]';  % delimiters
  binLimits(nBins+1,dim)=binLimits(nBins+1,dim);
  %binCenters(:,dim)=MIN + R/nBins/2 + R/nBins*[0:nBins]'; % halfway
  binCenters(:,dim)=binLimits(:,dim)+R/nBins/2';% halfway
end
binCenters(nBins+1,:)=[];                     % clip off last row

%% nested loop counting depnds on #dimensions. Construct code then use eval
cmd0=['counts=NaN*ones(' num2str(nBins) ',' num2str(nDim) '); '];  % init count
cmd1=['']; % init% setup for loops for each dimension
for dim=1:nDim % loop to set up nested for statements
  cmd1=[cmd1 'for j' num2str(dim) '=1:nBins, '];  
end
cmd2=', comp=['; % setup comparison matrix for all dimensions that match
for dim=1:nDim
  cmd2=[cmd2 'j' num2str(dim) '*ones(N,1) '];  
end
cmd2=[cmd2 ']; ']; 
cmd2=[cmd2 'm=(comp==xb); ']; % N by nDim array of mathing bins
if nDim==1, 
  cmd2=[cmd2 'match=(m==ones(N,1)); ']; 
else
  cmd2=[cmd2 'match=(transpose(sum(transpose(m))))==nDim*ones(N,1); '];
end
cmd3=['counts('];  % init count
for dim=1:nDim
  cmd3=[cmd3 'j' num2str(dim) ','];
end
cmd3(length(cmd3))=[];                                   % removeFinalComma
cmd3=[cmd3 ')=sum( match ); ']; % sumGridMatch
cmd4=['']; % init % wrap up loops in this command string
for dim=1:nDim
  cmd4=[cmd4 'end; '];  
end
cmd=[cmd0 cmd1 cmd2 cmd3 cmd4];   % Put peices together 
eval(cmd);                        % execute the command string

fprintf('done. '); drawnow; pause(.0001);
end % END function