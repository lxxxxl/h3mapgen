local Zone = require'graph/Zone'
local GD = require'GraphvizDrawer'

local MLMLHelper = {}
local MLMLHelper_mt = { __index = MLMLHelper, __metatable = "Access resticted." }

-- TODO: Get rid of GenerateOldLMLInterface.
--- Creates serializable LML object interface table that can be used to generate MultiLML
-- @param lml LML graph in new format
-- @return Table with properly formated LML interface
function MLMLHelper.GenerateOldLMLInterface(graph)
  local interface = {}
  for id, node in ipairs(graph) do
    -- from old function Zone:Interface(id)
    local zone = {}
    zone.id = id
    if node.classes[1].type=='LOCAL' then zone.type = 'LOCAL' end
    if node.classes[1].type=='BUFFER' then zone.type = 'BUFFER' end
    if node.classes[1].type=='GOAL' then zone.type = 'GOAL' end
    local edges = {}
    for k, v in pairs(graph.edges[id]) do
      for i = 1, v do edges[#edges+1] = k end
    end
    zone.edges = edges
    local outer = {}
    for _, f in ipairs(node.features) do
      if f.type == 'OUTER' then
        outer[#outer+1] = f.value
      end
    end
    zone.outer = outer
    -- from old interface[i] = k:Interface(i)
    interface[id] = zone
  end
  return interface
end


--- Produces data for MLML graph image
-- @param mlml MLML object
-- @param lml LML graph
-- @return GraphvizDrawer object containing current graph image data
function MLMLHelper.GenerateImage(mlml, lml)
  local gd = GD.New()
  
  local colors = {[0]='#000000', '#b41513', '#4059c6', '#c99e76', '#216228', '#e5760d', '#62336f', '#447174', '#e591a2'} -- taken from HOMM3 flags ^^
  
  gd:AddNode{id=0, shape='none', label=''}
  for i, z in pairs(mlml) do
    local baseclass = lml[z.baseid].classes[1]
    
    local players = {}
    for p=1,8 do
      if z.players[p] then table.insert(players, p) end
    end
    
    local color = colors[0]
    if #players==1 then color = colors[players[1]] end
    
    local label = baseclass.type:sub(1,1)..baseclass.level .. ' (' .. z.baseid .. ') <br/>'
    label = label .. 'P' .. table.concat(players, ',')
    
    --[[
    local labelc = {}
    for _, c in ipairs(z.classes) do
      labelc[#labelc+1] = c.type:sub(1,1)..c.level
    end
    
    local labelf = {}
    for j, f in ipairs(z.features) do
      
      if f.type == 'OUTER' then
        gd:AddNode{id=i..'o'..j, shape='none', label=''}
        gd:AddEdge(i, i..'o'..j, {label=f.value or '', style='bold'})
      elseif f.type == 'TELEPORT' then
        local tid = f.value.id
        if teleports[tid] == nil then
          teleports[tid]=true
          gd:AddNode{id='T'..tid, shape='plaintext', label='T'..tid}
        end
        gd:AddEdge(i, 'T'..tid, {label=f.value.level, style='dotted'})
      else
        labelf[#labelf+1] = f:labelstr(#labelc>1)
      end
    end
    --]]
    local shape = 'none'
    
    if z.type ~= baseclass.type then print('Critical Error Multi<->Single zone type mismatch for MLML zone '..i) end
    
    if     z.type=='LOCAL'  then shape='circle'
    elseif z.type=='BUFFER' then shape='box'
    elseif z.type=='GOAL'   then shape='diamond'
    end
  
    gd:AddNode{id=i, shape=shape, label=label, color=color}
    
    for e, n in pairs(z.edges) do
      if e <= i then -- display only one-direction of edge (from higher id's to lower)
        for j=1, n do gd:AddEdge(i, e) end
      end
    end
  end
  --[[
  for id1, e in pairs(self.edges) do
    for id2, k in pairs(e) do
      if id1 < id2 then
        for i=1,k do gd:AddEdge(id1, id2) end
      end
    end
  end
  --]]
  

  return gd
end
-- MLMLHelper.GenerateImage

return MLMLHelper
