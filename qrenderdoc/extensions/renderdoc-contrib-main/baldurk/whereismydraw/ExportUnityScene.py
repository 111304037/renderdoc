
# https://zhuanlan.zhihu.com/p/602316635
#批量导出mesh
#https://zhuanlan.zhihu.com/p/643519201
#python api
#https://gist.github.com/BlurryLight/5718987e699515ba480ba823c113ca83

import re
import os
import qrenderdoc as qrd
import renderdoc as rd
import struct
import math
import random
from typing import Callable, Tuple, List
import json
import threading

ctx = pyrenderdoc
shader_res_ids = {}

class UnityObject(json.JSONEncoder):
	def default(self, obj):
		try:
			re = super(UnityObject,self).default(obj)
		except:
			if isinstance(obj, UnityObject):
				re = obj.to_dict()
			else:
				re = f'unknow:{obj}'
		return re

class Vector2(UnityObject):
	def __init__(self) -> None:
		self.x = 0
		self.y = 0

	def to_dict(self):
		return {'x':self.x,'y':self.y}

class Vector3(UnityObject):
	def __init__(self) -> None:
		self.x = 0
		self.y = 0
		self.z = 0
	def to_dict(self):
		return {'x':self.x,'y':self.y,'z':self.z}


class Vector4(UnityObject):
	def __init__(self) -> None:
		self.x = 0
		self.y = 0
		self.z = 0
		self.w = 0
	def to_dict(self):
		return {'x':self.x,'y':self.y,'z':self.z,'w':self.w}

class UnityMesh(UnityObject):
	def __init__(self) -> None:
		self.indicesList:List[List[int]] = []
		self.vertices:List[Vector3] = []
		self.colors:List[Vector4] = []
		self.normals:List[Vector3] = []
		self.tangents:List[Vector4] = []
		self.uv1:List[Vector2] = []
		self.uv2:List[Vector2] = []
		self.uv3:List[Vector2] = []
		self.uv4:List[Vector2] = []
		self.uv5:List[Vector2] = []
		self.uv6:List[Vector2] = []
		self.uv7:List[Vector2] = []
		self.uv8:List[Vector2] = []

	def to_dict(self):
		return {
            'indicesList': self.indicesList,
            'vertices': self.vertices,
            'colors': self.colors,
            'normals': self.normals,
            'tangents': self.tangents,
            'uv1': self.uv1,
            'uv2': self.uv2,
            'uv3': self.uv3,
            'uv4': self.uv4,
            'uv5': self.uv5,
            'uv6': self.uv6,
            'uv7': self.uv7,
            'uv8': self.uv8,
		}
	
	def GetSubMeshCount(self):
		return len(self.indices)
	
	def GetIndices(self, submesh):
		return self.indices[submesh]
	
	def SetVertexBuffers(self, controller, meshInputs, vbs, numIndices):
		vb_resourceID = vbs[0].resourceId
		buffDesc: rd.BufferDescription = pyrenderdoc.GetBuffer(vb_resourceID)
		length = (buffDesc.length - vbs[0].byteOffset) // vbs[0].byteStride
		if length > 65535:
			print("vertex length:",length ,"->",numIndices)
			length = numIndices
		meshRowDataList = []
		for idx in range(0, length):
			# print("Vertex %d is index %d:" % (i, idx))
			meshRowData = {}
			for attr in meshInputs:
				# This is the data we're reading from. This would be good to cache instead of
				# re-fetching for every attribute for every index
				offset = attr.vertexByteOffset + attr.vertexByteStride * idx
				data = controller.GetBufferData(attr.vertexResourceId, offset, 0)
				if data:
					compType: rd.CompType = attr.format.compType
					compCount:int = attr.format.compCount

					# Get the value from the data
					value = RDMeshData.unpackData(attr.format, data)
					meshRowData[attr.name] = value
			meshRowDataList.append(meshRowData)
				
		for idx in range(0, length):
			meshRowData = meshRowDataList[idx]
			for name, value in meshRowData.items():
				if name == 'POSITION':
					self.vertices.append(value)
				elif name == 'NORMAL':
					self.normals.append(value)
				elif name == 'TANGENT':
					self.tangents.append(value)
				elif name == 'COLOR':
					self.colors.append(value)
				elif name == 'TEXCOORD0':
					self.colors.append(value)
				elif name == 'TEXCOORD1':
					self.uv1.append(value)
				elif name == 'TEXCOORD2':
					self.uv2.append(value)
				elif name == 'TEXCOORD3':
					self.uv3.append(value)
				elif name == 'TEXCOORD4':
					self.uv4.append(value)
				elif name == 'TEXCOORD5':
					self.uv5.append(value)
				elif name == 'TEXCOORD6':
					self.uv6.append(value)
				elif name == 'TEXCOORD7':
					self.uv7.append(value)
				elif name == 'TEXCOORD8':
					self.uv8.append(value)
				else:
					print("\tunknown Attribute '%s': %s" % (attr.name, value))

	def SetSubMesh(self, inIndices):
		# maxIndex = max(indices)
		# minIndex = min(indices)
		for indices in self.indicesList:
			if indices == inIndices:
				return
		self.indicesList.append(inIndices)
				

