'''
demo
https://renderdoc.org/docs/python_api/examples/renderdoc/save_texture.html

'''
import re
import os
import qrenderdoc as qrd
import renderdoc as rd
import struct
import math
import random
from typing import Callable, Tuple, List
resources_map = {}
g_isFlipY = False	#如果不是DX，应该isFlipY=True
g_isLinear = False
g_uv = [0.74299, 0.45937]#DX原点在左上角

def get_texture_description_by_resource_id(controller, resource_id):
    # 获取所有纹理的资源ID
    texture_resources = controller.GetTextures()

    # 遍历所有纹理资源以找到匹配的资源ID
    for tex_resource in texture_resources:
        if tex_resource.resourceId == resource_id:
            # 找到匹配的资源，获取其TextureDescription并返回
            return tex_resource

    # 如果没有找到匹配的资源ID，则返回None
    return None

def display_texture(controller, resource_id):
    # 创建ReplayOutput对象，使用默认的输出设置
    output = controller.CreateOutput(rd.WindowingSystem.Unknown, rd.CreateOutputOptions())

    # 创建一个TextureDisplay配置
    tex_display = rd.TextureDisplay()
    tex_display.resourceId = resource_id

    # 配置ReplayOutput来展示指定的纹理
    output.SetTextureDisplay(tex_display)

    # 此处可以添加更多逻辑，比如读取输出的像素数据或将输出渲染到窗口
    
    # 清理资源
    output.Shutdown()


def CheckResources(controller:renderdoc.ReplayController):
	for res in pyrenderdoc.GetResources():
		resources_map[res.resourceId] = res
		#List[ResourceId]
		derivedResources = res.derivedResources
		for resId in derivedResources:
			resources_map[resId] = res
			# for eventUsage in controller.GetUsage(resId):
			# 		print(eventUsage.usage)

def get_res_name(resourceId):
	res = resources_map.get(resourceId)
	if not res:
		return f'res_{resourceId}'
	return res.name

def ReadPixel(controller:renderdoc.ReplayController,texture:renderdoc.TextureDescription):
	global g_isFlipY,g_isLinear,g_uv
	print(f'ReadPixel:{get_res_name(texture.resourceId)}')
	height= texture.height
	width= texture.width
	print(f"width={width}, height={height}")
	isFlipY = g_isFlipY	#如果不是DX，应该isFlipY=True
	isLinear = g_isLinear
	#DX原点在左上角
	uv = g_uv
	if isFlipY:
		uv[1] = 1 - uv[1]
	x = round(uv[0] * width)
	y = round(uv[1] * height)
	subRes = renderdoc.Subresource(0,0,0)#{mip=0 slice=0 sample=0 }
	format = renderdoc.CompType.Float if isLinear else renderdoc.CompType.UNormSRGB
	pixelValue = controller.PickPixel(texture.resourceId, x, y, subRes, format)
	print(f"uv=({uv[0]},{uv[1]}),x={x},y={y}")
	print(pixelValue.floatValue)
	# print(pixelValue.intValue)
	# print(pixelValue.uintValue)
	color32 = [0]*4
	for i in range(4):
		color32[i] = round(pixelValue.floatValue[i]*255)
	print(color32)
	# bytes = controller.GetTextureData(texture.resourceId,subRes)

	# replayOutput:renderdoc.ReplayOutput = None
	# replayOutput.SetPixelContextLocation(x,y)
	# controller.DebugPixel(x,y,0,0xFFFFFFFF)
	# controller.PixelHistory(texture.resourceId, x, y, subRes, format)
	textureViewer = pyrenderdoc.GetTextureViewer()
	textureViewer.GotoLocation(x,y)


