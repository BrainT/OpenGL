//
//  main.cpp
//  OpenGL
//
//  Created by TL on 2020/7/10.
//  Copyright © 2020 tl. All rights reserved.
//

#include "GLTools.h"
#include "StopWatch.h"
#include "GLShaderManager.h"
#include "GLMatrixStack.h" // 矩阵堆栈
#include "GLFrame.h" // 矩阵变换
#include "GLFrustum.h" // 投影矩阵
#include "GLBatch.h" // 7中不同的图元容器对象
#include "GLGeometryTransform.h" // 几何变换的管道

#include <math.h>
#include <stdio.h>

#ifdef __APPLE__
#include <glut/glut.h>
#else
#define FREEGLUT_STATIC
#include <GL/glut.h>
#endif

//设置角色帧，作为相机
GLFrame             cameraFrame;
//使用GLFrustum类来设置透视投影
GLFrustum           viewFrustum;
// 三角形容器类
GLBatch             floorBatch; // 地板
GLTriangleBatch     bigSphereBatch; // 大球
GLTriangleBatch     globlueBatch; // 小球
// 模型矩阵堆栈
GLMatrixStack       modelViewMatix;
// 投影变换矩阵
GLMatrixStack       projectionMatrix;

// 几何变换的管道
GLGeometryTransform transformPipeline;
// 着色器管理器
GLShaderManager     shaderManager;

// 定义60个随机小球
#define Spheres_Num 60
GLFrame spheres[Spheres_Num];

// 定义纹理数组
GLuint uiTextures[3];

///加载纹理数据
bool loadTGATexture(const char *tgafileName,GLenum minFilter, GLenum magFilter, GLenum wrapMode)
{
    GLbyte *pBits;
    int mWidth, mHeight, mComponents;
    GLenum eFormat;
    
    // 1.加载纹理数据
    pBits = gltReadTGABits(tgafileName, &mWidth, &mHeight, &mComponents, &eFormat);
    if (!pBits) {
        return false;
    }
    
    // 2.设置纹理参数
    /**
     * 参数1：纹理维度
     * 2: 为S/T坐标设置模式
     * 3: wrapMode,环绕模式
     */
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, wrapMode);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, wrapMode);
    
    /**
     * 1：纹理维度
     * 2: 线性过滤
     * 3: wrapMode,环绕模式
     */
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, minFilter);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, magFilter);
    
    /**
     * 1：纹理维度
     * 2:  mip贴图层次
     * 3:  纹理单元存储的颜色成分（从读取像素图是获得）- 将内部参数comments改为通用压缩纹理格式GL_COMPRESSED_RGB
     * 4. 加载纹理宽
     * 5：加载纹理高
     * 6: 加载纹理的深度
     * 7：像素数据的类型     （GL_UNSIGNED_BYTE，每个颜色分量都是一个8位无符号整数）
     * 8：指向纹理图像数据的指针
            
    */

    glTexImage2D(GL_TEXTURE_2D, 0, GL_COMPRESSED_RGB, mWidth, mHeight, 0,
                 eFormat, GL_UNSIGNED_BYTE, pBits);
    // 3.使用完释放pBits
    free(pBits);
    
    //只有minFilter 等于以下四种模式，才可以生成Mip贴图
    //GL_NEAREST_MIPMAP_NEAREST具有非常好的性能，并且闪烁现象非常弱
    //GL_LINEAR_MIPMAP_NEAREST常常用于对游戏进行加速，它使用了高质量的线性过滤器
    //GL_LINEAR_MIPMAP_LINEAR 和GL_NEAREST_MIPMAP_LINEAR 过滤器在Mip层之间执行了一些额外的插值，以消除他们之间的过滤痕迹。
    //GL_LINEAR_MIPMAP_LINEAR 三线性Mip贴图。纹理过滤的黄金准则，具有最高的精度。
    if(minFilter == GL_LINEAR_MIPMAP_LINEAR ||
       minFilter == GL_LINEAR_MIPMAP_NEAREST ||
       minFilter == GL_NEAREST_MIPMAP_LINEAR ||
       minFilter == GL_NEAREST_MIPMAP_NEAREST)
    {
           //4.加载Mip,纹理生成所有的Mip层
           //参数：GL_TEXTURE_1D、GL_TEXTURE_2D、GL_TEXTURE_3D
           glGenerateMipmap(GL_TEXTURE_2D);
    }
        
    return true;
    
}

