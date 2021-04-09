%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "syntaxique.tab.h"
int nb_ligne = 1, col = 1;
extern YYSTYPE yylval;
%}
%option yylineno

%x pkg comment


IDF  [[:upper:]][[:alnum:]]{0,9}
CST_INTEGER ([[:digit:]]+)|(\([-+][[:digit:]]+\))
CST_REAL ({CST_INTEGER}\.{CST_INTEGER})|(\([-+]{CST_INTEGER}\.{CST_INTEGER}\))
CST_CHAR '.'
CST_STRING \"[^"]*\"

%%

"##" {
  rechercher(yytext, "", "sep", 0, "", 2);
  BEGIN(pkg);
  col += yyleng;
  printf("(%s)[SP_PKG] ", yytext);
  return SP_PKG;
}

<pkg>"PROCESS" {
  rechercher(yytext, "", "mc", 0, "", 1);
  col += yyleng;
  printf("(%s)[MC_PROCESS] ", yytext);
  return MC_PROCESS;
}

<pkg>"LOOP" {
  rechercher(yytext, "", "mc", 0, "", 1);
  col += yyleng;
  printf("(%s)[MC_LOOP] ", yytext);
  return MC_LOOP;
}

<pkg>"ARRAY" {
  rechercher(yytext, "", "mc", 0, "", 1);
  col += yyleng;
  printf("(%s)[MC_ARRAY] ", yytext);
  return MC_ARRAY;
}

<pkg>" " {
  col += yyleng;
  printf("[SPACE] ");
}

<pkg>"$" {
  rechercher(yytext, "", "sep", 0, "", 2);
  col += yyleng;
  printf("(%s)[SP_DOL] ", yytext);
  return SP_DOL;
}

<pkg>\n {
  rechercher("\\n", "", "sep", 0, "", 2);
  BEGIN(INITIAL);
  col = 1;
  nb_ligne++;
  printf("(\\n)[SP_NL]\n");
  return SP_NL;
}

"Programme" {
  rechercher(yytext, "", "mc", 0, "", 1);
  col += yyleng;
  printf("(%s)[MC_PROG] ", yytext);
  return MC_PROG;
}

"{" {
  rechercher(yytext, "", "sep", 0, "", 2);
  col += yyleng;
  printf("(%s)[SP_ACO] ", yytext);
  return SP_ACO;
}

"}" {
  rechercher(yytext, "", "sep", 0, "", 2);
  col += yyleng;
  printf("(%s)[SP_ACF] ", yytext);
  return SP_ACF;
}

"VAR" {
  rechercher(yytext, "", "mc", 0, "", 1);
  col += yyleng;
  printf("(%s)[MC_VAR] ", yytext);
  return MC_VAR;
}

"INTEGER" {
  rechercher(yytext, "", "mc", 0, "", 1);
  col += yyleng;
  printf("(%s)[MC_INTEGER] ", yytext);
  yylval.str = strdup(yytext);
  return MC_INTEGER;
}

"REAL" {
  rechercher(yytext, "", "mc", 0, "", 1);
  col += yyleng;
  printf("(%s)[MC_REAL] ", yytext);
  yylval.str = strdup(yytext);
  return MC_REAL;
}

"CHAR" {
  rechercher(yytext, "", "mc", 0, "", 1);
  col += yyleng;
  printf("(%s)[MC_CHAR] ", yytext);
  yylval.str = strdup(yytext);
  return MC_CHAR;
}

"STRING" {
  rechercher(yytext, "", "mc", 0, "", 1);
  col += yyleng;
  printf("(%s)[MC_STRING] ", yytext);
  yylval.str = strdup(yytext);
  return MC_STRING;
}

"CONST" {
  rechercher(yytext, "", "mc", 0, "", 1);
  col += yyleng;
  printf("(%s)[MC_CONST] ", yytext);
  yylval.str = strdup(yytext);
  return MC_CONST;
}

"READ" {
  rechercher(yytext, "", "mc", 0, "", 1);
  col += yyleng;
  printf("(%s)[MC_READ] ", yytext);
  yylval.str = strdup(yytext);
  return MC_READ;
}

