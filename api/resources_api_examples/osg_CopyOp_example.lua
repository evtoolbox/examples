-- CopyOp example

-- See results in the console

local origNode = osg.Group()
origNode:setName("Original Node")
origNode:setUpdateCallback(osg.NodeCallback(function(node, noveVisitor)
	loginfo("Updating '" .. node:getName() .. "'") end))

local clonedNode1 = origNode:clone(
	osg.CopyOp(bit_or(osg.CopyOp.DEEP_COPY_NODES))):asNode()
clonedNode1:setName("Cloned Node 1")
local clonedNode2 = origNode:clone(
	osg.CopyOp(bit_or(osg.CopyOp.DEEP_COPY_NODES,
					  osg.CopyOp.DEEP_COPY_CALLBACKS))):asNode()
clonedNode2:setName("Cloned Node 2")

local root = osg.Group()
root:addChild(origNode)
root:addChild(clonedNode1)
root:addChild(clonedNode2)


local scene = reactorController:getReactorByName("Scene")
scene.node:addChild(root)
