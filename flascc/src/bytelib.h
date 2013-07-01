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

float checkFirstByte(const unsigned char* buffer1, const unsigned char* buffer2,
    int buffersize);

void summingBytes(const unsigned char* buffer1, const unsigned char* buffer2,
    int buffersize, unsigned char* outputbuffer);
void summingFloats(const unsigned char* buffers, int buffersize, int count, unsigned char* outputbuffer);

int examinBytes(const unsigned char* buffer, int buffersize);