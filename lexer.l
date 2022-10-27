/* Declaration section*/
%{
	#define _CRT_SECURE_NO_WARNINGS
	#include "stackFuncs.cpp"
	#include "names_validator/tag_validator.c"
	#include "stack/stack.c"
	#include <stdio.h>
	#include "parser.tab.h"
	
	extern FILE* yyin;
	int line = 1;
	NStack* BOT;
	NStack* TOP;
	#ifndef unix
	#define fileno _fileno
	#endif
%}

%option stack yylineno caseless
%x TAG_VALIDATOR
%x DOCTYPE_VERSION_VALIDATOR
%x HTML_ATTRIBUTE_EXPRESSION
%x HEAD_ATTRIBUTE_EXPRESSION
%x BODY_ATTRIBUTE_EXPRESSION
%x TITLE_ATTRIBUTE_EXPRESSION
%x COMMON_ATTRIBUTE_EXPRESSION
%x UNARY_ATTRIBUTE_EXPRESSION
%x CLOSING_TAG
%x COMMENT_EXPRESSION

/*remove spaces and line breaks*/
line_break (\n)
space [( )|(\t)]

/*Comment handler*/
comment_start			\!\-\-
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
attribute_name			[a-z]+([\-][a-z]*)*
attribute_value			([\"][^\<\>]+?[\"])|([\']([^\<\>]?+)[\'])

/*for tags and attributes*/
/*can be h1 to h6 and can be without digits in it*/
name					[a-z]+[1-6]*
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
		//printf("%s\n", yytext);
		BEGIN(DOCTYPE_VERSION_VALIDATOR);
	}

	{html_tag} {
		//printf("%s\n", yytext);
		BEGIN(HTML_ATTRIBUTE_EXPRESSION);
	}

	{head_tag} {
		//printf("%s\n", yytext);
		BEGIN(HEAD_ATTRIBUTE_EXPRESSION);
	}

	{body_tag} {
		//printf("%s\n", yytext);
		BEGIN(BODY_ATTRIBUTE_EXPRESSION);
	}

	{title_tag} {
		//printf("%s\n", yytext);
		BEGIN(TITLE_ATTRIBUTE_EXPRESSION);
	}

	{name} {
		printf("%s %d\n", yytext, line);
		//check if valid
		int res = present_in_file("database/tags/all.txt", yytext);
		if(res==-1)
		{
			printf("ERROR: Can't open file \"database/tags/all.txt\"! file not found.\n");
			exit(-1);
		}
		if(res==0)
		{
			printf("ERROR: Unrecognised tag <%s>! in line: %d\n", yytext, line);
			exit(-1);
		}
		//check if obsolete
		res = present_in_file("database/tags/old.txt", yytext);
		if(res==-1)
		{
			printf("ERROR: Can't open file \"database/tags/old.txt\"! file not found. %d\n",line);
			exit(-1);
		}
		if(res==1)
		{
			printf("WARNING: Tag <%s> is obsolete! in line: %d\n", yytext, line);
			BEGIN(COMMON_ATTRIBUTE_EXPRESSION);
		}
		//check if unary 
		res = present_in_file("database/tags/unary.txt", yytext);
		if(res==-1)
		{
			printf("ERROR: Can't open file \"database/tags/unary.txt\"! file not found.\n");
			exit(-1);
		}
		if(res==1)
		{
			BEGIN(UNARY_ATTRIBUTE_EXPRESSION);
		}
		else
		{
			if(stack_main(yytext, line)==-1)
		{
			printf("in line %d", line);
			exit(-1);
		}
			BEGIN(COMMON_ATTRIBUTE_EXPRESSION);
		}
	}

	{custom_name} {
		//printf("%s\n", yytext);
		if(stack_main(yytext, line)==-1)
		{
			printf("in line %d", line);
			exit(-1);
		}
		printf("NOTE: Be careful using custom tags! in line %d\n", line);
		BEGIN(COMMON_ATTRIBUTE_EXPRESSION);
	}

	[\/] {
		//printf("%s\n", yytext);
		BEGIN(CLOSING_TAG);
	}

	{comment_start} {
		BEGIN(COMMENT_EXPRESSION);
	}

	. { 
		printf("ERROR: Unexpected \'%s\' after <! %d", yytext, line);
		exit(-1);
	}
}

