//
//  V_FShaders.metal
//  MetalBasicBuffers
//
//  Created by TL on 2020/8/26.
//  Copyright © 2020 tl. All rights reserved.
//

#include <metal_stdlib>
#import "MetalShaderTypes.h"
// 使用metal的命名空间
using namespace metal;

// 顶点着色器输出和片元着色器输入 结构体
typedef struct {
    // 处理空间的顶点信息
    float4 clipSpacePosition [[position]];
    // 颜色
    float4 color;
} Vertex_FragmentData;
/**
 *顶点函数
 */
vertex Vertex_FragmentData vertexShader(uint vertexID [[vertex_id]],
                                        constant MetalVertex * vertices [[buffer(VertexInputIndexVertices)]],
                                        constant vector_uint2 * viewportSizePointer [[buffer(VertexInputIndexViewportSize)]]
                                        )
{
    /**
     * 处理顶点数据
     * 1.执行坐标系转换，将生成的顶点剪辑空间写入返回值
     * 2.将顶点颜色值作为返回值传递出去
     */
    Vertex_FragmentData outVertex;
    
    // 初始化输出的剪辑空间位置
    outVertex.clipSpacePosition = vector_float4(0, 0, 0, 1.0);
    
    // 索引到数组位置获取当前顶点；位置是在像素纬度中指定的
    float2 pixpelSpacePosition = vertices[vertexID].position.xy;
    
    // 转换 viewportSizePointer: vector_uint2 -> vector_float2
    vector_float2 viewportSize = vector_float2(* viewportSizePointer);
    
    /**
     * 每个顶点着色器的输出位置在剪辑空间中（即归一化的设备坐标空间 - NDC），剪辑空间中（-1，1）代表视口的左下角，（1，1）则表示视口的右上角
     *  计算和写入XY值到剪辑空间的位置，为了把像素空间的位置转换到剪辑空间的位置，可以将像素坐标除以视口大小的一半
     */
    outVertex.clipSpacePosition.xy = pixpelSpacePosition / (viewportSize / 2.0);
    
    // 把输入颜色直接赋值给输出颜色，为每个片元生成对应的颜色值
    outVertex.color = vertices[vertexID].color;
    // 将结构体的顶点数据传递至管道下阶段
    return outVertex;
    
}

/** 片元函数
 * [[stage_in]],片元着色函数使用的单个片元输入数据是由顶点着色函数输出.然后经过光栅化生成的.单个片元输入函数数据可以使用"[[stage_in]]"属性修饰符.
 *  一个顶点着色函数可以读取单个顶点的输入数据,这些输入数据存储于参数传递的缓存中,使用顶点和实例ID在这些缓存中寻址.读取到单个顶点的数据.
 *  另外,单个顶点输入数据也可以通过使用"[[stage_in]]"属性修饰符的产生传递给顶点着色函数.
 *  被stage_in 修饰的结构体的成员不能是如下这些.Packed vectors 紧密填充类型向量,matrices 矩阵,structs 结构体,references or pointers to type 某类型的引用或指针. arrays,vectors,matrices 标量,向量,矩阵数组.
 */
fragment float4 fragmentShader(Vertex_FragmentData inFrag [[stage_in]])
{
    // 返回输入颜色
    return inFrag.color;
}








