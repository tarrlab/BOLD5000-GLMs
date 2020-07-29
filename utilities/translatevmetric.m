function f = translatevmetric(x)

f = 1 - x.^2;

f(f<0) = 0;

f = sqrt(f) ./ x;

f(isinf(f)) = NaN;

end

