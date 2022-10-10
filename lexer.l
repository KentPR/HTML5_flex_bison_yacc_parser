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
%x TAG_VALIDATOR
%x DOCTYPE_VERSION_VALIDATOR
%x HTML_ATTRIBUTE_EXPRESSION

/*remove spaces and line breaks*/
line_break [\r\n]*[\n]*
space [\s]*[\t]*

/*Comment handler*/
comment_start			\<\!\-\-
comment_end				\-\-\>

/*Doctype handler*/
doctype 			\!doctype
public				public

/*other special tag*/
html_tag 				html
head_tag 				head
body_tag 				body
title_tag 				title

/*Attribute*/
attribute_name			[a-z]+([\-][a-z])*
attribute_value			([\"].*[\"])|([\'].*[\'])|[\d]+

/*for tags and attributes*/
name					[a-z]+
custom_name 			([a-z]+[\-])+[a-z\d]*

/*non HTML5 constuctions*/
/*such as XML, CDATA*/
xml_tag 				(xml)|(\?xml)
cdata_definition		(\!\[cdata\[)
%%
{doctype} 



[\<] {
	/*what tag is it?..*/
	//printf("%s", yytext);
	BEGIN(TAG_VALIDATOR);
}

<TAG_VALIDATOR>{
	{doctype} {
		//printf("%s", yytext);
		BEGIN(DOCTYPE_VERSION_VALIDATOR);
	}

	{html_tag} {
		//printf("%s", yytext);
		BEGIN(HTML_ATTRIBUTE_EXPRESSION);
	}

	{head_tag} {
		printf("%s", yytext);
		
	}

	. ;
}

<DOCTYPE_VERSION_VALIDATOR>{
	({space}|{line_break})+{html_tag}[\>] {
		//printf("%s", yytext);
		BEGIN(0);
		return DOCTYPE_FULL;
	}

	({space}|{line_break})+{html_tag}({space}|{line_break})+{public} {
		//printf("%s", yytext);
		printf("WARNING: Obsolete DOCTYPE! Use <!DOCTYPE html> instead.");
		BEGIN(0);
		return DOCTYPE_FULL;
	}

	. ;
}

<HTML_ATTRIBUTE_EXPRESSION>{
	({space}|{line_break})*[\>] {
		//printf("%s", yytext);
		BEGIN(0);
		return OPEN_HTML_TAG;
	}
	
	({space}|{line_break})+{attribute_name}({space}|{line_break})+[=]({space}|{line_break})+{attribute_value} {
		//printf("%s", yytext);
		BEGIN(HTML_ATTRIBUTE_EXPRESSION);
		/*need to validate*/
	}

	. ;
}

{line_break} {
	line++;
} 

. ;

%%

int yywrap(){}

void yyerror(char *msg)
{
    printf("%s . in line %d\n", msg, line);
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
		printf("argv[%d] - %s\n", i, argv[i]);
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