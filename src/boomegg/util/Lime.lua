-- simple general utility functions
-- created by David Feng 2015-07-28 Tuesday


local lime = {}

function lime.simple_curry(func, parameter)
    return function(...)
        func(parameter, ...)
    end
end

return lime