"WRITE" {
  rechercher(yytext, "", "mc", 0, "", 1);
  col += yyleng;
  printf("(%s)[MC_WRITE] ", yytext);
  yylval.str = strdup(yytext);
  return MC_WRITE;
}

"WHILE" {
  rechercher(yytext, "", "mc", 0, "", 1);
  col += yyleng;
  printf("(%s)[MC_WHILE] ", yytext);
  yylval.str = strdup(yytext);
  return MC_WHILE;
}

"EXECUT" {
  rechercher(yytext, "", "mc", 0, "", 1);
  col += yyleng;
  printf("(%s)[MC_EXECUT] ", yytext);
  yylval.str = strdup(yytext);
  return MC_EXECUT;
}

"IF" {
  rechercher(yytext, "", "mc", 0, "", 1);
  col += yyleng;
  printf("(%s)[MC_IF] ", yytext);
  yylval.str = strdup(yytext);
  return MC_IF;
}

"ELSE" {
  rechercher(yytext, "", "mc", 0, "", 1);
  col += yyleng;
  printf("(%s)[MC_ELSE] ", yytext);
  yylval.str = strdup(yytext);
  return MC_ELSE;
}

"END_IF" {
  rechercher(yytext, "", "mc", 0, "", 1);
  col += yyleng;
  printf("(%s)[MC_END_IF] ", yytext);
  yylval.str = strdup(yytext);
  return MC_END_IF;
}

"INF" {
  rechercher(yytext, "", "sep", 0, "", 2);
  col += yyleng;
  printf("(%s)[SP_INF] ", yytext);
  return SP_INF;
}

"SUP" {
  rechercher(yytext, "", "sep", 0, "", 2);
  col += yyleng;
  printf("(%s)[SP_SUP] ", yytext);
  return SP_SUP;
}

"INFE" {
  rechercher(yytext, "", "sep", 0, "", 2);
  col += yyleng;
  printf("(%s)[SP_INFE] ", yytext);
  return SP_INFE;
}

"SUP" {
  rechercher(yytext, "", "sep", 0, "", 2);
  col += yyleng;
  printf("(%s)[SP_SUPE] ", yytext);
  return SP_SUPE;
}

"EG" {
  rechercher(yytext, "", "sep", 0, "", 2);
  col += yyleng;
  printf("(%s)[SP_EG] ", yytext);
  return SP_EG;
}

"DIFF" {
  rechercher(yytext, "", "sep", 0, "", 2);
  col += yyleng;
  printf("(%s)[SP_DIFF] ", yytext);
  return SP_DIFF;
}

"[" {
  rechercher(yytext, "", "sep", 0, "", 2);
  col += yyleng;
  printf("(%s)[SP_CRO] ", yytext);
  return SP_CRO;
}

"]" {
  rechercher(yytext, "", "sep", 0, "", 2);
  col += yyleng;
  printf("(%s)[SP_CRF] ", yytext);
  return SP_CRF;
}

"::" {
  rechercher(yytext, "", "sep", 0, "", 2);
  col += yyleng;
  printf("(%s)[SP_DP] ", yytext);
  return SP_DP;
}

"//" {
  rechercher(yytext, "", "sep", 0, "", 2);
  col += yyleng;
  printf("(%s)[SP_DS] ", yytext);
  return SP_DS;
}

"(" {
  rechercher(yytext, "", "sep", 0, "", 2);
  col += yyleng;
  printf("(%s)[SP_PAO] ", yytext);
  return SP_PAO;
}

")" {
  rechercher(yytext, "", "sep", 0, "", 2);
  col += yyleng;
  printf("(%s)[SP_PAF] ", yytext);
  return SP_PAF;
}

"|" {
  rechercher(yytext, "", "sep", 0, "", 2);
  col += yyleng;
  printf("(%s)[SP_VB] ", yytext);
  return SP_VB;
}

"@" {
  rechercher(yytext, "", "sep", 0, "", 2);
  col += yyleng;
  printf("(%s)[SP_AT] ", yytext);
  return SP_AT;
}

