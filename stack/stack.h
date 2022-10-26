#pragma once

#include <stdio.h>
#include <string.h>

typedef struct Names_stack 
{
    char name[256];
    int line;
    struct Names_stack* next;
    struct Names_stack* prev;
} NStack;

extern NStack* BOT;
extern NStack* TOP;

void push(const char* tag_name, int seen);
void pop(void);
int stack_main(const char* tag_name, int seen);
void print_stack(void);
