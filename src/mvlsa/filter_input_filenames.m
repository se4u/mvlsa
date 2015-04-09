function deptoload=filter_input_filenames(input_filenames, ...
                                          depgroup_to_pick)
    exclude_depgroup=(depgroup_to_pick(1)=='E');
    groups = strsplit(depgroup_to_pick, '@');
    groups = groups(2:end);
    deptoload = {};
    for infi_idx = 1:length(input_filenames)
        infi = input_filenames{infi_idx};
        if xor(any_group_matches(infi, groups), exclude_depgroup)
            % Include this file
            deptoload=[deptoload; infi];
        end
    end
end

function flag = any_group_matches(filename, groups)
    flag = 0;
    for group=groups
        group=group{1};
        flag = flag || group_matches(filename, group);
    end
end

function flag = group_matches(filename, group_acronym)
    switch group_acronym
      case 'fn'
        flag = ~isempty(strfind(filename, '_fnppdb_'));
      case 'mo'
        flag = ~isempty(strfind(filename, '_morphology_'));
      case 'po'
        flag = ~isempty(strfind(filename, '_polyglotwiki_'));
      case 'ag'
        flag = ~isempty(strfind(filename, '_agigastandep_'));
      case 'mi'
        flag = ~isempty(strfind(filename, '_mikolov_'));
      case 'bi'
        flag = ~isempty(strfind(filename, '_bitext_'));
    end
end