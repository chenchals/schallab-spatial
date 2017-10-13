function [] = nixUpdateAttribs( dirOrFile )
%MAKEWRITABLE Update file or dir attributes on *NIX system
    if isunix
      fileattrib(dirOrFile,'+w +x','a');
    end
end

