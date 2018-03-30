function def = defineIfNotBuiltin( nameOfBuiltin, functionHandle )
    if exist(nameOfBuiltin,'file') == 2
        def = str2func(nameOfBuiltin);
    else
        def = functionHandle;
    end
end

