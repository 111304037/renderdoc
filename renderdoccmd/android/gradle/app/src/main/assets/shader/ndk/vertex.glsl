#version 300 es
layout (location = 0) in vec4 aPosition;  //顶点位置,layout限定布局位置为0
uniform mat4 uMVPMatrix; //总变换矩阵

void main()
{
#if 1
   gl_Position = aPosition;
#else
   gl_Position = uMVPMatrix * vec4(aPosition,1); //根据总变换矩阵计算此次绘制此顶点位置
   gl_Position /= gl_Position.w;
#endif
}