<DOCTYPE_VERSION_VALIDATOR>{
	({space}|{line_break})+{html_tag}[\>] {
		//printf("%s", yytext);
		line+=LB_count(yytext);
		BEGIN(0);
		return DOCTYPE_FULL;
	}

	({space}|{line_break})+{html_tag}({space}|{line_break})+{public} {
		//printf("%s", yytext);
		line+=LB_count(yytext);
		printf("WARNING: Obsolete DOCTYPE! Use <!DOCTYPE html> instead.\n");
		BEGIN(0);
		return DOCTYPE_FULL;
	}

	. ;
}

<HTML_ATTRIBUTE_EXPRESSION>{
	({space}|{line_break})*[\>] {
		//printf("%s", yytext);
		line+=LB_count(yytext);
		BEGIN(0);
		return OPEN_HTML_TAG;
	}
	
	({space}|{line_break})+{attribute_name}({space}|{line_break})*[=]({space}|{line_break})*{attribute_value} {
		int res = present_in_file("database/attributes/all.txt", yytext);
		if(res==-1)
		{
			printf("ERROR: Can't open file \"database/attributes/all.txt\"! file not found.\n");
			exit(-1);
		}
		if(res==0)
		{
			printf("ERROR: Unrecognised attribute \"%s\"! in line: %d\n", yytext, line);
			exit(-1);
		}
		res = present_in_file("database/attributes/old.txt", yytext);
		if(res==-1)
		{
			printf("ERROR: Can't open file \"database/attributes/old.txt\"! file not found.\n");
			exit(-1);
		}
		if(res==1)
		{
			printf("WARNING: Attribute \"%s\" is obsolete! in line: %d\n", yytext, line);
		}
		line+=LB_count(yytext);
		BEGIN(HTML_ATTRIBUTE_EXPRESSION);
		/*need to validate*/
	}

	. ;
}

<HEAD_ATTRIBUTE_EXPRESSION>{
	({space}|{line_break})*[\>] {
		//printf("%s", yytext);
		line+=LB_count(yytext);
		BEGIN(0);
		return OPEN_HEAD_TAG;
	}
	
	({space}|{line_break})+{attribute_name}({space}|{line_break})*[=]({space}|{line_break})*{attribute_value} {
		//printf("%s", yytext);
		int res = present_in_file("database/attributes/all.txt", yytext);
		if(res==-1)
		{
			printf("ERROR: Can't open file \"database/attributes/all.txt\"! file not found.\n");
			exit(-1);
		}
		if(res==0)
		{
			printf("ERROR: Unrecognised attribute \"%s\"! in line: %d\n", yytext, line);
			exit(-1);
		}
		res = present_in_file("database/attributes/old.txt", yytext);
		if(res==-1)
		{
			printf("ERROR: Can't open file \"database/attributes/old.txt\"! file not found.\n");
			exit(-1);
		}
		if(res==1)
		{
			printf("WARNING: Attribute \"%s\" is obsolete! in line: %d\n", yytext, line);
			exit(-1);
		}
		line+=LB_count(yytext);
		BEGIN(HEAD_ATTRIBUTE_EXPRESSION);
		/*need to validate*/
	}

	. ;
}

<BODY_ATTRIBUTE_EXPRESSION>{
	({space}|{line_break})*[\>] {
		//printf("%s", yytext);
		line+=LB_count(yytext);
		BEGIN(0);
		return OPEN_BODY_TAG;
	}
	
	({space}|{line_break})+{attribute_name}({space}|{line_break})*[=]({space}|{line_break})*{attribute_value} {
		//printf("%s", yytext);
		int res = present_in_file("database/attributes/all.txt", yytext);
		if(res==-1)
		{
			printf("ERROR: Can't open file \"database/attributes/all.txt\"! file not found.\n");
			exit(-1);
		}
		if(res==0)
		{
			printf("ERROR: Unrecognised attribute \"%s\"! in line: %d\n", yytext, line);
			exit(-1);
		}
		res = present_in_file("database/attributes/old.txt", yytext);
		if(res==-1)
		{
			printf("ERROR: Can't open file \"database/attributes/old.txt\"! file not found.\n");
			exit(-1);
		}
		if(res==1)
		{
			printf("WARNING: Attribute \"%s\" is obsolete! in line: %d\n", yytext, line);
			exit(-1);
		}
		line+=LB_count(yytext);
		BEGIN(BODY_ATTRIBUTE_EXPRESSION);
		/*need to validate*/
	}

	. ;
}

