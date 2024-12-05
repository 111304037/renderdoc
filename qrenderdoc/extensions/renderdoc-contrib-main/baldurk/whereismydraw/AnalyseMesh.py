
# https://zhuanlan.zhihu.com/p/602316635
#批量导出mesh
#https://zhuanlan.zhihu.com/p/643519201

import re
import os
import qrenderdoc as qrd
import renderdoc as rd
import struct
import math
import random
from typing import Callable, Tuple, List

# eidToIndexBufferDict = {}
# eidToVertexBufferDict = {}
# all_buf_usage = {}
grass_event_ids = {}
grass_res_ids = {}

class Stats:
	numTris = 0
	numLods = {}
	numVert = {}
	def __init__(self) -> None:
		pass

	@staticmethod
	def AddAction(controller:renderdoc.ReplayController, action:renderdoc.ActionDescription):
		numIndices = action.numIndices
		numInstances = action.numInstances
		tris = numIndices/3 * numInstances
		Stats.numTris += tris
		Stats.numLods[numIndices] = Stats.numLods.get(numIndices, 0) + numInstances

		# Calculate the mesh input configuration
		meshInputs = getMeshInputs(controller, action)
		indices = getIndices(controller, meshInputs[0])
		numVert = max(indices) + 1 #一般顶点数为index里最大的顶点id
		Stats.numVert[numIndices] = numVert

	@staticmethod
	def Dump():
		print(fr"total draw tris:{int(Stats.numTris)}")
		print("[draw num]")
		for k,v in Stats.numLods.items():
			print(fr"Indices({k})={v}")
		print("[mesh verts]")
		for k,v in Stats.numVert.items():
			print(fr"Indices({k})={v}")

#decode_mesh
#https://renderdoc.org/docs/python_api/examples/renderdoc/decode_mesh.html
class MeshData(rd.MeshFormat):
	indexOffset = 0
	name = ''

# Get a list of MeshData objects describing the vertex inputs at this draw
def getMeshInputs(controller, draw):
	state = controller.GetPipelineState()

	# Get the index & vertex buffers, and fixed vertex inputs
	ib = state.GetIBuffer()
	vbs = state.GetVBuffers()
	attrs = state.GetVertexInputs()

	meshInputs = []

	for attr in attrs:

		# We don't handle instance attributes
		if attr.perInstance:
			raise RuntimeError("Instanced properties are not supported!")
		
		meshInput = MeshData()
		meshInput.indexResourceId = ib.resourceId
		meshInput.indexByteOffset = ib.byteOffset
		meshInput.indexByteStride = ib.byteStride
		meshInput.baseVertex = draw.baseVertex
		meshInput.indexOffset = draw.indexOffset
		meshInput.numIndices = draw.numIndices

		# If the draw doesn't use an index buffer, don't use it even if bound
		if not (draw.flags & rd.ActionFlags.Indexed):
			meshInput.indexResourceId = rd.ResourceId.Null()

		# The total offset is the attribute offset from the base of the vertex
		meshInput.vertexByteOffset = attr.byteOffset + vbs[attr.vertexBuffer].byteOffset + draw.vertexOffset * vbs[attr.vertexBuffer].byteStride
		meshInput.format = attr.format
		meshInput.vertexResourceId = vbs[attr.vertexBuffer].resourceId
		meshInput.vertexByteStride = vbs[attr.vertexBuffer].byteStride
		meshInput.name = attr.name

		meshInputs.append(meshInput)

	return meshInputs

def getIndices(controller, mesh):
	# Get the character for the width of index
	indexFormat = 'B'
	if mesh.indexByteStride == 2:
		indexFormat = 'H'
	elif mesh.indexByteStride == 4:
		indexFormat = 'I'

	# Duplicate the format by the number of indices
	indexFormat = str(mesh.numIndices) + indexFormat

	# If we have an index buffer
	if mesh.indexResourceId != rd.ResourceId.Null():
		# Fetch the data
		ibdata = controller.GetBufferData(mesh.indexResourceId, mesh.indexByteOffset, 0)

		# Unpack all the indices, starting from the first index to fetch
		offset = mesh.indexOffset * mesh.indexByteStride
		indices = struct.unpack_from(indexFormat, ibdata, offset)

		# Apply the baseVertex offset
		return [i + mesh.baseVertex for i in indices]
	else:
		# With no index buffer, just generate a range
		return tuple(range(mesh.numIndices))

