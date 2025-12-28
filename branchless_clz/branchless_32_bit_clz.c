#include <stdio.h>
#include <stdint.h>

int main()
{
    uint32_t mant_a = 1;

    // My own approach
    for(int i = 0; i < 31; i++) {
        uint32_t x = mant_a;
        uint32_t s, shift = 0;

    
        s = (x <= 0x0000FFFF);   shift += (s << 4); x <<= (s << 4); // 0000 0000 0000 0000 1111 1111 1111 1111
        s = (x <= 0x00FFFFFF);   shift += (s << 3); x <<= (s << 3); // 0000 0000 1111 1111 1111 1111 1111 1111
        s = (x <= 0x0FFFFFFF);   shift += (s << 2); x <<= (s << 2); // 0000 1111 1111 1111 1111 1111 1111 1111
        s = (x <= 0x3FFFFFFF);   shift += (s << 1); x <<= (s << 1); // 0011 1111 1111 1111 1111 1111 1111 1111
        s = (x <= 0x7FFFFFFF);   shift += (s << 0); x <<= (s << 0); // 0111 1111 1111 1111 1111 1111 1111 1111

    
        printf("clz(0x%x) = %d\n", mant_a, shift);
        mant_a <<= 1;
    }
    return 0;
}