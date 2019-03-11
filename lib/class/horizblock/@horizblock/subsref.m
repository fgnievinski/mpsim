function varargout = subsref (A, s)
    %A, s  % DEBUG
    switch s.type
    case '()'
        % let @sparse do the error checking:
        A2 = sparse(A.size(1), A.size(2));
        try
            subsref(A2, s);
        catch
            e = lasterror;
            e.identifier = strrep (e.identifier, 'MATLAB:', ...
                'horizblock:subsref:');
            rethrow(e);
        end
        clear A2

        switch length(s.subs)
        case 0
            [varargout{1:nargout}] = A;
        case 1
            if islogical(s.subs)
                [I,J] = find(s.subs{1});
            else
                [I,J] = ind2sub(A.size, s.subs{1});
            end
            s.subs = {I, J};
            varargout{1:nargout} = subsref(A, s);
        case 2
            row_ind = s.subs{1};
            col_ind = s.subs{2};
            if ( strcmp(row_ind, ':') || isequal(row_ind, 1:A.size(1)) ) ...
            && ( strcmp(col_ind, ':') || isequal(col_ind, 1:A.size(2)) )
                %disp('hw!');
                [varargout{1:nargout}] = A;
                return;
            end
            num_col_per_block = cellfun(@(a) size(a,2), A.data);
            num_blocks = length(A.data);
            block_ind_per_col = cell2mat(arrayfun(@(a,b) repmat(a, 1, b), ...
                1:num_blocks, num_col_per_block, 'UniformOutput',false));
            block_ind = unique(block_ind_per_col(col_ind));
            if length(block_ind) > 1
                error('horizblock:subsref:notSupported', ...
                    'Indexing across individual blocks is not supported.');
            end
            col_ind_in_block = col_ind ...
                - sum(num_col_per_block(1:(block_ind-1)));
            [varargout{1:nargout}] = ...
                A.data{block_ind}(row_ind, col_ind_in_block);
        otherwise
            error('horizblock:subsref:notSupported', ...
                'Case not supported.');
        end
    case '{}'
        try
            [varargout{1:nargout}] = subsref(cell(A), s);
        catch
            e = lasterror;
            e.identifier = strrep (e.identifier, 'MATLAB:', ...
                'horizblock:subsref:');
            rethrow(e);
        end
    case '.'
        error('horizblock:subsref:nonStrucReference', ...
            'Attempt to reference field of non-structure array.');
    end
end

%TODO: add test cases!!!