/// 初始化场景
void SetupRC()
{
    // 1.设置背景色
    glClearColor(0.1, 0.1, 0.1f, 1.0f);
   
    // 2.初始化着色器管理器
    shaderManager.InitializeStockShaders();
    // 开启深度测试
    glEnable(GL_DEPTH_TEST);
    // 开启背面剔除
    glEnable(GL_CULL_FACE);
    
     // 初始化一个球体 球体批次类，半径，片段数，堆积数量
     gltMakeSphere(bigSphereBatch, 0.5f, 40, 80);
     
     // 初始化小球
     gltMakeSphere(globlueBatch, 0.11f, 15, 30);
    
 
    //6.设置地板顶点数据&地板纹理
    GLfloat texSize = 10.0f;
    floorBatch.Begin(GL_TRIANGLE_FAN, 4,1);
    floorBatch.MultiTexCoord2f(0, 0.0f, 0.0f);
    floorBatch.Vertex3f(-20.f, -0.41f, 20.0f);
    
    floorBatch.MultiTexCoord2f(0, texSize, 0.0f);
    floorBatch.Vertex3f(20.0f, -0.41f, 20.f);
    
    floorBatch.MultiTexCoord2f(0, texSize, texSize);
    floorBatch.Vertex3f(20.0f, -0.41f, -20.0f);
    
    floorBatch.MultiTexCoord2f(0, 0.0f, texSize);
    floorBatch.Vertex3f(-20.0f, -0.41f, -20.0f);
    floorBatch.End();
    
    for (int i = 0; i < Spheres_Num; i++) {
        
        //y轴不变，X,Z产生随机值
        GLfloat x = ((GLfloat)((rand() % 400) - 200 ) * 0.1f);
        GLfloat z = ((GLfloat)((rand() % 400) - 200 ) * 0.1f);
        
        //在y方向，将球体设置为0.0的位置，这使得它们看起来是飘浮在眼睛的高度
        //对spheres数组中的每一个顶点，设置顶点数据
        spheres[i].SetOrigin(x, 0.0f, z);
    }
 
    //8.命名纹理对象
    glGenTextures(3, uiTextures);
    
    //9.将TGA文件加载为2D纹理。
    //参数1：纹理文件名称
    //参数2&参数3：需要缩小&放大的过滤器
    //参数4：纹理坐标环绕模式
    glBindTexture(GL_TEXTURE_2D, uiTextures[0]);
    loadTGATexture("marble.tga", GL_LINEAR_MIPMAP_LINEAR, GL_LINEAR, GL_REPEAT);
    
    
    glBindTexture(GL_TEXTURE_2D, uiTextures[1]);
    loadTGATexture("marslike.tga", GL_LINEAR_MIPMAP_LINEAR,
                   GL_LINEAR, GL_CLAMP_TO_EDGE);
    
    
    glBindTexture(GL_TEXTURE_2D, uiTextures[2]);
    loadTGATexture("moonlike.tga", GL_LINEAR_MIPMAP_LINEAR,
                   GL_LINEAR, GL_CLAMP_TO_EDGE);
    
}