# Replay时的回调函数：
def CheckResources(controller:renderdoc.ReplayController):
	# print("CheckResources")

	#pyrenderdoc: qrenderdoc.CaptureContext
	for res in pyrenderdoc.GetResources():
		# res:renderdoc.ResourceDescription
		#   print(res.name)
		if res.type == renderdoc.ResourceType.Shader or res.type == renderdoc.ResourceType.StateObject:
			if 'Grass' in res.name:
				grass_res_ids[res.resourceId] = res
				#List[ResourceId]
				derivedResources = res.derivedResources
				for resId in derivedResources:
					grass_res_ids[resId] = res
					for eventUsage in controller.GetUsage(resId):
						  print(eventUsage.usage)

	# #引用buff的事件
	# for buf in pyrenderdoc.GetBuffers():
	#	 for eventUsage in controller.GetUsage(buf.resourceId):
	#			 # if eventUsage.usage & (renderdoc.ResourceUsage.IndexBuffer) <= 0:
	#					 # continue
	#					 # pass
	#			 matchObj = re.search("(?<=ResourceId::)[0-9]+", str(buf.resourceId), re.M|re.I)
	#			 id = "-1"
	#			 if matchObj:
	#					 id = matchObj.group()
	#			 resourceName = pyrenderdoc.GetResourceName(buf.resourceId) # + ":" + str(id)

	#			 if eventUsage.usage == renderdoc.ResourceUsage.IndexBuffer:
	#					 eidToIndexBufferDict.setdefault(eventUsage.eventId, []).append( resourceName )
	#			 if eventUsage.usage == renderdoc.ResourceUsage.VertexBuffer:
	#					 eidToVertexBufferDict.setdefault(eventUsage.eventId, []).append( resourceName )

	#			 # if eventUsage.eventId == 3474:
	#					 # print(f"{resourceName}, {str(eventUsage.usage)}({int(eventUsage.usage)})")


	#			 int_id = int(id)
	#			 all_buf_usage.setdefault(eventUsage.usage, []).append(str(id) + ":" + pyrenderdoc.GetResourceName(buf.resourceId))
	#			 # if int_id == 3600 or int_id == 3601 or int_id == 6583:
	#					 # print(f"usageEid: {eventUsage.eventId}, {eventUsage.usage}, {str(id) + ':' + pyrenderdoc.GetResourceName(buf.resourceId)}")


def Analyse_Action(controller:renderdoc.ReplayController, action:renderdoc.ActionDescription):
	if action.flags & renderdoc.ActionFlags.Drawcall > 0:
		controller.SetFrameEvent(action.eventId, False)
		# print("play:", action.eventId)
		
		#https://renderdoc.org/docs/python_api/renderdoc/replay.html#renderdoc.ReplayController
		pipe = controller.GetPipelineState()
		# vs:renderdoc.ShaderReflection = pipe.GetShaderReflection(renderdoc.ShaderStage.Vertex)
		# if vs:
		#	 print(vs)
		#	 print(f"VS: {vs.entryPoint} in {vs.debugInfo.files[0].filename if vs.debugInfo.files else 'N/A'}")

		vertShader:renderdoc.ResourceId = pipe.GetShader(rd.ShaderStage.Vertex)
		if vertShader in grass_res_ids:
			grass_event_ids[action.eventId] = action
			Stats.AddAction(controller, action)

def Analyse_Action_Recursion(controller:renderdoc.ReplayController, action:renderdoc.ActionDescription):
	Analyse_Action(controller, action)
	for child in action.children:
		Analyse_Action_Recursion(controller, child)

def Analyse():
	# eid = pyrenderdoc.CurEvent()
	# drawcall = pyrenderdoc.GetAction(eid)
	# Replay时的回调函数：
	def callback(controller:renderdoc.ReplayController):
		# print("Replay callback")
		CheckResources(controller)
		# curRootActions = pyrenderdoc.CurRootActions()
		curRootActions = controller.GetRootActions()
		if not curRootActions:
			print("no actions")
			return
		for action in curRootActions:
			#https://renderdoc.org/docs/python_api/renderdoc/analysis.html#renderdoc.ActionDescription
			#action:renderdoc.ActionDescription
			Analyse_Action_Recursion(controller,action)
		Stats.Dump()
	pyrenderdoc.Replay().BlockInvoke(callback)

	# while action is not None:
	# 	# print("type:",type(action))
	# 	# print(f"EID: {action.eventId}, actionId: {action.actionId}, numIndices: {action.numIndices}, instances: {action.numInstances}")
	# 	if action.eventId in grass_event_ids:
	# 		numIndices = action.numIndices
	# 		numInstances = action.numInstances
	# 		tris = numIndices/3 * numInstances
	# 	meshStr = ""
	# 	# if action.eventId == 3474:
	# 			# print(action.eventId, eidToIndexBufferDict.get(action.eventId, "None"))

	# 	if action.flags & renderdoc.ActionFlags.Drawcall > 0:
	# 			fromVertex = eidToVertexBufferDict.get(action.eventId, ["!!should has mesh!!!!"])[-1] + ":vert"
	# 			# default = "!!should has mesh!!!!"
	# 			meshStr = eidToIndexBufferDict.get(action.eventId, [fromVertex])[0]
	# 	if meshStr != "":
	# 			# print(f"EID: {action.eventId}, {action.flags}, {meshStr}")
	# 			str = f"{action.eventId}, {meshStr}"
	# 			# print(str)
	# 			pass
	# 	action = action.next

Analyse()