class UnityGameObject(UnityObject):
	def __init__(self) -> None:
		self.mesh : str = ''
		self.cullMode = rd.CullMode.NoCull
		self.depthEnable = True
		self.depthWriteEnable = True
		self.depthFunction = rd.CompareFunction.AlwaysTrue
		self.blendFactor = [1,1,1,1]
		self.shader_vertex = ''
		self.shader_pixel = ''

	def to_dict(self):
		return {
			'cullMode': self.cullMode,
			'depthEnable': self.depthEnable,
			'depthWriteEnable': self.depthWriteEnable,
			'depthFunction': self.depthFunction,
			'blendFactor': self.blendFactor,
			'mesh:': self.mesh,
			'shader_vertex': self.shader_vertex,
			'shader_pixel': self.shader_pixel,
		}

class UnityScene(UnityObject):
	__instance = None
	NonSerialized = ['__instance']
    #排除不需要序列化的字段
	def __getstate__(self):
		state = self.__dict__.copy()
		for str in UnityScene.NonSerialized:
			if str in state:
				del state[str]
		return state
	def saveToFile(self):
		import json
		with open('D:/data.json', 'w', encoding="utf-8") as fw:
			jsonStr = json.dumps(self, indent=4,cls=UnityObject)
			# print(jsonStr)
			fw.write(jsonStr)

	@staticmethod
	def getInst():
		if not UnityScene.__instance:
			UnityScene.__instance = UnityScene()
		return UnityScene.__instance
	
	def __init__(self) -> None:
		self.gameObjects:List[UnityGameObject] = []
		self.resourcesMap:dict[int,int] = {}
		self.meshMap:dict[str, UnityMesh] = {}
		self.shaderMap:dict[str, str] = {}

	def to_dict(self):
		return {
            'gameObjects': self.gameObjects,
            'meshMap': self.meshMap,
            'shaderMap': self.shaderMap,
		}
	
	def addGameObject(self, go:UnityGameObject):
		self.gameObjects.append(go)

	def AddShaderRes(self, shader_res_id, shader_code):
		self.shaderMap[shader_res_id] = shader_code