/// 绘制j球体
/// @param yRot <#yRot description#>
void drawSphere(GLfloat yRot)
{
    // 1.定义光源位置和漫反射颜色
    static GLfloat vWhite[] = {1.0f,1.0f,1.0f,1.0f};
    static GLfloat vLightPosition[] = { 0.0f, 3.0f,0.0, 1.0f };
    
    // 2.绘制小球   绑定纹理
    glBindTexture(GL_TEXTURE_2D, uiTextures[2]);
   // 3.随机小球
   for (int i = 0; i<Spheres_Num; i ++) {
       modelViewMatix.PushMatrix();
       modelViewMatix.MultMatrix(spheres[i]);
       shaderManager.UseStockShader(GLT_SHADER_TEXTURE_POINT_LIGHT_DIFF,
                                    modelViewMatix.GetMatrix(),
                                    transformPipeline.GetProjectionMatrix(),
                                    vLightPosition,
                                    vWhite,
                                    0);
       globlueBatch.Draw();
       modelViewMatix.PopMatrix(); // 小球绘制完成，再出栈
   }
    
    // 4.绘制大球
    modelViewMatix.Translate(0.0f, 0.2f, -2.5f);
    modelViewMatix.PushMatrix();
    modelViewMatix.Rotate(yRot, 0.0f, 1.0f, 0.0f);
    glBindTexture(GL_TEXTURE_2D, uiTextures[1]);
    shaderManager.UseStockShader(GLT_SHADER_TEXTURE_POINT_LIGHT_DIFF,
                                 modelViewMatix.GetMatrix(),
                                 transformPipeline.GetProjectionMatrix(),
                                 vLightPosition,
                                 vWhite,
                                 0);
    bigSphereBatch.Draw();
    modelViewMatix.PopMatrix();
    
    // 5.绘制公转的小球
    modelViewMatix.PushMatrix();
    modelViewMatix.Rotate(yRot * -2.0f, 0.0f, 1.0f, 0.0f);
    modelViewMatix.Translate(0.8f, 0.0f, 0.0f);
    glBindTexture(GL_TEXTURE_2D, uiTextures[2]);
    shaderManager.UseStockShader(GLT_SHADER_TEXTURE_POINT_LIGHT_DIFF,
                                 modelViewMatix.GetMatrix(),
                                 transformPipeline.GetProjectionMatrix(),
                                 vLightPosition,
                                 vWhite,
                                 0);
    globlueBatch.Draw();
    modelViewMatix.PopMatrix();
    
}


/// 改变窗口大小
/// @param w 宽带
/// @param h 高度
void ChangeSize(int w,int h)
{
   
    // .设置窗口尺寸
    glViewport(0, 0, w, h);
    
    /* 3.设置透视模式，初始化透视矩阵
     * SetPerspective 的参数是y
     * 参数1：垂直方向上的观察者视角度数
     * 参数2：纵横比 w/h
     * 参数3：近裁剪⾯距离 （视角到近裁剪面距离为fNear）
     * 参数4：远裁剪面距离（视角到远裁剪面距离为fFar）
     */
    viewFrustum.SetPerspective(35.0f, float(w)/float(h), 1.0f, 100.0f);
    
    // 4.把透视矩阵加载到透视矩阵对阵中
    projectionMatrix.LoadMatrix(viewFrustum.GetProjectionMatrix());
    modelViewMatix.LoadIdentity();
    
    //设置变换管道以使用两个矩阵堆栈（变换矩阵modelViewMatrix ，投影矩阵projectionMatrix）
    //初始化GLGeometryTransform 的实例transformPipeline.通过将它的内部指针设置为模型视图矩阵堆栈 和 投影矩阵堆栈实例，来完成初始化
    //当然这个操作也可以在SetupRC 函数中完成，但是在窗口大小改变时或者窗口创建时设置它们并没有坏处。而且这样可以一次性完成矩阵和管线的设置。
    // 5.初始化渲染管线
    transformPipeline.SetMatrixStacks(modelViewMatix, projectionMatrix);
    
    
}


/// 方向控制 通过改变Camera 移动，改变视口
/// @param key key description
/// @param x x description
/// @param y y description

