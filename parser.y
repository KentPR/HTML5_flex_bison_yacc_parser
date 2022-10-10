%{
	#define YYERROR_VERBOSE 1
	#include <stdio.h>
	extern int line;
%}

/*the main tags that should be in the HTML file*/
%token DOCTYPE_FULL 
%token OPEN_HTML_TAG CLOSE_HTML_TAG
%token OPEN_HEAD_TAG CLOSE_HEAD_TAG
%token OPEN_BODY_TAG CLOSE_BODY_TAG
%token OPEN_TITLE_TAG CLOSE_TITLE_TAG

%token OPEN_COMMON_TAG CLOSE_COMMON_TAG UNARY_TAG

%%

/*hardcoding (doctype,html,head,title,body) 
as they are once-used tag*/
valid_HTML_doc: DOCTYPE_FULL OPEN_HTML_TAG html_content CLOSE_HTML_TAG
			|error { yyerrok; printf("in line %d.\n", line); exit(-1);}

/*HTML document can be without a <body>
but can't be without a <head>
*/
html_content: OPEN_HEAD_TAG head_content CLOSE_HEAD_TAG
			| OPEN_HEAD_TAG head_content CLOSE_HEAD_TAG OPEN_BODY_TAG body_content CLOSE_BODY_TAG

/*exactly one <title> is required in HTML document!*/
head_content: other_head_content OPEN_TITLE_TAG CLOSE_TITLE_TAG other_head_content


/*other tags  allowed in <head> such as:
<style>
<base>
<link>
<meta>
<script>
<noscript>
*/
other_head_content: /*nothing or <unary>+*/
				| other_head_content UNARY_TAG


body_content: /*<body> section can be empty*/
			| body_content OPEN_COMMON_TAG body_content CLOSE_COMMON_TAG
			| body_content UNARY_TAG

%%