<TITLE_ATTRIBUTE_EXPRESSION>{
	({space}|{line_break})*[\>] {
		//printf("%s", yytext);
		line+=LB_count(yytext);
		BEGIN(0);
		return OPEN_TITLE_TAG;
	}
	
	({space}|{line_break})+{attribute_name}({space}|{line_break})*[=]({space}|{line_break})*{attribute_value} {
		//printf("%s", yytext);
		int res = present_in_file("database/attributes/all.txt", yytext);
		if(res==-1)
		{
			printf("ERROR: Can't open file \"database/attributes/all.txt\"! file not found.\n");
			exit(-1);
		}
		if(res==0)
		{
			printf("ERROR: Unrecognised attribute \"%s\"! in line: %d\n", yytext, line);
			exit(-1);
		}
		res = present_in_file("database/attributes/old.txt", yytext);
		if(res==-1)
		{
			printf("ERROR: Can't open file \"database/attributes/old.txt\"! file not found.\n");
			exit(-1);
		}
		if(res==1)
		{
			printf("WARNING: Attribute \"%s\" is obsolete! in line: %d\n", yytext, line);
			exit(-1);
		}
		line+=LB_count(yytext);
		BEGIN(TITLE_ATTRIBUTE_EXPRESSION);
		/*need to validate*/
	}

	. ;
}

<COMMON_ATTRIBUTE_EXPRESSION>{
	({space}|{line_break})*[\>] {
		//printf("%s", yytext);
		line+=LB_count(yytext);
		BEGIN(0);
		return OPEN_COMMON_TAG;
	}

	({space}|{line_break})*\/\> {
		//printf("%s", yytext);
		line+=LB_count(yytext);
		BEGIN(0);
		return OPEN_COMMON_TAG;
	}
	
	({space}|{line_break})+{attribute_name}({space}|{line_break})*[=]({space}|{line_break})*{attribute_value} {
		printf("\t%s %d\n", yytext, line);
		
		line+=LB_count(yytext);
		BEGIN(COMMON_ATTRIBUTE_EXPRESSION);
		/*need to validate*/
	}

	. ;
}

<UNARY_ATTRIBUTE_EXPRESSION>{
	({space}|{line_break})*[\>] {
		//printf("%s", yytext);
		line+=LB_count(yytext);
		BEGIN(0);
		return UNARY_TAG;
	}

	({space}|{line_break})*\/\> {
		//printf("%s", yytext);
		line+=LB_count(yytext);
		BEGIN(0);
		return UNARY_TAG;
	}
	
	({space}|{line_break})+{attribute_name}({space}|{line_break})*[=]({space}|{line_break})*{attribute_value} {
		//printf("%s %d\n", yytext, line);
		
		line+=LB_count(yytext);
		BEGIN(UNARY_ATTRIBUTE_EXPRESSION);
		/*need to validate*/
	}

	. ;
}

<CLOSING_TAG>{
	{html_tag}{space}*[\>] {
		//printf("%s\n", yytext);
		BEGIN(0);
		return CLOSE_HTML_TAG;
	}

	{head_tag}{space}*[\>] {
		//printf("%s\n", yytext);
		BEGIN(0);
		return CLOSE_HEAD_TAG;
	}

	{body_tag}{space}*[\>] {
		//printf("%s\n", yytext);
		BEGIN(0);
		return CLOSE_BODY_TAG;
	}

	{title_tag}{space}*[\>] {
		//printf("%s\n", yytext);
		BEGIN(0);
		return CLOSE_TITLE_TAG;
	}

	{name}{space}*[\>] {
		printf("%s %d\n", yytext, line);
		if(stack_main(yytext, line)==-1)
		{
			printf("in line %d", line);
			exit(-1);
		}
		BEGIN(0);
		return CLOSE_COMMON_TAG;
	}

	{custom_name}{space}*[\>] {
		if(stack_main(yytext, line)==-1)
		{
			printf("in line %d", line);
			exit(-1);
		}
		BEGIN(0);
		return CLOSE_COMMON_TAG;
	}

	. ;
}

<COMMENT_EXPRESSION>{
	{comment_end} {
		BEGIN(0);
	}

	{line_break} {
	line++;
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
		printf("Can't open file \"%s\". File not found.\n", argv[1]);
		exit(-1);
	} 
	//tagStackInit();
    // The function that starts the analysis
	yyparse();
	//tagStackDeinit();
	fclose(yyin);
	print_stack();
	printf("Parse status - ok. || total lines: %d\n", line);
    return 0;
}