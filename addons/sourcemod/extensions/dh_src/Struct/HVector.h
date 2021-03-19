#ifndef __Navigation_vector_h__
#define __Navigation_vector_h__

class HVector {
public:
    HVector(float x, float y, float z)
    {
        this->x = x;
        this->y = y;
        this->z = z;
    }
    float x;
    float y;
    float z;
};

#endif
