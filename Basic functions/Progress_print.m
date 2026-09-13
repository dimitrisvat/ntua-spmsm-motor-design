function Progress_print(taskname, k, N)
% Progress_print("AlignDAxis", k, N)  inside your loop.
% Prints one line that updates in-place using backspaces.

persistent last_pct last_len

if isempty(last_pct), last_pct = -1; end
if isempty(last_len), last_len = 0; end

pct = floor(100 * k / N);

if pct ~= last_pct
    msg = sprintf('[%s] Progress: %3d%%', taskname, pct);

    % Erase previous message using backspaces (works even where \r fails)
    if last_len > 0
        fprintf(repmat('\b', 1, last_len));
    end

    % Print new message
    fprintf('%s', msg);

    % If new msg shorter than old, clear remaining chars
    if length(msg) < last_len
        fprintf(repmat(' ', 1, last_len - length(msg)));
        fprintf(repmat('\b', 1, last_len - length(msg)));
    end

    last_len = length(msg);
    last_pct = pct;

    if k == N
        fprintf('\n');
        last_pct = -1;
        last_len = 0;
    end
end
end

