//
//  MetalShaderTypes.h
//  MetalBasicBuffers
//
//  Created by TL on 2020/8/26.
//  Copyright © 2020 tl. All rights reserved.
//

#ifndef MetalShaderTypes_h
#define MetalShaderTypes_h
#include <simd/simd.h>

typedef enum VertexInputIndex{
    // 顶点
    VertexInputIndexVertices = 0,
    // 视图大小
    VertexInputIndexViewportSize = 1,
    
} VertexInputIndex;

// 顶点&颜色值 结构体
typedef struct {
    
    /**
     像素空间位置
     像素中心点（100，100）
     （float，float）
     */
    vector_float2 position;
    // RGB颜色
    vector_float4 color;
    
} MetalVertex;


#endif /* MetalShaderTypes_h */
