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

void summingFloats(const unsigned char* buffers, int buffersize, int count, unsigned char* outputbuffer) {
    int i,j;
    float sum;
    for (i=0; i<buffersize; i+=4) {
        sum = 0;
        for (j=0; j<count; j++) {
            sum+= .7*(*(float*)(buffers+i+(j*buffersize)));
        }
        *(float*)(outputbuffer+i) = sum;
    }
}