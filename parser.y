%{
	#define YYERROR_VERBOSE 1
	#include <stdio.h>
	extern int line;
%}

%token OPEN_OPENER CLOSE_OPENER CLOSER

/*the main tags that should be in the HTML file*/
%token DOCTYPE_TAG HTML_TAG HEAD_TAG BODY_TAG TITLE_TAG 
//%token COMMENT_TAG
%token COMMON_TAG //COMMON_UNARY_TAG
%token ATTRIBUTE_EQUAL VALUE

%%

/*hardcoding (doctype,html,head,title,body) 
as they are once-used tag*/
valid_HTML_doc: doctype_open doctype_content doctype_close|
error { yyerrok; printf("in line %d.\n", line); exit(-1);}

doctype_open: OPEN_OPENER DOCTYPE_TAG CLOSER

doctype_content: html_opener html_content html_closer

html_opener: OPEN_OPENER HTML_TAG CLOSER |
/*<hTml lang="ru" translate="no" class="adaptive" >*/
OPEN_OPENER HTML_TAG attributes CLOSER

attributes: attributes ATTRIBUTE_EQUAL VALUE 
			| ATTRIBUTE_EQUAL VALUE

html_content: head_element body_element
		| head_element

head_element: head_opener head_content head_close

head_opener: OPEN_OPENER HEAD_TAG CLOSER

head_content: title_opener title_closer

title_opener: OPEN_OPENER TITLE_TAG CLOSER

title_closer: CLOSE_OPENER TITLE_TAG CLOSER

head_close: CLOSE_OPENER HEAD_TAG CLOSER

body_element: body_opener body_content body_closer

body_opener: OPEN_OPENER BODY_TAG CLOSER

body_content: 
|common_tag_elenemt 
|body_content common_tag_elenemt

common_tag_elenemt: common_tag_elenemt common_tag_opener common_tag_elenemt common_tag_closer
| common_tag_elenemt common_tag_opener common_tag_closer
| common_tag_opener common_tag_closer

common_tag_opener: OPEN_OPENER COMMON_TAG CLOSER |
OPEN_OPENER COMMON_TAG attributes CLOSER

common_tag_closer: CLOSE_OPENER COMMON_TAG CLOSER

body_closer: CLOSE_OPENER BODY_TAG CLOSER

html_closer: CLOSE_OPENER HTML_TAG CLOSER

doctype_close: CLOSE_OPENER DOCTYPE_TAG CLOSER

%%