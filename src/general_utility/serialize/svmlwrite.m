function svmlwrite(fname, X, floatformat, header)
% SVMLWRITE - Write matrix into data file for SVM light
%
%   SVMLWRITE(FNAME, X) writes out matrix X into file FNAME, in the format
%   needed for SVM light. X is a matrix of data points, with one point
%   per row.
%   SVMLWRITE(FNAME, X, Y) writes out data points X with target values
%   given in the column vector Y. In the case of classification, Y(i) may
%   either be +1, -1 or 0 (indicating unknown class label, for
%   transductive SVM). In the case of regression data, Y(i) is
%   real-valued.
%   SVMLWRITE(FNAME, X, Y, FLOATFORMAT) uses format string FLOATFORMAT to
%   write out the features in X (and in case of regression, also the
%   target values Y(i)). Default: '%.16g'
%
%   See also
%   SVM_LEARN, SVMLOPT, SVM_CLASSIFY, SVMLREAD
%

%
% Copyright (c) by Anton Schwaighofer (2001)
% $Revision: 1.8 $ $Date: 2002/02/19 12:28:03 $
% mailto:anton.schwaighofer@gmx.net
%
% This program is released unter the GNU General Public License.
%

error(nargchk(2, 5, nargin));
if ~exist('fileformat'),
  floatformat = '%.16g';
end
[N, d] = size(X);
f = fopen(fname, 'wt');
if (f<0),
  error(sprintf('Unable to open file %s', fname));
end
if exist('header'),
    fprintf(f,[header '\n']);
end
% transpose for increased efficiency when working with sparse matrices
X = X';
%fprintf('Writing ');
for i = 1:N,
    Xi = X(:,i);
    s='';
    % Then follow 'feature:value' pairs
    ind = find(Xi);
    s = [s sprintf(['%i:' floatformat ' '], [ind'; full(Xi(ind))'])];
    fprintf(f, '%s\n', s);
end
%fprintf(' done.\n');

fclose(f);