"$" {
  rechercher(yytext, "", "sep", 0, "", 2);
  col += yyleng;
  printf("(%s)[SP_DOL] ", yytext);
  return SP_DOL;
}

":=" {
  rechercher(yytext, "", "sep", 0, "", 2);
  col += yyleng;
  printf("(%s)[SP_AFF] ", yytext);
  return SP_AFF;
}

"=" {
  rechercher(yytext, "", "sep", 0, "", 2);
  col += yyleng;
  printf("(%s)[SP_AFF_DEC] ", yytext);
  return SP_AFF_DEC;
}

"+" {
  rechercher(yytext, "", "sep", 0, "", 2);
  col += yyleng;
  printf("(%s)[SP_ADD] ", yytext);
  return SP_ADD;
}

"-" {
  rechercher(yytext, "", "sep", 0, "", 2);
  col += yyleng;
  printf("(%s)[SP_SUB] ", yytext);
  return SP_SUB;
}

"*" {
  rechercher(yytext, "", "sep", 0, "", 2);
  col += yyleng;
  printf("(%s)[SP_MUL] ", yytext);
  return SP_MUL;
}

"/" {
  rechercher(yytext, "", "sep", 0, "", 2);
  col += yyleng;
  printf("(%s)[SP_DIV] ", yytext);
  return SP_DIV;
}

{IDF} {
  rechercher(yytext, "idf", "", 0, "", 0);
  col += yyleng;
  printf("(%s)[IDF] ", yytext);
  yylval.str = strdup(yytext);
  return IDF;
}

{CST_INTEGER} {
  if (yytext[0] == '(')
    yylval.entier = atoi(yytext + 1);
  else
    yylval.entier = atoi(yytext);
  if (yylval.entier >= -32768 && yylval.entier <= 32767) {
    rechercher(yytext, "const", "INTEGER", yylval.entier, "", 0);
    col += yyleng;
    printf("(%s)[CST_INTEGER] ", yytext);
    return CST_INTEGER;
  } else {
    printf("Erreur lexical: (%d - %d): %s: Constante entiere depassant la capacite d'un entier\n", nb_ligne, col, yytext);
    col += yyleng;
  }
}

{CST_REAL} {
  if (yytext[0] == '(')
    yylval.reel = atof(yytext + 1);
  else
    yylval.reel = atof(yytext);
  rechercher(yytext, "const", "REAL", yylval.reel, "", 0);
  col += yyleng;
  printf("(%s)[CST_REAL] ", yytext);
  return CST_REAL;
}

{CST_STRING} {
  int i = 0;
  for (i = 0; i < strlen(yytext); i++) {
    if (yytext[i] == '\n') {
      nb_ligne++;
      col = 1;
      printf("col %d\n", col);
    } else {
      col++;
    }
  }
  printf("(%s)[CST_STRING] ", yytext);
  yylval.str = strdup(yytext);
  rechercher(yytext, "const", "STRING", 0, yylval.str, 0);
  return CST_STRING;
}

{CST_CHAR} {
  col += yyleng;
  printf("(%s)[CST_CHAR] ", yytext);
  yylval.str = yytext;
  rechercher(yytext, "const", "CHAR", yylval.str[1], yylval.str, 0);
  return CST_CHAR;
}

"/*" {
  BEGIN(comment);
  printf("(%s)[DEBUT COMMENTAIRE] ", yytext);
}
<comment>[^*\n]* {
  printf("%s", yytext);
}
<comment>"*"+[^*/\n]* {
  printf("%s", yytext);
}
<comment>\n {
  printf("%s", yytext);
  nb_ligne++;
}
<comment>"*"+"/" {
  BEGIN(INITIAL);
  printf("(%s)[FIN COMMENTAIRE] ", yytext);
}

[ \t] {
  printf("[SPACE|TAB] ");
  col += yyleng;
}

\n {
  col = 1;
  nb_ligne++;
  printf("[NEWLINE]\n");
}

. {
  printf("Erreur lexical: (%d - %d): %s\n", nb_ligne, col, yytext);
  col += yyleng;
}
%%


