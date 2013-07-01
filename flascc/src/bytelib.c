/*
** ADOBE SYSTEMS INCORPORATED
** Copyright 2012 Adobe Systems Incorporated
** All Rights Reserved.
**
** NOTICE:  Adobe permits you to use, modify, and distribute this file in accordance with the
** terms of the Adobe license agreement accompanying it.  If you have received this file from a
** source other than Adobe, then your use, modification, or distribution of it requires the prior
** written permission of Adobe.
*/
#include "bytelib.h"
#include <stdio.h>

float checkFirstByte(const unsigned char* buffer1, const unsigned char* buffer2,
    int buffersize) {
    int i=0;
    return *(float*)(buffer1+i)+*(float*)(buffer2+i);;
}

void summingBytes(const unsigned char* buffer1, const unsigned char* buffer2,
    int buffersize, unsigned char* outputbuffer) {
    int i;
    for (i=0; i<buffersize; i+=4) {
        *(float*)(outputbuffer+i) = *(float*)(buffer1+i)+*(float*)(buffer2+i);
    }
}

void summingFloats(const unsigned char* buffers, int buffersize, int count, unsigned char* outputbuffer) {
    int i,j;
    float sum;
    for (i=0; i<buffersize; i+=4) {
        sum = 0;
        for (j=0; j<count; j++) {
            sum+= *(float*)(buffers+i+(j*buffersize));
        }
        *(float*)(outputbuffer+i) = sum;
    }
}

int examinBytes(const unsigned char* buffer, int buffersize) {
    int i;
    int result=0;
    for (i=0; i<buffersize; i++) {
        result += *buffer;
    }
    return result;
}
