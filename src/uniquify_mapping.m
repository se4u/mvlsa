function [mapping, unique_mapping]=uniquify_mapping(mapping, use_unique_mapping)
unique_mapping=unique(mapping, 'rows');
if use_unique_mapping
    mapping=unique_mapping;
end