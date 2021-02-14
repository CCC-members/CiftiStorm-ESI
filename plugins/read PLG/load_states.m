function twstruct = load_states(win_info)

twstruct= [];
if ~isempty(win_info)
    for it = 1:win_info.n
        tmp.type = char(win_info.code(it));
        tmp.start = win_info.begin_arr(it);
        tmp.end = win_info.end_arr(it);
        twstruct = [twstruct tmp];
    end
end
end

    