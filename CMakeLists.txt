cmake_minimum_required(VERSION 2.8)
project(sample_project)

find_package(OpenGL REQUIRED)
find_package(GLUT REQUIRED)
find_package(GLEW REQUIRED)

include_directories(
	${OPENGL_INCLUDE_DIR}
	${GLUT_INCLUDE_DIR}
	${GLEW_INCLUDE_DIR}
)

add_executable(main src/sample1.cpp)

target_link_libraries(main 
	${OPENGL_LIBRARIES}
	${GLUT_LIBRARIES}
	${GLEW_LIBRARIES}
)