#decode_mesh
#https://renderdoc.org/docs/python_api/examples/renderdoc/decode_mesh.html
class RDMeshData(rd.MeshFormat):
	indexOffset = 0
	name = ''

	# Get a list of MeshData objects describing the vertex inputs at this draw
	@staticmethod
	def getMeshInputs(controller, draw):
		state = controller.GetPipelineState()

		# Get the index & vertex buffers, and fixed vertex inputs
		ib = state.GetIBuffer()		#index buffer
		vbs = state.GetVBuffers()	#vertex buffers
		attrs = state.GetVertexInputs()

		#VS Input Columns
		meshInputs = []

		for attr in attrs:
			if not attr.used:
				continue

			# We don't handle instance attributes
			if attr.perInstance:
				raise RuntimeError("Instanced properties are not supported!")
			
			meshInput = RDMeshData()
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

	@staticmethod
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

	# Unpack a tuple of the given format, from the data
	@staticmethod
	def unpackData(fmt, data):
		# print("data:",data)
		# We don't handle 'special' formats - typically bit-packed such as 10:10:10:2
		if fmt.Special():
			raise RuntimeError("Packed formats are not supported!")

		formatChars = {}
		#                                 012345678
		formatChars[rd.CompType.UInt]  = "xBHxIxxxL"
		formatChars[rd.CompType.SInt]  = "xbhxixxxl"
		formatChars[rd.CompType.Float] = "xxexfxxxd" # only 2, 4 and 8 are valid

		# These types have identical decodes, but we might post-process them
		formatChars[rd.CompType.UNorm] = formatChars[rd.CompType.UInt]
		formatChars[rd.CompType.UScaled] = formatChars[rd.CompType.UInt]
		formatChars[rd.CompType.SNorm] = formatChars[rd.CompType.SInt]
		formatChars[rd.CompType.SScaled] = formatChars[rd.CompType.SInt]

		# We need to fetch compCount components
		vertexFormat = str(fmt.compCount) + formatChars[fmt.compType][fmt.compByteWidth]

		# Unpack the data
		value = struct.unpack_from(vertexFormat, data, 0)

		# If the format needs post-processing such as normalisation, do that now
		if fmt.compType == rd.CompType.UNorm:
			divisor = float((2 ** (fmt.compByteWidth * 8)) - 1)
			value = tuple(float(i) / divisor for i in value)
		elif fmt.compType == rd.CompType.SNorm:
			maxNeg = -float(2 ** (fmt.compByteWidth * 8)) / 2
			divisor = float(-(maxNeg-1))
			value = tuple((float(i) if (i == maxNeg) else (float(i) / divisor)) for i in value)

		# If the format is BGRA, swap the two components
		if fmt.BGRAOrder():
			value = tuple(value[i] for i in [2, 1, 0, 3])

		return value

# Replay时的回调函数：
def CheckResources(controller:renderdoc.ReplayController):
	pass
	# print("CheckResources")

	#pyrenderdoc: qrenderdoc.CaptureContext
	for res in pyrenderdoc.GetResources():
		# res:renderdoc.ResourceDescription
		#   print(res.name)
		if res.type == renderdoc.ResourceType.Shader or res.type == renderdoc.ResourceType.StateObject:
			# if 'Grass' in res.name:
			shader_res_ids[res.resourceId] = res
			#List[ResourceId]
			derivedResources = res.derivedResources
			for resId in derivedResources:
				shader_res_ids[resId] = res
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


def GetShaderCode(controller, pipe_state, shader_stage):
	shader_res_id:rd.ResourceId = str(pipe_state.GetShader(shader_stage))
	if shader_res_id in shader_res_ids:
		return shader_res_id
	#refer to docs/python_api/examples/renderdoc/fetch_shader.py
	# For some APIs, it might be relevant to set the PSO id or entry point name
	pipe: rd.ResourceId = pipe_state.GetGraphicsPipelineObject()
	entry: str = pipe_state.GetShaderEntryPoint(shader_stage)
	# Get the pixel shader's reflection object
	ps: rd.ShaderReflection = pipe_state.GetShaderReflection(shader_stage)
	# print("Available disassembly formats:",entry, ps)
	
	if pipe_state.IsCaptureGL() or pipe_state.IsCaptureVK():
		targets:List[str] = controller.GetDisassemblyTargets(True)	#这个只能获取内置的
		# for disasm in targets:
		# 	print("  - " + disasm)
		target = targets[0]
		# print(controller.DisassembleShader(pipe, ps, target))
		# raise Exception("not found encoding:")
	else:
		targetShaderTool = qrd.ShaderProcessingTool = None
		targetShaderEncoding = rd.ShaderEncoding.DXBC
		targetShaderToolName = 'HLSLDecompiler'
		config: qrd.PersistantConfig = ctx.Config()
		shaderProcessors:List[qrd.ShaderProcessingTool] = config.ShaderProcessors
		for sp in shaderProcessors:
			# if sp.output not in [
			# 	rd.ShaderEncoding.HLSL,
			# 	rd.ShaderEncoding.GLSL,
			# 	rd.ShaderEncoding.SPIRVAsm,
			# 	rd.ShaderEncoding.OpenGLSPIRVAsm
			# ]:
			# 	continue
			# print(sp.name," ", sp.input ," ", targetShaderEncoding)
			if sp.input != targetShaderEncoding:
				continue
			if sp.name != targetShaderToolName:
				continue
			# print(">>>>",sp.name," ", sp.input)
			targetShaderTool = sp
			break
		else:
			raise Exception("not found encoding:",targetShaderEncoding)
		# print(controller.DisassembleShader(pipe, ps, target))
		results = {}
		event = threading.Event()
		def call_on_ui(resultsMap):
			shaderViewer:rd.ShaderViewer = ctx.ViewShader(ps, pipe)
			# print("shaderViewer:",shaderViewer, ",Widget", shaderViewer.Widget())
			# ctx.AddDockWindow(shaderViewer.Widget(), qrd.DockReference.AddTo, ctx.GetPipelineViewer().Widget())
			ret:rd.ShaderToolOutput = targetShaderTool.DisassembleShader(shaderViewer.Widget(), ps, '')
			# print(ret.log)
			resultsMap['shader_code'] = ret.result
			# pyrenderdoc.RaiseDockWindow(shaderViewer.Widget())
			shaderViewer.Widget().close()
			# print("resultsMap:", 'shader_code' in resultsMap)
			event.set()
		ctx.Extensions().GetMiniQtHelper().InvokeOntoUIThread(lambda: call_on_ui(results))
		event.wait(10)
		shader_code = results.get('shader_code','')
		UnityScene.getInst().AddShaderRes(shader_res_id, shader_code)
		return shader_res_id

