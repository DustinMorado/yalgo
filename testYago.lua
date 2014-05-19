local yago = require 'yago'

local sString = 'a,     b,    c_,    d,     e_,      f,    g'
local lString = 'alpha, beta, gamma, delta, epsilon, zeta, eta'

local status, arg, Opts = pcall(yago.getOpt, arg, sString, lString)
if not status then
   print(arg)
   return 1
end

print(sString, '\n')
print(lString, '\n')
for i,v in ipairs(arg) do 
   print(v, '\n')
end
for k,v in pairs(Opts) do
   print(k, v, '\n')
end
