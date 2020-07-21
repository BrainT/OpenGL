//
//  main.cpp
//  OpenGL图元
//
//  Created by TL on 2020/7/10.
//  Copyright © 2020 tl. All rights reserved.
//

#include "GLTools.h"


#include "GLMatrixStack.h" // 矩阵堆栈
#include "GLFrame.h" // 矩阵变换
#include "GLFrustum.h" // 投影矩阵
#include "GLBatch.h" // 7中不同的图元容器对象
#include "GLGeometryTransform.h" // 几何变换的管道

#include <math.h>
#ifdef __APPLE__
#include <glut/glut.h>
#else
#define FREEGLUT_STATIC
#include <GL/glut.h>
#endif

//设置角色帧，作为相机
GLFrame             viewFrame;
//使用GLFrustum类来设置透视投影
GLFrustum           viewFrustum;
// 三角形容器类
GLTriangleBatch     torusBatch;
// 模型矩阵堆栈
GLMatrixStack       modelViewMatix;
GLMatrixStack       projectionMatrix;
// 几何变换的管道
GLGeometryTransform transformPipeline;

GLShaderManager     shaderManager;

//标记：背面剔除、深度测试
int iCull = 0;
int iDepth = 0;

/// 初始化场景
void SetupRC()
{
    // 1.设置背景色
    glClearColor(0.59f, 0.39f, 0.78f, 1.0f);
    
    // 2.初始化着色器管理器
    shaderManager.InitializeStockShaders();
    
    // 3.将相机移动10个单元：肉眼到物体之间的距离
    viewFrame.MoveForward(10.0f);
    
    // 4.创建游泳圈
    /* void gltMakeTorus(GLTriangleBatch& torusBatch, GLfloat majorRadius, GLfloat minorRadius, GLint numMajor, GLint numMinor);
     * par1: GLTriangleBatch 容器帮助类，虽说是游泳圈，其最小单位还是有三角形组成
     * par2: 外边缘半径
     * par3: 内边缘半径
     * par4&5: 主半径和从半径的细分单元数量
     **/
    gltMakeTorus(torusBatch, 1.5f, 0.5, 60, 30);
    
    // 5.点的大小 方便肉眼观察
    glPointSize(4.0f);
    
}

/// 改变窗口大小
/// @param w 宽带
/// @param h 高度
void ChangeSize(int w,int h)
{
    // 1.判断h是否为0
    if (h == 0) {
        h = 1;
    }
    // 2.设置窗口尺寸
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
           viewFrame.RotateWorld(m3dDegToRad(-10.0f), 2, 0.0f, 0.0f);
           break;
       case GLUT_KEY_RIGHT:
           viewFrame.RotateWorld(m3dDegToRad(10.0f), 2, 0.0f, 0.0f);
           break;
       case GLUT_KEY_DOWN:
           viewFrame.RotateWorld(m3dDegToRad(-10.0f), 0, 2, 0.0f);
           break;
       case GLUT_KEY_LEFT:
           viewFrame.RotateWorld(m3dDegToRad(10.0f), 0, 2, 0.0f);
           break;
    }

    // 3.重新刷新
    glutPostRedisplay();
    
}

/// 渲染场景
void RenderScene()
{
    // 1.清除窗口、深度缓冲区
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // 背面剔除
    glEnable(GL_CULL_FACE);
    glCullFace(GL_BACK);
    
    // 2.把摄像机矩阵压入模型矩阵中->压栈
    modelViewMatix.PushMatrix(viewFrame);
    
    // 3.设置绘图颜色
    GLfloat vRGBA[] = {0.8f,0.73f,0.0f,1.0f};
    
    // 使用平面着色器
//    shaderManager.UseStockShader(GLT_SHADER_FLAT,transformPipeline.GetProjectionMatrix(),vRGBA);
    
    // 使用光源着色器
    shaderManager.UseStockShader(GLT_SHADER_DEFAULT_LIGHT, transformPipeline.GetModelViewMatrix(), transformPipeline.GetProjectionMatrix(), vRGBA);
    // 5.绘制在屏幕上
    torusBatch.Draw();
    
    // 6.出栈 绘制后 恢复
    modelViewMatix.PopMatrix();
    
    // 7.交换缓存区
    glutSwapBuffers();
}

int main(int argc ,char* argv[])
{
    gltSetWorkingDirectory(argv[0]);
    // 初始化
    glutInit(&argc, argv);
    // 申请一个颜色缓存区、深度缓存区、双缓存区、模板缓存区
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGBA | GLUT_DEPTH | GLUT_STENCIL);
    
    // 设置window的尺寸
    glutInitWindowSize(500, 500);
    
    // 创建window的名称
    glutCreateWindow("点点");
    
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




