#include <GL/glut.h>
// https://tokoik.github.io/opengl/libglut.html#3
void display(void)
{
}

int main(int argc, char *argv[])
{
  glutInit(&argc, argv);
  glutCreateWindow(argv[0]);
  glutDisplayFunc(display);
  glutMainLoop();
  return 0;
}