def Analyse_Drawcall(controller:renderdoc.ReplayController, action:renderdoc.ActionDescription):
	gameObject = UnityGameObject()
	UnityScene.getInst().addGameObject(gameObject)
	controller.SetFrameEvent(action.eventId, False)
	print("play:", action.eventId)
	
	#https://renderdoc.org/docs/python_api/renderdoc/replay.html#renderdoc.ReplayController
	pipe_state:rd.PipeState = controller.GetPipelineState()
	if pipe_state.IsCaptureGL():
		state = ctx.CurGLPipelineState()
		cullMode:rd.CullMode = state.rasterizer.state.cullMode
		depthEnable = state.depthState.depthEnable
		depthWriteEnable = state.depthState.depthWrites
		depthFunction = state.depthState.depthFunction
		blendFactor = state.blendState.blendFactor
	elif pipe_state.IsCaptureVK():
		state = ctx.CurVulkanPipelineState()
		cullMode:rd.CullMode = state.rasterizer.cullMode
		depthEnable = state.depthStencil.depthTestEnable
		depthWriteEnable = state.depthStencil.depthWriteEnable
		depthFunction = state.depthStencil.depthFunction
		blendFactor = state.colorBlend.blendFactor
	elif pipe_state.IsCaptureD3D11():
		state = ctx.CurD3D11PipelineState()
		cullMode:rd.CullMode = state.rasterizer.state.cullMode
		depthEnable = state.outputMerger.depthStencilState.depthEnable
		depthWriteEnable = state.outputMerger.depthStencilState.depthWrites
		depthFunction = state.outputMerger.depthStencilState.depthFunction
		blendFactor = state.outputMerger.blendState.blendFactor
	elif pipe_state.IsCaptureD3D12():
		state = ctx.CurD3D12PipelineState()
		cullMode:rd.CullMode = state.rasterizer.state.cullMode
		depthEnable = state.outputMerger.depthStencilState.depthEnable
		depthWriteEnable = state.outputMerger.depthStencilState.depthWrites
		depthFunction = state.outputMerger.depthStencilState.depthFunction
		blendFactor = state.outputMerger.blendState.blendFactor
	else:
		raise Exception("unknown Capture:",ctx.CurPipelineState())
	# print("cullMode:", cullMode)
	# print("depthEnable:", depthEnable)
	# print("depthWriteEnable:", depthWriteEnable)
	# print("depthFunction:", depthFunction)
	# print("blendFactor:", blendFactor)
	# raise Exception("not found encoding:")
	# vs:renderdoc.ShaderReflection = pipe.GetShaderReflection(renderdoc.ShaderStage.Vertex)
	gameObject.cullMode = cullMode
	gameObject.depthEnable = depthEnable
	gameObject.depthWriteEnable = depthWriteEnable
	gameObject.depthFunction = depthFunction
	gameObject.blendFactor = blendFactor
	# if vs:
	#	 print(vs)
	#	 print(f"VS: {vs.entryPoint} in {vs.debugInfo.files[0].filename if vs.debugInfo.files else 'N/A'}")

	#mesh
	numIndices = action.numIndices
	numInstances = action.numInstances
	if numInstances > 1:# GpuInstancing
		pass
	else:
		# Calculate the mesh input configuration
		meshInputs = RDMeshData.getMeshInputs(controller, action)
		# print("Mesh attribute inputs:",len(meshInputs))
		# for attr in meshInputs:
		# 	print("\t%s:" % attr.name)
		# 	print("\t\t- vertex: %s / %d stride" % (attr.vertexResourceId,  attr.vertexByteStride))
		# 	print("\t\t- format: %s x %s @ %d" % (attr.format.compType, attr.format.compCount, attr.vertexByteOffset))
		if meshInputs:
			vbs = pipe_state.GetVBuffers()	#vertex buffers
			vb_resourceID = str(vbs[0].resourceId)
			mesh: UnityMesh = UnityScene.getInst().meshMap.get(vb_resourceID)
			if not mesh:
				print("play:", action.eventId)
				mesh = UnityMesh()
				UnityScene.getInst().meshMap[vb_resourceID] = mesh
				mesh.SetVertexBuffers(controller, meshInputs, vbs, numIndices)

			gameObject.mesh = vb_resourceID
			# print("meshInputs:", action.eventId," - ", len(meshInputs))
			# for i,input in enumerate(meshInputs):
			# 	print(i,".", input.name)
			indices = RDMeshData.getIndices(controller, meshInputs[0])
			mesh.SetSubMesh(indices)
		else:
			pass
			# print("meshInputs:", action.eventId," - ", len(meshInputs))
	
	# #shader
	# vertShader:renderdoc.ResourceId = pipe_state.GetShader(rd.ShaderStage.Vertex)
	# if vertShader in grass_res_ids:
	# 	grass_event_ids[action.eventId] = action
	# 	Stats.AddAction(controller, action)

	gameObject.shader_vertex = GetShaderCode(controller, pipe_state, rd.ShaderStage.Vertex)
	gameObject.shader_pixel = GetShaderCode(controller, pipe_state, rd.ShaderStage.Pixel)
	# gameObject.shader_compute = GetShaderCode(controller, pipe_state, rd.ShaderStage.Compute)
	# print(gameObject.shader_compute)
	# raise Exception("not found encoding:")

	# cb = pipe_state.GetConstantBuffer(rd.ShaderStage.Pixel, 0, 0)
	# cbufferVars = controller.GetCBufferVariableContents(pipe, ps.resourceId, rd.ShaderStage.Pixel, entry, 0, cb.resourceId, 0, 0)
	# print("Pixel vars:")
	# def printVar(v, indent = ''):
	# 	print(indent + v.name + ":")

	# 	if len(v.members) == 0:
	# 		valstr = ""
	# 		for r in range(0, v.rows):
	# 			valstr += indent + '  '

	# 			for c in range(0, v.columns):
	# 				valstr += '%.3f ' % v.value.f32v[r*v.columns + c]

	# 			if r < v.rows-1:
	# 				valstr += "\n"

	# 		print(valstr)

	# 	for v in v.members:
	# 		printVar(v, indent + '    ')

	# for v in cbufferVars:
	# 	printVar(v)

def Analyse_Action(controller:renderdoc.ReplayController, action:renderdoc.ActionDescription):
	if action.flags & renderdoc.ActionFlags.Drawcall > 0:
		Analyse_Drawcall(controller, action)

def Analyse_Action_Recursion(controller:renderdoc.ReplayController, action:renderdoc.ActionDescription):
	Analyse_Action(controller, action)
	for child in action.children:
		Analyse_Action_Recursion(controller, child)

def ExportScene():
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
		UnityScene.getInst().saveToFile()
		print("-------------done-------------")
	pyrenderdoc.Replay().BlockInvoke(callback)


ExportScene()