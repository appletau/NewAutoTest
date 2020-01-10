//
//  libControlBits.c
//  autoTest
//
//  Created by Li Richard on 13-8-29.
//  Copyright (c) 2013年 TOM. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h> //C99 support boolean
#include "CBAuth_API.h"
#include "libControlBits.h"

bool IP_CBsToClearOnFail(void)
{
    size_t size;
    
    bool cbResult = ControlBitsToClearOnFail(NULL,&size);
    
    if (cbResult)
    {
        int *array = (int *)malloc(size*sizeof(int));
        
        cbResult = ControlBitsToClearOnFail(array,&size);
        if(cbResult)
        {
            for(int i = 0; i < size;i++)
            {
                printf("%02x:%d \n", array[i],array[i]);
            }
            
            free(array);
            printf("returned true from\n");
            
            return true;
        }
        
    }
    else
    {
        printf("%ld\nreply was not successful from first call\n",size);
    }
    
    return false;
}

bool IP_CBsToClearOnPass(void)
{
    size_t size;
    
    bool cbResult = ControlBitsToClearOnPass(NULL,&size);
    
    
    if(cbResult)
    {
        int *array = (int *)malloc(size*sizeof(int));
        
        cbResult = ControlBitsToClearOnPass(array,&size);
        if(cbResult)
        {
            for(int i=0; i<size;i++)
            {
                printf("%02x:%d \n", array[i],array[i]);
            }
            free(array);
            printf("returned true from\n");
            
            return true;
        }
        
    }
    else
    {
        printf("%ld\nreply was not successful from first call\n",size);
    }
    
    return false;
}

bool IP_CBsToCheck(int *dstArray,size_t *arrayLength,char stationNameArray[ARRAYSIZE][ARRAYSIZE])
{
    size_t size;
    
    bool cbResult = ControlBitsToCheck(NULL,&size,NULL);
    *arrayLength = size;
    
    if(cbResult)
    {
        int *array = (int *)malloc(size*sizeof(int));
        char **stationNames = (char **)malloc(size*sizeof(char *));
        for(int i =0; i<size;i++)
            stationNames[i] =(char *) malloc(256*sizeof(char));
        
        cbResult = ControlBitsToCheck(array,&size,stationNames);
        if(cbResult)
        {
            for(int i=0; i<size;i++)
            {
                //printf("%02x:%d == ", array[i],array[i]);
                //printf("%s \n ",stationNames[i]);
                dstArray[i] = array[i];
                strcpy(stationNameArray[i],stationNames[i]);
            }
            for(int i=0; i<size;i++)
            {
            
                free(stationNames[i]);
            }
            free(array);
            free(stationNames);
            //printf("returned true from\n");
            
            return true;
        }
        
    }
    else
    {
        printf("%ld\nreply was not successful from first call\n",size);
    }
    
    return false;
}

int IP_StationFailCountAllowed(void)
{
    return StationFailCountAllowed();
}

bool IP_CBsToClearOnPass2(int *dstArray,size_t *arrayLength)
{
    size_t size;
    bool cbResult = ControlBitsToClearOnPass(NULL,&size);
    *arrayLength = size;
    
    if(cbResult)
    {
        int *array = (int *)malloc(size*sizeof(int));
        
        cbResult = ControlBitsToClearOnPass(array,&size);
        if(cbResult)
        {
            for(int i=0; i<size;i++)
                dstArray[i] = array[i];
            
            free(array);
            return true;
        }
    }
    else
        printf("%ld\nreply was not successful from first call\n",size);
    
    return false;
}
bool IP_CBsToClearOnFail2(int *dstArray,size_t *arrayLength)
{
    size_t size;
    bool cbResult = ControlBitsToClearOnFail(NULL,&size);
    *arrayLength = size;
    
    if(cbResult)
    {
        int *array = (int *)malloc(size*sizeof(int));
        
        cbResult = ControlBitsToClearOnFail(array,&size);
        if(cbResult)
        {
            for(int i=0; i<size;i++)
                dstArray[i] = array[i];
            
            free(array);
            return true;
        }
    }
    else
        printf("%ld\nreply was not successful from first call\n",size);
    
    return false;
}

bool setCb()
{
    return StationSetControlBit();
}

const char * getAuthVersion()
{
    return cbauthVersion();
}

unsigned char * IP_CBToCreateSHA1(unsigned char* secretKey, unsigned char* nonce)
{
    return CreateSHA1(secretKey, nonce);
}

