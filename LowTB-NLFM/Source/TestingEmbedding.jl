# This file is used to debug the emdedding not working in C++.

global global_variable = 1

function get_global()
    return global_variable
end

function get_local()
    local local_variable = 2
    return local_variable
end

function get_number()
    return 3
end
