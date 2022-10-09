/* Declaration section*/
%{
	#define _CRT_SECURE_NO_WARNINGS
	#include "stackFuncs.cpp"
	#include <stdio.h>
	#include "parser.tab.h"
	
	extern FILE* yyin;
	int line = 1;
	#ifndef unix
	#define fileno _fileno
	#endif
%}

%option stack yylineno caseless

%x doctype_version_validator


/*remove spaces and line breaks*/
skip [\t]*[\r\n]*[\n]*
space [\s]*

/*Comment handler*/
COMMENT_start			\<\!\-\-
COMMENT_end				\-\-\>

/*Doctype handler*/
DOCTYPE_tag 			\!doctype

/*other special tag*/
HTML_tag 				html
HEAD_tag 				head
BODY_tag 				body
TITLE_tag 				title

/*Attribute value may*/
ATTRIBUTE_value			([\"].*[\"])|([\'].*[\'])|[\d]+

/*for tags and attributes*/
name					[a-z]+
custom_name 			([a-z]+[\-])+[a-z\d]*

/*non HTML5 constuctions*/
/*such as XML, CDATA*/
XML_tag 				(xml)|(\?xml)
CDATA_definition		(\!\[cdata\[)

%%

\<{DOCTYPE_tag}{space}*{skip}*
{
	BEGIN(doctype_version_validator);
}

<doctype_version_validator>
{
	{HTML_tag}
	{
		BEGIN(0);
		return DOCTYPE_TAG
	}
	{HTML_tag}{space}*public
	{
		printf("ERROR: Obsolete doctype. Expected <!DOCTYPE html>.", line);
		exit(-1);
	}
}

%% 
  
int yywrap(){}

void yyerror(char *msg)
{
    printf("%s \n", msg); 
}
  
int main(int argc, char*argv[])
{
	errno_t err;
    
	if (argc < 2)
	{
		printf("no filename\n");
		exit(-1);
	}

	for (int i = 1; i < argc; i++) 
	{
		printf("argv[%d] - %s", i, argv[i]);
	}

    if ((err = fopen_s(&yyin, argv[1], "r")) != 0) {
		printf("file not found.\n");
		exit(-1);
	} 
	tagStackInit();
    // The function that starts the analysis
	yyparse();
	tagStackDeinit();
	fclose(yyin);
	printf("Parse status - ok.\n");
    return 0;
}