#pragma warning(disable:4996)
#define _CRT_SECURE_NO_WARNINGS

#include <stdio.h>
#include <string.h>
#include <Windows.h>
#include <errno.h>
#include "tag_validator.h"

int present_in_file(const char* filename, const char* name)
{
	
	FILE* f;
	char* str;
	char cc[256];
	char* new_name;

	if ((f = fopen(filename, "r")) == NULL)
	{
		return -1;
	}

	new_name = first_word(name);

	if (is_data_(new_name))
	{
		fclose(f);
		return 1;
	}

	while ((str = fgets(cc, 256, f)) != NULL)
	{
		str[strlen(str) - 1] = '\0';
		if (!(strcmp(str, new_name)))
		{
			fclose(f);
			return 1;
		}
	}

	fclose(f);

	return 0;
}

int is_data_(const char* name)
{
	if (name[0] == 'd')
		if (name[1] == 'a')
			if (name[2] == 't')
				if (name[3] == 'a')
					if (name[4] == '-')
						return 1;

	return 0;
}

char* first_word(char* str)
{
	int pre_spaces = 0;
	int i = 0;
	char* new_str = NULL;
	while (str[i] == ' ')
	{
		pre_spaces++;
		i++;
	}
	int newlen = (strlen(str) + 1) - pre_spaces;
	
	//make new string without pre_spaces
	new_str = (char*)malloc(newlen);
	for (int j = 0; j < newlen; j++)
	{
		new_str[j] = str[i];
		i++;
	}

	i = 0;
	for (; i < newlen; i++)
	{
		if (new_str[i] == ' ' || new_str[i] == '=')
		{
			new_str[i] = '\0';
			break;
		}
	}
	return new_str;
}