def ReadPixelByResID(controller:renderdoc.ReplayController, resourceId):
	texture:renderdoc.TextureDescription = get_texture_description_by_resource_id(controller, resourceId)
	ReadPixel(controller, texture)
	# texsave.resourceId = resourceId
	# filename = str(int(texsave.resourceId))

	# print("Saving images of %s at %d: %s" % (filename, draw.eventId, draw.GetName(controller.GetStructuredFile())))

	# # Save different types of texture

	# # Blend alpha to a checkerboard pattern for formats without alpha support
	# texsave.alpha = rd.AlphaMapping.BlendToCheckerboard

	# # Most formats can only display a single image per file, so we select the
	# # first mip and first slice
	# texsave.mip = 0
	# texsave.slice.sliceIndex = 0

	# texsave.destType = rd.FileType.JPG
	# controller.SaveTexture(texsave, filename + ".jpg")

	# texsave.destType = rd.FileType.HDR
	# controller.SaveTexture(texsave, filename + ".hdr")

	# # For formats with an alpha channel, preserve it
	# texsave.alpha = rd.AlphaMapping.Preserve

	# texsave.destType = rd.FileType.PNG
	# controller.SaveTexture(texsave, filename + ".png")

	# # DDS textures can save multiple mips and array slices, so instead
	# # of the default behaviour of saving mip 0 and slice 0, we set -1
	# # which saves *all* mips and slices
	# texsave.mip = -1
	# texsave.slice.sliceIndex = -1

	# texsave.destType = rd.FileType.DDS
	# controller.SaveTexture(texsave, filename + ".dds")

def GetTextureColor(controller:renderdoc.ReplayController):
	print('[?]GetTextureColor')
	eventId = pyrenderdoc.CurEvent()
	#https://renderdoc.org/docs/python_api/renderdoc/analysis.html#renderdoc.ActionDescription
	#action:renderdoc.ActionDescription
	draw = pyrenderdoc.GetAction(eventId)
	#https://renderdoc.org/docs/python_api/renderdoc/resources.html#renderdoc.TextureDescription
	textures:renderdoc.TextureDescription = controller.GetTextures()
	# print(textures)
	texture = textures[0]
	ReadPixel(controller, texture)

#读取Outputs第一个纹理
def GetOutputTexture(controller:renderdoc.ReplayController):
	global g_isFlipY,g_isLinear,g_uv
	eventId = pyrenderdoc.CurEvent()
	#https://renderdoc.org/docs/python_api/renderdoc/analysis.html#renderdoc.ActionDescription
	#action:renderdoc.ActionDescription
	draw = pyrenderdoc.GetAction(eventId)
	texsave = rd.TextureSave()

	# Select the first color output
	resourceId = draw.outputs[0]

	# 获取管线状态
	pipeline_state = controller.GetPipelineState()
	# 获取输入纹理的信息（例如，顶点着色器的资源绑定）
    # 这里假设你要获取顶点着色器的第一个输入纹理位置
	shader_stage = rd.ShaderStage.Vertex
	shader_stage = rd.ShaderStage.Fragment
	
	boundResourceArrays = pipeline_state.GetReadOnlyResources(shader_stage)
	print(len(boundResourceArrays))
	for boundResourceArray in pipeline_state.GetReadOnlyResources(shader_stage):
		resources = boundResourceArray.resources
		# print("-", len(resources))
		if resources:  # 假设我们要查询的纹理绑定点是0
			for res in resources:
				if res.resourceId == rd.ResourceId.Null():
					break
				print("-",res.resourceId, boundResourceArray.bindPoint.bind)
				if boundResourceArray.bindPoint.bind == 0:
					resourceId = res.resourceId
	
	print("resourceId:", resourceId)

	g_isFlipY = False	#如果不是DX，应该isFlipY=True
	g_isLinear = False
	#DX原点在左上角
	g_uv = [0.33894, 0.27442]

	if resourceId == rd.ResourceId.Null():
		GetTextureColor(controller)
		return
	ReadPixelByResID(controller, resourceId)

# Replay时的回调函数：
#https://renderdoc.org/docs/python_api/renderdoc/replay.html#renderdoc.ReplayController
def callback(controller:renderdoc.ReplayController):
	CheckResources(controller)
	GetOutputTexture(controller)
pyrenderdoc.Replay().BlockInvoke(callback)