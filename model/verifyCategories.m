function verifyCategories(categories, validCategories)
%VERIFYCATEGORIES Summary of this function goes here
%   Detailed explanation goes here

    if iscellstr(categories) && size(categories,2) > 1
        categories = categories';
    end
    if iscellstr(validCategories) && size(validCategories,2) > 1
        validCategories = validCategories';
    end
    unknownOutcomes = setdiff(categories,unique(validCategories));
    if ~isempty(unknownOutcomes)
        error('Selected categories contain names {%s}, that are not in vaild names {%s}',...
            join(unknownOutcomes,','), join(unique(validCategories),','));
    end
end


