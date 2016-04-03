function matrix2latextab(matrix, varargin)

% function: matrix2latextab(...)
% Author:   Benjamin Auffarth
% Contact:  auffarth@csc.kth.se
% Version:  0.9
% Date:     Jan 10, 2012
% based on M. Koehler's matrix2latex. 
% 
% This script is an extension of matrix2latex. It includes several changes 
% with respect to the latter: 
% 1. nicer printing (based on booktabs)
% 2. print to screen by default (but allow filename as an option)
% 3. predefine a default number format argument: %-6.2f
% 4. (optionally) set cell background in gray shade as a color code for values. 
%    This option is off by default and can be set by the parameter value pair 'colorcode',1. 
%    It can be useful for example for correlation matrices. 
%
% By default, gray shades are scaled from 0 to 1 if absolute values of the 
% matrix are below 1 and above 0. If they are not below 1, then gray shades 
% are rescaled linearly by the maximum value of matrix. 
% 
% Instead of using \hline, or \hline\hline or other macros, I decided to
% make use of the booktabs package, which supports the output of 
% publication quality tables. Therefore, you should include this in your 
% latex document preamble: 
% \usepackage{booktabs}
%
% If you decide to use color coding, in addition to booktabs, you should 
% load the colortbl package: 
% \usepackage{colortbl}
%
% In addition to other parameters, filename sets writing to file (see
% below). 
%
% This software is published under the GNU GPL, by the free software
% foundation. For further reading see: http://www.gnu.org/licenses/licenses.html#GPL
%
% Usage:
% matrix2late(matrix, filename, varargs)
% where
%   - matrix is a 2 dimensional numerical or cell array
%   - filename is a valid filename, in which the resulting latex code will
%   be stored
%   - varargs is one ore more of the following (denominator, value) combinations
%      + 'rowLabels', array -> Can be used to label the rows of the
%      resulting latex table
%      + 'columnLabels', array -> Can be used to label the columns of the
%      resulting latex table
%      + 'alignment', 'value' -> Can be used to specify the alginment of
%      the table within the latex document. Valid arguments are: 'l', 'c',
%      and 'r' for left, center, and right, respectively
%      + 'format', 'value' -> Can be used to format the input data. 'value'
%      has to be a valid format string, similar to the ones used in
%      fprintf('format', value);
%      + 'size', 'value' -> One of latex' recognized font-sizes, e.g. tiny,
%      HUGE, Large, large, LARGE, etc.
%      + 'filename', 'value' -> a filename of a file to write to
%
% Example input:
%   matrix = [1.5 1.764; 3.523 0.2];
%   rowLabels = {'row 1', 'row 2'};
%   columnLabels = {'col 1', 'col 2'};
%   matrix2latextab(matrix, 'filename','out.tex', 'rowLabels', rowLabels, 'columnLabels', columnLabels, 'alignment', 'c', 'format', '%-6.2f', 'size', 'tiny');
%
% The resulting latex file can be included into any latex document by:
% /input{out.tex}
%

    rowLabels = [];
    colLabels = [];
    alignment = 'l';
    format = '%-6.2f';
    textsize = [];
    filename = [];
    iscolored=false;
	
    if nargin < 1
        %     if (rem(nargin,2) == 1 || nargin < 1)
        error('matrix2latextab: ', 'Incorrect number of arguments to %s.', mfilename); 
    end

    okargs = {'rowlabels','columnlabels', 'alignment', 'format', 'size','filename','colorcode'};
    for j=1:2:(nargin-2)
        pname = varargin{j};
        pval = varargin{j+1};
        k = strmatch(lower(pname), okargs);
        if isempty(k)
            error('matrix2latextab: Unknown parameter name: %s.', pname);
        elseif length(k)>1
            error('matrix2latextab: Ambiguous parameter name: %s.', pname);
        else
            switch(k)
                case 1  % rowlabels
                    rowLabels = pval;
                    if isnumeric(rowLabels)
                        rowLabels = cellstr(num2str(rowLabels(:)));
                    end
                case 2  % column labels
                    colLabels = pval;
                    if isnumeric(colLabels)
                        colLabels = cellstr(num2str(colLabels(:)));
                    end
                case 3  % alignment
                    alignment = lower(pval);
                    if alignment == 'right'
                        alignment = 'r';
                    end
                    if alignment == 'left'
                        alignment = 'l';
                    end
                    if alignment == 'center'
                        alignment = 'c';
                    end
                    if alignment ~= 'l' && alignment ~= 'c' && alignment ~= 'r'
                        alignment = 'l';
                        warning('matrix2latextab: ', 'Unkown alignment. (Set it to \''left\''.)');
                    end
                case 4  % format
                    format = lower(pval);
                case 5  % textsize
                    textsize = pval;
                case 6  % filename
                    filename= pval;
				case 7 % colorcode
					iscolored = pval; % truth value: either true (>0) or false (0). 
            end
        end
    end
        
    if(~isempty(filename)) 
        fid = fopen(filename, 'w');
    else
        fid=1; % print to screen
    end
    
	grayscalenorm=max(abs(matrix(:)));
	if grayscalenorm<1
		grayscalenorm=1;
	end
	
    width = size(matrix, 2);
    height = size(matrix, 1);

    if isnumeric(matrix)
        matrix = num2cell(matrix);
        for h=1:height
            for w=1:width
				if iscolored
                   matrix{h, w} = ['\cellcolor[gray]{' num2str(abs(matrix{h, w}/grayscalenorm),'%-6.2f') '} ' num2str(matrix{h, w}, format)];
				else
				   matrix{h, w} = [num2str(matrix{h, w}, format)];
				end
            end
        end
    end
    
    if(~isempty(textsize))
        fprintf(fid, '\\begin{%s}\n', textsize);
    end

    fprintf(fid, '\\begin{tabular}{');

    if(~isempty(rowLabels))
        fprintf(fid, 'l ');
    end
    for i=1:width
        fprintf(fid, '%c ', alignment);
    end
    fprintf(fid, '}\n\\toprule\n');
    
    %fprintf(fid, '\\hline\r\n');
    
    if(~isempty(colLabels))
        if(~isempty(rowLabels))
            fprintf(fid, '&');
        end
        for w=1:width-1
            fprintf(fid, '\\textbf{%s}&', colLabels{w});
        end
        fprintf(fid, '\\textbf{%s}\\\\\n\\midrule\n', colLabels{width});  % \\\\\\hline\r\n
    end
    
    for h=1:height
        if(~isempty(rowLabels))
            fprintf(fid, '\\textbf{%s}&', rowLabels{h});
        end
        for w=1:width-1
            fprintf(fid, '%s&', matrix{h, w});
        end
        fprintf(fid, '%s\\\\\n', matrix{h, width}); % \\\\hline\r\n
    end

    fprintf(fid, '\\bottomrule\n\\end{tabular}\n');
    
    if(~isempty(textsize))
        fprintf(fid, '\\end{%s}\n', textsize);
    end

    if(~isempty(filename)) 
        fclose(fid);
    end    