void directionKeyOnclick(int key,int x,int y)
{
    
    float linear = 0.1f;
    float angular = float(m3dDegToRad(5.0f));
    
    if (key == GLUT_KEY_UP) {
        
        //MoveForward 平移
        cameraFrame.MoveForward(linear);
    }
    
    if (key == GLUT_KEY_DOWN) {
        cameraFrame.MoveForward(-linear);
    }
    
    if (key == GLUT_KEY_LEFT) {
        //RotateWorld 旋转
        cameraFrame.RotateWorld(angular, 0.0f, 1.0f, 0.0f);
    }
    
    if (key == GLUT_KEY_RIGHT) {
        cameraFrame.RotateWorld(-angular, 0.0f, 1.0f, 0.0f);
    }
    
   
    
}
/// 渲染场景
void RenderScene()
{
    // 0.设置颜色值-地板 球体
    static GLfloat mFloorColor[] = {0.8f,0.8f,0.1f,0.75f};
    
    // 1.清除窗口、深度缓冲区
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // 设置定时器动画
    static CStopWatch rotTimer;
    
    float rot = rotTimer.GetElapsedSeconds() * 60.0f;
    
    // 压栈，将单元矩阵压入
    modelViewMatix.PushMatrix();

    // 3.将观察者提前一轮绘制，不影响下一层的布局
    M3DMatrix44f myCamera;
    cameraFrame.GetCameraMatrix(myCamera);
    modelViewMatix.MultMatrix(myCamera);
    
    // 4. 镜面压栈
    modelViewMatix.PushMatrix();
    
    // 5. 添加反光效果
    // 翻转y轴
    modelViewMatix.Scale(1.0f, -1.0f, 1.0f);
    // 使镜面世界与y轴平移一段距离
    modelViewMatix.Translate(0.0f, 1.2f, 0.0f);
    
    // 6.指定顺时针为正面
    glFrontFace(GL_CW);
    
    // 7. 绘制地面以外其他地方-镜面
    drawSphere(rot);
    
    // 8. 恢复为逆时针为正面
    glFrontFace(GL_CCW);
    
    // 9.恢复绘制镜面的矩阵
    modelViewMatix.PopMatrix();
    // 开启混合功能
    glEnable(GL_BLEND);
    // 10。指定glBlendFunc 颜色混合方程式

    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    // 11.绑定地面纹理
    glBindTexture(GL_TEXTURE_2D, uiTextures[0]);
    
    /* 12
     纹理着色器——将基本色乘以一个取自纹理单元TextureUnit的纹理
     para1：GLT_SHADER_TEXTURE_MODULATE
     para2：模型视图投影矩阵
     para3: 颜色
     para4: 纹理单元 第0层的纹理单元
     
     */
     shaderManager.UseStockShader(GLT_SHADER_TEXTURE_MODULATE,
                                  transformPipeline.GetModelViewProjectionMatrix(),
                                  mFloorColor,
                                  0);
    floorBatch.Draw();
    
    // 13.取消混合
    glDisable(GL_BLEND);
    
    // 14.绘制地面以外的球体
    drawSphere(rot);
    
    // 15.绘制完毕，恢复矩阵
    modelViewMatix.PopMatrix();
    
    // 16.交换缓存区
    glutSwapBuffers();
    // 17.提交重新显示
    glutPostRedisplay();
}

/// 停止渲染，删除纹理
void shutDownRC()
{
    glDeleteTextures(3, uiTextures);
}

int main(int argc ,char* argv[])
{
    gltSetWorkingDirectory(argv[0]);
    // 初始化
    glutInit(&argc, argv);
    // 申请一个双缓存区、颜色缓存区、深度缓存区、模板缓存区
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGBA | GLUT_DEPTH );

    // 设置window的尺寸
    glutInitWindowSize(800, 600);

    // 创建window的名称
    glutCreateWindow("OpenGL Sphere");

    // 注册回调函数(改变尺寸)
    glutReshapeFunc(ChangeSize);

    // 点击空格时掉用函数
//    glutKeyboardFunc(KeyOnclick);

    // 显示函数
    glutDisplayFunc(RenderScene);

    // 设置特殊键位函数 ： 上下左右
    glutSpecialFunc(directionKeyOnclick);

    GLenum err = glewInit();
    if (GLEW_OK != err) {
        fprintf(stderr, "GLEW Init Error: %s\n", glewGetErrorString(err));
        return 1;
    }
    // 绘制
    SetupRC();

    // runloop 运行循环
    glutMainLoop();
    // 删除纹理
    shutDownRC();

    return 0;
   
}




