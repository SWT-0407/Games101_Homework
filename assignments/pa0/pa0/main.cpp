// C++ math library: provides sqrt, acos, sin, and other math functions.
#include<cmath>
// Eigen core types, including Vector3f and Matrix3f.
#include<Eigen/Core>
// Eigen dense-matrix operations used by the exercises below.
#include<Eigen/Dense>
// C++ standard input/output library; std::cout prints values to the terminal.
#include<iostream>

// main is the program entry point. Transformation.exe starts here.
int main(){

    // Basic Example of cpp
    std::cout << "Example of cpp \n";
    // Define two single-precision floating-point values.
    float a = 1.0, b = 2.0;
    // Print a, which is 1.
    std::cout << a << std::endl;
    // Print a / b, which is 0.5. This is floating-point division.
    std::cout << a/b << std::endl;
    // Print the square root of b, which is sqrt(2).
    std::cout << std::sqrt(b) << std::endl;
    // acos(-1) is pi. C++ trigonometric functions use radians.
    std::cout << std::acos(-1) << std::endl;
    // Convert 30 degrees to radians, then print sin(30 degrees), which is 0.5.
    std::cout << std::sin(30.0/180.0*acos(-1)) << std::endl;

    // Example of vector
    std::cout << "Example of vector \n";
    // vector definition
    // Vector3f is a column vector containing three float values.
    Eigen::Vector3f v(1.0f,2.0f,3.0f);
    Eigen::Vector3f w(1.0f,0.0f,0.0f);
    // vector output
    std::cout << "Example of output \n";
    // Eigen prints this column vector on three lines: 1, 2, and 3.
    std::cout << v << std::endl;
    // vector add
    std::cout << "Example of add \n";
    // Vector addition is component-wise: (1,2,3) + (1,0,0) = (2,2,3).
    std::cout << v + w << std::endl;
    // vector scalar multiply
    std::cout << "Example of scalar multiply \n";
    // A scalar may appear on either side of the vector.
    std::cout << v * 3.0f << std::endl;
    std::cout << 2.0f * v << std::endl;
    // TODO(PA0): Calculate and print the dot product of v and w.
    // Hint: a dot product is a scalar, so it can be printed directly.

    // Example of matrix
    std::cout << "Example of matrix \n";
    // matrix definition
    // Matrix3f is a 3-by-3 matrix whose elements are float values.
    Eigen::Matrix3f i,j;
    // Eigen's comma initializer fills the matrices in the written row order.
    i << 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0;
    j << 2.0, 3.0, 1.0, 4.0, 6.0, 5.0, 9.0, 7.0, 8.0;
    // matrix output
    std::cout << "Example of output \n";
    std::cout << i << std::endl;
    // matrix add i + j
    // TODO(PA0): Calculate and print the matrix sum i + j.
    // matrix scalar multiply i * 2.0
    // TODO(PA0): Calculate and print the scalar multiplication i * 2.0.
    // matrix multiply i * j
    // TODO(PA0): Calculate and print i * j. This is not component-wise multiplication.
    // matrix multiply vector i * v
    // TODO(PA0): Calculate and print i * v. The result is another column vector.

    // Final PA0 task: add your own code below these comments and before return 0.
    // Given P=(2,1), first rotate it 45 degrees counter-clockwise about the origin,
    // and then translate it by (1,2). Use homogeneous coordinates for all steps.
    // TODO(PA0): Represent the 2D point P as the homogeneous vector (x,y,1).
    // TODO(PA0): Build a 3-by-3 counter-clockwise rotation matrix using cos and sin.
    //             Convert 45 degrees to radians before calling the math functions.
    // TODO(PA0): Build a 3-by-3 homogeneous translation matrix for (1,2).
    // TODO(PA0): Compose and apply the transforms in "rotate, then translate" order.
    //             With column vectors, the transform applied first is closest to P.
    // TODO(PA0): Print the transformed homogeneous coordinate and verify its last
    //             component remains 1.

    // Returning 0 tells the operating system that the program finished normally.
    return 0;
}
