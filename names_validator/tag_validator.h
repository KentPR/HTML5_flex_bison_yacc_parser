#pragma once

//typedef struct DB
//{
//	FILE* unary_tags = nullptr;
//	FILE* binary_tags = nullptr;
//	FILE* obsolete_tags = nullptr;
//}DB;

int present_in_file(const char* filename, const char* tagname);

int is_data_(const char* tagname);

char* first_word(char* str);