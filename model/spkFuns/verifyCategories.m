function verifyCategories(categories, validCategories)
%VERIFYCATEGORIES Checks if category names are a subset of
%validCategories. Throws an error if categories contain names not present in
%validCatgories.
%

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
