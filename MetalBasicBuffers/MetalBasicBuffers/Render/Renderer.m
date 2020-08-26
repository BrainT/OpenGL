//
//  Renderer.m
//  MetalBasicBuffers
//
//  Created by TL on 2020/8/26.
//  Copyright © 2020 tl. All rights reserved.
//

#import "Renderer.h"
#import "MetalShaderTypes.h"

@implementation Renderer
{
    // 渲染的设备 GPU
    id<MTLDevice> _device;
    
    // 渲染管道：顶点着色器/片元着色器 存储在shader.metal文件中
    id<MTLRenderPipelineState> _pipelineState;
    
    // 从命令缓存区获取 命令队列
    id<MTLCommandQueue> _commandQueue;
    
    // 顶点缓存区
    id<MTLBuffer> _vertexBuffer;
    
    // 当前视图大小，以便在渲染通道中使用此视图
    vector_uint2 _viewportSize;
    
    // 顶点个数
    NSInteger _numVertices;
    
}


- (instancetype)initWithMetalKitView:(nonnull MTKView *)mtkView
{
    self = [super init];
    if (self) {
        _device = mtkView.device;
        
        [self loadMetalShaderWith:mtkView];
    }
    return self;
}

- (void)loadMetalShaderWith:(MTKView *)mtkView
{
    // 1.设置绘制纹理的像素格式
    mtkView.colorPixelFormat = MTLPixelFormatBGRA8Unorm_sRGB;
    // 2.从项目中加载着色器文件
    id<MTLLibrary> defLibary = [_device newDefaultLibrary];
    
    // 从库中加载顶点函数
    id<MTLFunction> vertexFunction = [defLibary newFunctionWithName:@"vertexShader"];
    
    id<MTLFunction> fragmentFunction = [defLibary newFunctionWithName:@"fragmentShader"];
    
    // 3.配置管道
    MTLRenderPipelineDescriptor * pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    //
    pipelineStateDescriptor.label = @"This is pipeline";
    // 可编程函数-处理渲染过程的顶点
    pipelineStateDescriptor.vertexFunction = vertexFunction;
    // 处理渲染过程的片元
    pipelineStateDescriptor.fragmentFunction = fragmentFunction;
    // 设置管道中存储颜色数据的格式
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat;
    
    // 4.同步创建并返回渲染管道对象
    NSError * err = nil;
    _pipelineState = [_device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error:&err];
    // 判断是否创建成功
    if (_pipelineState == nil) {
        NSLog(@"创建渲染管道失败：%@",err);
    }
    
    // 获取顶点数据
    NSData * vertexData = [self createVertexData];
    
    // 创建vertex buffer 交由GPU读取
    _vertexBuffer = [_device newBufferWithLength:vertexData.length options:MTLResourceStorageModeShared];
    /*
        memcpy(void *dst, const void *src, size_t n);
        dst:目的地
        src:源内容
        n: 长度
        */
    memcpy(_vertexBuffer.contents, vertexData.bytes, vertexData.length);
    //计算顶点个数 = 顶点数据长度 / 单个顶点大小
    _numVertices = vertexData.length / sizeof(MetalVertex);
    // 6.创建命令队列
    _commandQueue = [_device newCommandQueue];
    
}


