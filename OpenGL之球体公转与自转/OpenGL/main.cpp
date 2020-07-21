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

/// 初始化场景
void SetupRC()
{
    // 1.设置背景色
    glClearColor(0.1, 0.1, 0.1f, 1.0f);
   
    // 2.初始化着色器管理器
    shaderManager.InitializeStockShaders();
    // 开启深度测试
    glEnable(GL_DEPTH_TEST);
//    glEnable(GL_);
       
    // 3.将相机移动10个单元：肉眼到物体之间的距离
//    cameraFrame.MoveForward(10.0f);
    
    floorBatch.Begin(GL_LINES, 400);
    for (GLfloat x = -20.0; x <= 20.0f; x+=0.5) {
        floorBatch.Vertex3f(x, -0.55f, 20.0f);
        floorBatch.Vertex3f(x, -0.55f , -20.0f);
        floorBatch.Vertex3f(20.0f, -0.55f, x);
        floorBatch.Vertex3f(-20.0f, -0.55f, x);
    }
    floorBatch.End();
    
    // 初始化一个球体 球体批次类，半径，片段数，堆积数量
    gltMakeSphere(bigSphereBatch, 0.6f, 50, 100);
    
    // 初始化小球
    gltMakeSphere(globlueBatch, 0.15f, 20, 40);
        
    for (int i = 0; i < Spheres_Num; i ++) {
        // y值不变，x，z值随机产生
        GLfloat x = ((GLfloat)((rand() % 500) - 300 ) * 0.1f);
        GLfloat z = ((GLfloat)((rand() % 500) - 300 ) * 0.1f);
        
        // 在y值方向上，将球体的位置固定在0.0f，这使得小球固定在眼睛的高度；对spheres数组的每个顶点设置顶点数据
        spheres[i].SetOrigin(x,0.0f,z);
        
    }
 
    
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
    viewFrustum.SetPerspective(45.0f, float(w)/float(h), 2.0f, 100.0f);
    
    // 4.把透视矩阵加载到透视矩阵对阵中
    projectionMatrix.LoadMatrix(viewFrustum.GetProjectionMatrix());
    
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
void directionOnclick(int key, int x, int y)
{
    // 1.判断方向
    switch (key) {
       case GLUT_KEY_UP:
           // 2.根据方向调整观察者位置
            cameraFrame.MoveForward(-2.0f);
           break;
       case GLUT_KEY_RIGHT:
           cameraFrame.RotateWorld(m3dDegToRad(10.0f), 0, 2, 0.0f);
           break;
       case GLUT_KEY_DOWN:
            cameraFrame.MoveForward(3.0f);
           break;
       case GLUT_KEY_LEFT:
           cameraFrame.RotateWorld(-m3dDegToRad(10.0f), 0, 2, 0.0f);
           break;
    }

    // 3.重新刷新
    glutPostRedisplay();
    
}

/// 渲染场景
void RenderScene()
{
    // 0.设置颜色值-地板 球体
    static GLfloat mFloorColor[] = {0.8,0.8,0.1,1.0};
    static GLfloat mGloblueColor[] = {0.1,0.3,0.9,1.0};
    static GLfloat mBigSphereColor[] = {0.7,0.7,0.7,1.0};
    
    // 1.清除窗口、深度缓冲区
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
 
    // 设置定时器动画
    static CStopWatch rotTimer;
    
    float rot = rotTimer.GetElapsedSeconds() * 60.f;
    
    // 2.把摄像机矩阵压入模型矩阵中->压栈
    modelViewMatix.PushMatrix(cameraFrame);

    // 3.将观察者提前一轮绘制，不影响下一层的布局
    M3DMatrix44f myCamera;
    cameraFrame.GetCameraMatrix(myCamera);
    
    modelViewMatix.PushMatrix(myCamera);
    
    // 4.使用光源着色器 绘制地面
    shaderManager.UseStockShader(GLT_SHADER_FLAT, transformPipeline.GetModelViewProjectionMatrix(), mFloorColor);
    // 绘制在屏幕上
    floorBatch.Draw();
    
    // 5.设置点光源位置
    M3DVector4f vLightPosition = {0,10,5,1};
    // 6.将打球远离观察位置5个单位
    modelViewMatix.Translate(0, 0, -5.0f);
    
    // 7.绘制大球
    modelViewMatix.PushMatrix();
    modelViewMatix.Rotate(rot, 0, 1, 0);
    shaderManager.UseStockShader(GLT_SHADER_POINT_LIGHT_DIFF,
                                 transformPipeline.GetModelViewMatrix(),
                                 transformPipeline.GetProjectionMatrix(),
                                 vLightPosition,mBigSphereColor);
    bigSphereBatch.Draw();
    modelViewMatix.PopMatrix(); // 打球绘制完成，再出栈
    
    // 8.小球
    for (int i = 0; i<Spheres_Num; i ++) {
        modelViewMatix.PushMatrix();
        modelViewMatix.MultMatrix(spheres[i]);
        shaderManager.UseStockShader(GLT_SHADER_POINT_LIGHT_DIFF,
                                     transformPipeline.GetModelViewMatrix(),
                                     transformPipeline.GetProjectionMatrix(),
                                     vLightPosition,mBigSphereColor);
        globlueBatch.Draw();
        modelViewMatix.PopMatrix(); // 小球绘制完成，再出栈
    }
    
    modelViewMatix.Rotate(rot * -2.0f, 0, 1, 0);
    modelViewMatix.Translate(1.2f, 0.0f, 0.0f);
    shaderManager.UseStockShader(GLT_SHADER_POINT_LIGHT_DIFF,
                                 transformPipeline.GetModelViewMatrix(),
                                 transformPipeline.GetProjectionMatrix(),
                                 vLightPosition,mGloblueColor);
    globlueBatch.Draw();
    
     // 9.出栈 绘制后 恢复
    modelViewMatix.PopMatrix();
    
    modelViewMatix.PopMatrix();
    
    // 10.交换缓存区
    glutSwapBuffers();
    // 11.提交重新显示
    glutPostRedisplay();
}

int main(int argc ,char* argv[])
{
    gltSetWorkingDirectory(argv[0]);
    // 初始化
    glutInit(&argc, argv);
    // 申请一个双缓存区、颜色缓存区、深度缓存区、模板缓存区
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGBA | GLUT_DEPTH | GLUT_STENCIL);
    
    // 设置window的尺寸
    glutInitWindowSize(500, 500);
    
    // 创建window的名称
    glutCreateWindow("OpenGL Sphere");
    
    // 注册回调函数(改变尺寸)
    glutReshapeFunc(ChangeSize);
    
    // 点击空格时掉用函数
//    glutKeyboardFunc(KeyOnclick);
    
    // 设置特殊键位函数 ： 上下左右
    glutSpecialFunc(directionOnclick);
    
    // 显示函数
    glutDisplayFunc(RenderScene);
    
    GLenum err = glewInit();
    if (GLEW_OK != err) {
        fprintf(stderr, "GLEW Init Error: %s\n", glewGetErrorString(err));
        return 1;
    }
    
    // 绘制
    SetupRC();
    
    // runloop 运行循环
    glutMainLoop();
    
    return 0;
}




