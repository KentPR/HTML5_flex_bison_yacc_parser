#include "stack.h"

void push(const char* tag_name, int seen)
{
    NStack* tmp = malloc(sizeof(NStack));
    tmp->next = NULL;
    tmp->line = seen;

    for (int i = 0; i <= strlen(tag_name); i++)
    {
        tmp->name[i] = tag_name[i];
    }

    if (TOP != NULL)
    {
        tmp->prev = TOP;
        TOP->next = tmp;
    }

    if (BOT == NULL)
    {
        tmp->prev = NULL;
        BOT = tmp;
    }

    TOP = tmp;
}

void pop(void)
{
    NStack* tmp = TOP;
    if (TOP->prev != NULL) 
    {
        TOP = TOP->prev;
        TOP->next = NULL;
    }
    else
    {
        BOT = NULL;
        TOP = NULL;
    }
    free(tmp);
}

int stack_main(const char* tag_name, int seen)
{
    NStack* tmp = TOP;
    char ch[256];
    
    if (tag_name[strlen(tag_name) - 1] == '>')
    {
        for (int i = 0; i < strlen(tag_name) - 1; i++)
        {
            ch[i] = tag_name[i];
        }
        ch[strlen(tag_name)-1] = '\0';
        if (!strcmp(tmp->name, ch))
        {
            pop();
        }
        else
        {
            printf("ERROR: Unecpected </%s>! Expexted </%s> | ", ch, tmp->name);
            return -1;
        }
    }
    else
    {
        for (int i = 0; i < strlen(tag_name); i++)
        {
            ch[i] = tag_name[i];
        }
        ch[strlen(tag_name)] = '\0';
        push(ch, seen);
    }
    return 0;
}

void print_stack(void)
{
    NStack* tmp = BOT;
    if (BOT == NULL)
    {
        return;
    }
    
    while (1)
    {
        if (tmp->next == NULL)
        {
            printf("%d) %s\n", tmp->line, tmp->name);
            break;
        }
        else
        {
            printf("%d) %s\n", tmp->line, tmp->name);
            tmp = tmp->next;
        }
    }

    //printf("%d) %s\n", TOP->line, TOP->name);

    return;
}