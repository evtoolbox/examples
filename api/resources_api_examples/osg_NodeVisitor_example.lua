-- Example of osg.NodeVisitor usage.
-- Show complete subgraph of Scene object.
-- See results in the console (script will be evaluated Immediately during project startup).

local scene = reactorController:getReactorByName("Scene") -- must be presented in the project

local depth = 0
local nv = osg.NodeVisitor(osg.NodeVisitor.TRAVERSE_ALL_CHILDREN)
nv:setNodeMaskOverride(0xffffffff)
nv:setApplyNodeCb(function(aNode)
	local prefix = ""
	for i = 0, depth do prefix = prefix .. "  " end

	loginfo(string.format("%s'%s' (%s.%s)", prefix, aNode:name(), aNode:libraryName(), aNode:className()))

	depth = depth + 1
	nv:traverse(aNode)
	depth = depth - 1
end)

loginfo("******* Complete subgraph of Scene object *******")
scene.node:accept(nv)
loginfo("*************************************************")
