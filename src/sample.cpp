
// deform_disp.c   図形の描画　//以下はコメント
#include <GL/glut.h> // GLUTライブラリを使用

void display(void) // 表示関数
{
  glClear(GL_COLOR_BUFFER_BIT); //背景色で塗る
  glColor3d( 1.0, 0.5, 0.5 );   // 描画色を赤で指定(赤成分,緑成分,青成分)
  glLineWidth( 1.5 );           // 線幅指定(画素単位)
  glPointSize( 6.0 );           // 点の大きさ指定(画素単位)

// 次のglBegin( )の７つのいずれか１つのみを有効にしてみよう
//  glBegin(GL_POINTS);           // 表示対象(点群)作成
//  glBegin(GL_LINES);            // 表示対象(線分)作成
//  glBegin(GL_LINE_STRIP);       // 表示対象(折れ線)作成
//  glBegin(GL_LINE_LOOP);        // 表示対象(閉じた折れ線)作成
//  glBegin(GL_TRIANGLE_STRIP);   // 表示対象(三角形の連なり)作成
//  glBegin(GL_TRIANGLE_FAN);     // 表示対象(1頂点を共有した三角形群)作成
  glBegin(GL_TRIANGLES);        // 表示対象(三角形)作成
     glVertex2d(-0.69, 0.4 );   // ２次元の頂点座標(x,y)
     glVertex2d(-0.69,-0.4 );
     glVertex2d( 0.  , 0.8 );
     glVertex2d( 0.  ,-0.8 );
     glVertex2d( 0.69, 0.4 );
     glVertex2d( 0.69,-0.4 );
  glEnd();                      // 表示対象作成終了
  glFlush();                    // 画面に出力
}

int main(int argc, char *argv[])    // 主関数(プログラムのスタート)
{
  glutInit(&argc, argv);            // グラフィック初期化
  glutInitDisplayMode(GLUT_RGBA);   // 画素毎に色を指定する描画モード
  glutInitWindowSize( 480,480 );    // ウィンドウの大きさ指定
  glutCreateWindow(argv[0]);        // 描画ウィンドウ作成(引数は表示される文字列を与える)
  glutDisplayFunc(display);         // 描画関数指定
  glClearColor(1.0, 1.0, 1.0, 1.0); // 背景色指定(白)
  glutMainLoop();                   // 割り込み待ち
  return 0;
}