///创建顶点数据
- (nonnull NSData *)createVertexData
{
   //1.正方形 = 三角形+三角形
   const MetalVertex quadVertices[] =
   {
       // Pixel 位置, RGBA 颜色
       { { -20,   20 },    { 1, 0, 0, 1 } },
       { {  20,   20 },    { 1, 0, 0, 1 } },
       { { -20,  -20 },    { 1, 0, 0, 1 } },
       
       { {  20,  -20 },    { 0, 0, 1, 1 } },
       { { -20,  -20 },    { 0, 0, 1, 1 } },
       { {  20,   20 },    { 0, 0, 1, 1 } },
   };
   //行/列 数量
   const NSUInteger NUM_COLUMNS = 25;
   const NSUInteger NUM_ROWS = 15;
   //顶点个数
   const NSUInteger NUM_VERTICES_PER_QUAD = sizeof(quadVertices) / sizeof(MetalVertex);
   //四边形间距
   const float QUAD_SPACING = 50.0;
   //数据大小 = 单个四边形大小 * 行 * 列
   NSUInteger dataSize = sizeof(quadVertices) * NUM_COLUMNS * NUM_ROWS;
   
   //2. 开辟空间
   NSMutableData *vertexData = [[NSMutableData alloc] initWithLength:dataSize];
   //当前四边形
   MetalVertex * currentQuad = vertexData.mutableBytes;
   
   
   //3.获取顶点坐标(循环计算)
   //行
   for(NSUInteger row = 0; row < NUM_ROWS; row++)
   {
       //列
       for(NSUInteger column = 0; column < NUM_COLUMNS; column++)
       {
           //A.左上角的位置
           vector_float2 upperLeftPosition;
           
           //B.计算X,Y 位置.注意坐标系基于2D笛卡尔坐标系,中心点(0,0),所以会出现负数位置
           upperLeftPosition.x = ((-((float)NUM_COLUMNS) / 2.0) + column) * QUAD_SPACING + QUAD_SPACING/2.0;
           
           upperLeftPosition.y = ((-((float)NUM_ROWS) / 2.0) + row) * QUAD_SPACING + QUAD_SPACING/2.0;
           
           //C.将quadVertices数据复制到currentQuad
           memcpy(currentQuad, &quadVertices, sizeof(quadVertices));
           
           //D.遍历currentQuad中的数据
           for (NSUInteger vertexInQuad = 0; vertexInQuad < NUM_VERTICES_PER_QUAD; vertexInQuad++)
           {
               //修改vertexInQuad中的position
               currentQuad[vertexInQuad].position += upperLeftPosition;
           }
           
           //E.更新索引
           currentQuad += 6;
       }
   }
   
   return vertexData;
   
}

#pragma mark - MTKViewDelegate
- (void)drawInMTKView:(nonnull MTKView *)view {

    // 1,为当前渲染的每个渲染传递创建一个新的命令缓存区
    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    commandBuffer.label = @"My Command";
    // 2.MTLRenderPassDescriptor:一组渲染目标，用作渲染通道生成的像素的输出目标。
    MTLRenderPassDescriptor * renderPassDescriptor = view.currentRenderPassDescriptor;
    // 判断渲染目标是否为空
    if (renderPassDescriptor != nil) {

        // 3.创建渲染命令编码器，这样我们就可以渲染
        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        renderEncoder.label = @"My Render Encoder";
        /**
         * 4.设置绘制区域
         * typedef struct {
         *  double originX, originY, width, height, znear, zfar;
         * } MTLViewport;
         */
        [renderEncoder setViewport:(MTLViewport){0.0, 0.0, _viewportSize.x, _viewportSize.y, -1.0, 1.0}];

        // 5.设置渲染管道
        [renderEncoder setRenderPipelineState:_pipelineState];

        /**
         * 6.发送数据到顶点着色器函数
         * buffer：包含需要传递的缓冲对象
         * offset：从缓冲器的开头字节偏移，指示“顶点指针”指向什么。在这种情况下，我们通过0，所以数据一开始就被传递下来.偏移量
         * index：一个整数索引，对应于我们的“vertexShader”函数中的缓冲区属性限定符的索引。注意，此参数与 -[MTLRenderCommandEncoder setVertexBytes:length:atIndex:] “索引”参数相同。
         */
        [renderEncoder setVertexBuffer:_vertexBuffer offset:0 atIndex:VertexInputIndexVertices];
        
        // 将 viewportSize 设置到顶点缓存区绑定点设置数据
        [renderEncoder setVertexBytes:&_viewportSize length:sizeof(_viewportSize) atIndex:VertexInputIndexViewportSize];

        /**
         * 7.开始绘图
         * @brief 在不使用索引列表的情况下,绘制图元
         * @param 绘制图形组装的基元类型
         * @param 从哪个位置数据开始绘制,一般为0
         * @param 每个图元的顶点个数,绘制的图型顶点数量
         */
        /* (MTLPrimitiveType)
            MTLPrimitiveTypePoint = 0, 点
            MTLPrimitiveTypeLine = 1, 线段
            MTLPrimitiveTypeLineStrip = 2, 线环
            MTLPrimitiveTypeTriangle = 3,  三角形
            MTLPrimitiveTypeTriangleStrip = 4, 三角型扇
            */

        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:_numVertices];

        //8.完成编码器命令的生成，结束编码；并从MTLCommandBuffer中分离
        [renderEncoder endEncoding];

        // 9.推出绘制
        [commandBuffer presentDrawable:view.currentDrawable];

    }
    // 10.完成渲染并将命令推送到GPU
    [commandBuffer commit];

}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
    
    // 保存可绘制的大小
    _viewportSize.x = size.width;
    
    _viewportSize.y = size.height;
}

@end
