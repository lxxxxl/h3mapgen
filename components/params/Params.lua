local DetailedParams = require'DetailedParams'

local Params = {}
local Params_mt = { __index = Params, __metatable = "Access resticted." }


--- Overrides generated detailedDarams with the ones given by the user. The 'seed' key is never overridden.
-- @param detailedParams Parameters generated by our system, modified by the function.
-- @param userDetailedParams User given values with higher priority (except 'seed').
local function overrideDetailedParams(detailedParams, userDetailedParams)
  for k, v in pairs(userDetailedParams) do
    if k ~= 'seed' then
      detailedParams[k] = userDetailedParams[k]
    end
  end
end


--- Function generates 'detailedParams' based on user's wishes about the generated map (also overrides generated values with the ones in 'userDetailedParams' if necessary)
-- @param state H3pgm state containing 'userMapParams', 'config' and optionally 'userDetailedParams' keys, which is extended by 'detailedParams'
function Params.GenerateDetailedParams(state)
  if not state.userMapParams then
    error('Given h3pgm state do not contain userMapParams (required by Params.GenerateDetailedParams).', 2)
  end
  DetailedParams.Generate(state)
  if state.userDetailedParams then
    overrideDetailedParams(state.detailedParams, state.userDetailedParams)
  end
end

--- TODO
-- todo
function Params.GenerateInitLMLNode(state)
  if not state.detailedParams then
    error('Given h3pgm state do not contain detailedParams (required by Params.GenerateInitLMLNode).', 2)
  end
  print('Params.GenerateInitLMLNode : status=TODO')
end


return Params
