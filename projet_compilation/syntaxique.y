%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "utils.h"

extern FILE* yyin ;
extern int yylineno;
extern int nb_ligne;
extern int col;
extern char *yytext;

int yylex();

char type[100];
int qc = 0;
char tmp[100];
char args[100][100];
int nbArgs;
int ti = 1;
int includes[3] = {0, 0, 0};

Pile qcBoucle = NULL;
Pile qcSi = NULL;

%}
%error-verbose
%code requires {
    #include "utils.h"
}
%union {
  int entier;
  float reel;
  char *str;
  struct expression exp;
  struct expression_taille expTaille;
};

%start S
%type <str>Type
%type <str>Variable
%type <exp>Exp
%type <exp>Terme
%type <exp>Fact
%type <exp>Condition
%type <expTaille>ExpTaille
%type <expTaille>TermTaille
%type <expTaille>FactTaille

%nonassoc SP_SUP SP_INF SP_SUPE SP_INFE SP_EG SP_DIFF
%nonassoc SP_AFF
%left SP_ADD SP_SUB
%left SP_MUL SP_DIV

%token SP_PKG MC_PROCESS MC_LOOP MC_ARRAY SP_NL
%token <str>IDF SP_DOL
%token MC_PROG SP_ACO SP_ACF MC_VAR MC_CONST
%token <str>MC_INTEGER <str>MC_REAL <str>MC_CHAR <str>MC_STRING SP_DP SP_CRO SP_CRF SP_DS SP_AFF_DEC
%token <entier>CST_INTEGER <reel>CST_REAL <str>CST_CHAR <str>CST_STRING
%token MC_READ MC_WRITE SP_PAO SP_PAF SP_VB SP_AT
%token MC_EXECUT MC_IF MC_ELSE MC_END_IF MC_WHILE SP_INF SP_SUE SP_INFE SP_SUPE SP_EG SP_DIFF

%%

S: Imports Program SP_ACO Declarations Instructions SP_ACF
{
  printf("\nProgramme syntaxiquement correcte\n");
  YYACCEPT;
}
;

Imports: 
| Import Imports
;

Import: SP_PKG Package SP_DOL SP_NL
;

Package: MC_PROCESS
{
  if (includes[0] == 1)
     printf("\nErreur sementique: (%d - %d): PROCESS: Bibliotheque deja incluse\n", yylineno, col);
  includes[0] = 1;
}
| MC_LOOP
{
  if (includes[1] == 1)
     printf("\nErreur sementique: (%d - %d): LOOP: Bibliotheque deja incluse\n", yylineno, col);
  includes[1] = 1;
}
| MC_ARRAY
{
  if (includes[2] == 1)
     printf("\nErreur sementique: (%d - %d): ARRAY: Bibliotheque deja incluse\n", yylineno, col);
  includes[2] = 1;
}
;

Program: MC_PROG IDF
{
  setTypeTaille($2, "PROG", 0);
}
;

Declarations: 
| DeclarationsVars DeclarationsCsts
| DeclarationsCsts DeclarationsVars
| DeclarationsCsts
| DeclarationsVars
;

DeclarationsVars: MC_VAR ListeDeclarationsVars
;

DeclarationsCsts: MC_CONST ListeDeclarationsCsts
;

ListeDeclarationsVars:
| DeclarationVars ListeDeclarationsVars
;

ListeDeclarationsCsts:
| DeclarationCsts ListeDeclarationsCsts
;

DeclarationVars: Type SP_DP Vars SP_DOL
;

Vars: Var
| Var SP_DS Vars
;

Var: IDF
{
  if (estDeclaree($1)) {
    printf("\nErreur sementique: (%d - %d): %s: Variable deja declaree\n", yylineno, col, $1);
  } else {
    setTypeTaille($1, type, 1);
  }
}
| IDF SP_AFF_DEC Exp
{
  if (estDeclaree($1)) {
    printf("\nErreur sementique: (%d - %d): %s: Variable deja declaree\n", yylineno, col, $1);
  } else {
    setTypeTaille($1, type, 1);
  }

  if (strcmp($3.type, type) != 0)
    printf("\nErreur sementique: (%d - %d): %s: Incompatibilite de type %s et %s\n", yylineno, col, $1, type, $3.type);

  quadr("=", $3.id, "Vide",  $1);
}
| IDF SP_CRO ExpTaille SP_CRF
{
  if (includes[2] == 0) 
    printf("\nErreur sementique: (%d - %d): %s: Bibliotheque ARRAY non incluse\n", yylineno, col, $1);

  if (estDeclaree($1)) {
    printf("\nErreur sementique: (%d - %d): %s: Variable deja declaree\n", yylineno, col, $1);
  }  else {
    setTypeTaille($1, type, $3.val);
  }
  if ($3.val <= 0)
    printf("\nErreur sementique: (%d - %d): %d: Taille de tableau negative ou nulle\n", yylineno, col, $3);
  else 
    setBorn($1, 1, $3.val);
  if (includes[2] == 0)
    printf("\nErreur sementique: (%d - %d): %s: Bibliotheque ARRAY non incluse\n", yylineno, col, $1);
  
  setAsTab($1);

  quadr("BOUNDS", "1", $3.id, "Vide");
  quadr("ADEC", $1, "Vide",  "Vide");
}
;

ExpTaille: ExpTaille SP_ADD TermTaille
{
  if (includes[0] == 0) 
    printf("\nErreur sementique: (%d - %d): +: Bibliotheque PROCESS non incluse\n", yylineno, col);

  $$.val = $1.val + $3.val;
  sprintf($$.id, "t%d", ti++);
  quadr("+", $1.id, $3.id, $$.id);
}
| ExpTaille SP_SUB TermTaille
{
  if (includes[0] == 0) 
    printf("\nErreur sementique: (%d - %d): +: Bibliotheque PROCESS non incluse\n", yylineno, col);

  $$.val = $1.val - $3.val;
  sprintf($$.id, "t%d", ti++);
  quadr("-", $1.id, $3.id, $$.id);
}
| TermTaille
;
TermTaille: TermTaille SP_MUL FactTaille
{
  if (includes[0] == 0) 
    printf("\nErreur sementique: (%d - %d): +: Bibliotheque PROCESS non incluse\n", yylineno, col);

  $$.val = $1.val * $3.val;
  sprintf($$.id, "t%d", ti++);
  quadr("*", $1.id, $3.id, $$.id);
}
| TermTaille SP_DIV FactTaille
{
  if (includes[0] == 0) 
    printf("\nErreur sementique: (%d - %d): +: Bibliotheque PROCESS non incluse\n", yylineno, col);

  if ($3.val == 0) {
    printf("\nErreur sementique: (%d - %d): %s:Division par zero\n", yylineno, col, $3.id);
    $$.val = 0;
  } else {
    $$.val = $1.val / $3.val;
  }
  sprintf($$.id, "t%d", ti++);
  quadr("*", $1.id, $3.id, $$.id);
}
| FactTaille
;
FactTaille: CST_INTEGER
{
  sprintf($$.id, "%d", $1);
  $$.val = $1;
}
;

DeclarationCsts: Type SP_DP Csts SP_DOL
;

Csts: Cst
| Cst SP_DS Csts
;

Cst: IDF
{
  if (estDeclaree($1)) {
    printf("\nErreur sementique: (%d - %d): %s: Constante deja declaree\n", yylineno, col, $1);
  } else {
    setTypeTaille($1, type, 0);
    setAsConst($1);
  }
}
| IDF SP_AFF_DEC Exp
{
  if (estDeclaree($1)) {
    printf("\nErreur sementique: (%d - %d): %s: Constante deja declaree\n", yylineno, col, $1);
  } else {
    setTypeTaille($1, type, 1);
    setAsConst($1);
  }

  if (strcmp($3.type, type) != 0)
    printf("\nErreur sementique: (%d - %d): %s: Incompatibilite de type %s et %s\n", yylineno, col, $1, type, $3.type);

  quadr("=", $3.id, "Vide",  $1);
}
;

Type: MC_INTEGER
{
  strcpy(type, $1);
}
| MC_REAL
{
  strcpy(type, $1);
}
| MC_CHAR
{
  strcpy(type, $1);
}
| MC_STRING
{
  strcpy(type, $1);
}
;

Instructions: 
| Instruction Instructions
;

Instruction: Affectation SP_DOL
| Read SP_DOL
| Write SP_DOL
| Boucle
| SiSimple
| SiSinon
;

Affectation: Variable SP_AFF Exp
{
  Element e = extraireElement(extraireName($1));
  
  if (e.estCst == 1)
    if (e.taille != 0)
      printf("\nErreur sementique: (%d - %d): %s: Changement de la valeur d'un constante\n", yylineno, col, $1);
    else
      setTypeTaille($1, NULL, 1);
  
  if (strcmp(e.type, $3.type) != 0)
    printf("\nErreur sementique: (%d - %d): %s: Incompatibilite de type %s et %s\n", yylineno, col, $1, e.type, $3.type);

  quadr(":=", $3.id, "Vide",  $1);
}
;

Exp: Exp SP_ADD Terme
{
  if (includes[0] == 0) 
    printf("\nErreur sementique: (%d - %d): +: Bibliotheque PROCESS non incluse\n", yylineno, col);

  if (strcmp($1.type, $3.type) != 0)
    printf("\nErreur sementique: (%d - %d): %s: Incompatibilite de type %s et %s\n", yylineno, col, $1, $1.type, $3.type);

  sprintf($$.id, "t%d", ti++);
  quadr("+", $1.id, $3.id, $$.id);

  strcpy($$.type, $1.type);
}
| Exp SP_SUB Terme
{
  if (includes[0] == 0) 
    printf("\nErreur sementique: (%d - %d): -: Bibliotheque PROCESS non incluse\n", yylineno, col);

  if (strcmp($1.type, $3.type) != 0)
    printf("\nErreur sementique: (%d - %d): %s: Incompatibilite de type %s et %s\n", yylineno, col, $1, $1.type, $3.type);

  if (strcmp($1.type, "STRING") == 0 || strcmp($3.type, "STRING") == 0)
    printf("\nErreur sementique: (%d - %d) %s - %s: Utilisation d'un type non numerique dans une expression de soustraction\n", yylineno, col, $1.id, $3.id);

  sprintf($$.id, "t%d", ti++);
  quadr("-", $1.id, $3.id, $$.id);
  
  strcpy($$.type, $1.type);
}
| Terme
;

Terme: Terme SP_MUL Fact
{
  if (includes[0] == 0) 
    printf("\nErreur sementique: (%d - %d): *: Bibliotheque PROCESS non incluse\n", yylineno, col);

  if (strcmp($1.type, $3.type) != 0)
    printf("\nErreur sementique: (%d - %d): %s: Incompatibilite de type %s et %s\n", yylineno, col, $1, $1.type, $3.type);

  if (strcmp($1.type, "STRING") == 0 || strcmp($3.type, "STRING") == 0 
     || strcmp($1.type, "CHAR") == 0 || strcmp($3.type, "CHAR") == 0)
    printf("\nErreur sementique: (%d - %d) %s * %s: Utilisation d'un type non numerique dans une expression de multiplication\n", yylineno, col, $1.id, $3.id);

  sprintf($$.id, "t%d", ti++);
  quadr("*", $1.id, $3.id, $$.id);

  strcpy($$.type, $1.type);
}
| Terme SP_DIV Fact
{
  if (includes[0] == 0) 
    printf("\nErreur sementique: (%d - %d): /: Bibliotheque PROCESS non incluse\n", yylineno, col);

  if (strcmp($1.type, $3.type) != 0)
    printf("\nErreur sementique: (%d - %d): %s: Incompatibilite de type %s et %s\n", yylineno, col, $1, $1.type, $3.type);
  
  if (strcmp($1.type, "STRING") == 0 || strcmp($3.type, "STRING") == 0 
     || strcmp($1.type, "CHAR") == 0 || strcmp($3.type, "CHAR") == 0)
    printf("\nErreur sementique: (%d - %d) %s / %s: Utilisation d'un type non numerique dans une expression de division\n", yylineno, col, $1.id, $3.id);

  if (isdigit($3.id[0]) && atof($3.id) == 0)
    printf("\nErreur sementique: (%d - %d): %s:Division par zero\n", yylineno, col, $3.id);

  sprintf($$.id, "t%d", ti++);
  quadr("/", $1.id, $3.id, $$.id);
  
  strcpy($$.type, $1.type);
}
| Fact
;

Fact: SP_PAO Exp SP_PAF
{
  strcpy($$.id, $2.id);
  strcpy($$.type, $2.type);
}
| Variable 
{
  Element e = extraireElement(extraireName($1));
  if (e.estCst == 1 && e.taille == 0)
    printf("\nErreur sementique: (%d - %d): %s: Utilisation d'une constante non initialisee\n", yylineno, col, $1);
  
  strcpy($$.id, $1);
  strcpy($$.type, e.type);
}
| CST_INTEGER
{
  sprintf($$.id, "%d", $1);
  strcpy($$.type, "INTEGER");
}
| CST_REAL
{
  sprintf($$.id, "%f", $1);
  strcpy($$.type, "REAL");
}
| CST_CHAR
{
  strcpy($$.id, $1);
  strcpy($$.type, "CHAR");
}
| CST_STRING
{
  strcpy($$.id, $1);
  strcpy($$.type, "STRING");
}
;

Variable: IDF
{
  Element e = extraireElement($1);

  $$ = $1;
  if (!estDeclaree($1))
    printf("\nErreur sementique: (%d - %d): %s: Variable non declaree\n", yylineno, col, $1);

  if (e.estTab == 1)
    printf("\nErreur sementique: (%d - %d): %s: Utilisation d'un tableau comme constante\n", yylineno, col, $1);
}
| IDF SP_CRO ExpTaille SP_CRF
{
  $$ = (char*)malloc(sizeof(char) * 20);
  sprintf($$, "%s[%d]", $1, $3.val);

  if (includes[2] == 0)
    printf("\nErreur sementique: (%d - %d): %s: Bibliotheque ARRAY non incluse\n", yylineno, col, $1);

  if (!estDeclaree($1)) {
    printf("\nErreur sementique: (%d - %d): %s: Variable non declaree\n", yylineno, col, $1);
  } else {
    switch (verifTableau($1, $3.val)) {
      case 0:
        break;
      case 1:
        printf("\nErreur sementique: (%d - %d): %s: Variable n'est pas un tableau\n", yylineno, col, $1);
        break;
      case 2:
        printf("\nErreur sementique: (%d - %d): %s: Indice errone\n", yylineno, col, $1);
        break;
    }
  }
}
;

Read: MC_READ SP_PAO CST_STRING SP_VB SP_AT Variable SP_PAF
{
  char c;
  char operand[2];
  operand[1] = '\0';
  Element e = extraireElement(extraireName($6));
  if (e.estCst == 1)
    if (e.taille != 0)
      printf("\nErreur sementique: (%d - %d): %s: Changement de la valeur d'un constante\n", yylineno, col, $6);
    else
      setTypeTaille($6, NULL, 1);

  if ((c = prochainFormateur($3)) != -1) {
    switch (c) {
      case ';':
        if (strcmp(e.type, "INTEGER") != 0)
          printf("\nErreur sementique: (%d - %d): %s: Type de la variable incompatible avec le signe de formatage $\n", yylineno, col, $6);
        break;
      case '%':
        if (strcmp(e.type, "REAL") != 0)
          printf("\nErreur sementique: (%d - %d): %s: Type de la variable incompatible avec le signe de formatage \%\n", yylineno, col, $6);
        break;
      case '#':
        if (strcmp(e.type, "STRING") != 0)
          printf("\nErreur sementique: (%d - %d): %s: Type de la variable incompatible avec le signe de formatage #\n", yylineno, col, $6);
        break;
      case '&':
        if (strcmp(e.type, "CHAR") != 0)
          printf("\nErreur sementique: (%d - %d): %s: Type de la variable incompatible avec le signe de formatage &\n", yylineno, col, $6);
        break;
      default:
        break;
    }
  } else {
    printf("\nErreur sementique: (%d - %d): %s: Signe de formatage inconnu\n", yylineno, col, $3);
  }

  if (prochainFormateur($3) != -1) {
    printf("\nErreur sementique: (%d - %d): %s: Signe de formatage multiple\n", yylineno, col, $3);
  }

  operand[0] = c;
  quadr("READ", $3, operand, $6);
}
;

Write: MC_WRITE SP_PAO CST_STRING Args SP_PAF
{
  int i = 0;
  int c;
  Element e;
  while ((c = prochainFormateur($3)) != -1 && i < nbArgs) {
    e = extraireElement(extraireName(args[i]));
    switch (c) {
      case ';':
        if (strcmp(e.type, "INTEGER") != 0)
          printf("\nErreur sementique: (%d - %d): %s: Type de la variable incompatible avec le signe de formatage $\n", yylineno, col, args[i]);
        quadr("ARG", ";", args[i], "Vide");
        break;
      case '%':
        if (strcmp(e.type, "REAL") != 0)
          printf("\nErreur sementique: (%d - %d): %s: Type de la variable incompatible avec le signe de formatage \%\n", yylineno, col, args[i]);
        quadr("ARG", "%", args[i], "Vide");
        break;
      case '#':
        if (strcmp(e.type, "STRING") != 0)
          printf("\nErreur sementique: (%d - %d): %s: Type de la variable incompatible avec le signe de formatage #\n", yylineno, col, args[i]);
        quadr("ARG", "#", args[i], "Vide");
        break;
      case '&':
        if (strcmp(e.type, "CHAR") != 0)
          printf("\nErreur sementique: (%d - %d): %s: Type de la variable incompatible avec le signe de formatage &\n", yylineno, col, args[i]);
        quadr("ARG", "&", args[i], "Vide");
        break;
      default:
        break;
    }
    i++;
  }
  if (c != -1) {
    printf("\nErreur sementique: (%d - %d): : Nombre d'arguments insuffisant\n", yylineno, col);
  } else if (i != nbArgs) {
    printf("\nErreur sementique: (%d - %d): : Nombre de signes de formatage insuffisant\n", yylineno, col);
  }
  nbArgs = 0;
  quadr("WRITE", $3, "Vide", "Vide");
}
;

Args:
| ListArgs
;

ListArgs: SP_VB Variable
{
  Element e = extraireElement(extraireName($2));
  if (e.estCst == 1 && e.taille == 0)
    printf("\nErreur sementique: (%d - %d): %s: Utilisation d'une constante non initialisee\n", yylineno, col, $2);

  strcpy(args[nbArgs], $2);
  nbArgs++;
}
| ListArgs SP_VB Variable 
{
  Element e = extraireElement(extraireName($3));
  if (e.estCst == 1 && e.taille == 0)
    printf("\nErreur sementique: (%d - %d): %s: Utilisation d'une constante non initialisee\n", yylineno, col, $3);

  strcpy(args[nbArgs], $3);
  nbArgs++;
}
;

Condition: Exp SP_INF Exp
{
  sprintf($$.id, "t%d", ti++);
  quadr("INF", $1.id, $3.id, $$.id);
}
| Exp SP_SUP Exp
{
  sprintf($$.id, "t%d", ti++);
  quadr("SUP", $1.id, $3.id, $$.id);
}
| Exp SP_INFE Exp
{
  sprintf($$.id, "t%d", ti++);
  quadr("INFE", $1.id, $3.id, $$.id);
}
| Exp SP_SUPE Exp
{
  sprintf($$.id, "t%d", ti++);
  quadr("SUPE", $1.id, $3.id, $$.id);
}
| Exp SP_EG Exp
{
  sprintf($$.id, "t%d", ti++);
  quadr("EG", $1.id, $3.id, $$.id);
}
| Exp SP_DIFF Exp
{
  sprintf($$.id, "t%d", ti++);
  quadr("DIFF", $1.id, $3.id, $$.id);
}
;

Boucle: ABoucle SP_ACO Instructions SP_ACF
{
  int qcDebCond, qcBZ;
  qcBoucle = depiler(qcBoucle, &qcBZ);
  qcBoucle = depiler(qcBoucle, &qcDebCond);

  sprintf(tmp, "%d", qcDebCond);
  quadr("BR", tmp, "Vide", "Vide");
  sprintf(tmp, "%d", qc);
  ajour_quad(qcBZ, 1, tmp);
}
;

ABoucle: BBoucle SP_PAO Condition SP_PAF
{
  qcBoucle = empiler(qcBoucle, qc);
  quadr("BZ", "", $3.id, "Vide");
}
;

BBoucle: MC_WHILE
{
  if (includes[1] == 0) 
    printf("\nErreur sementique: (%d - %d): WHILE: Bibliotheque LOOP non incluse\n", yylineno, col);
  qcBoucle = empiler(qcBoucle, qc);
}
;

SiSimple: DebSi Instructions FinInstructions Si FinSi
;

SiSinon: DebSi Instructions FinInstructions Si MC_ELSE MC_EXECUT Instructions FinSi
;

DebSi: MC_EXECUT
{
  qcSi = empiler(qcSi, qc);
  quadr("BR", "", "Vide", "Vide");
}
;

FinInstructions: 
{
  qcSi = empiler(qcSi, qc);
  quadr("BR", "", "Vide", "Vide");
}

Si: MC_IF SP_PAO Condition SP_PAF
{
  int qcDeb, qcFin;
  qcSi = depiler(qcSi, &qcFin);
  qcSi = depiler(qcSi, &qcDeb);
  qcSi = empiler(qcSi, qcFin);
  sprintf(tmp, "%d", qcDeb + 1);
  quadr("BNZ", tmp, $3.id, "Vide");
  sprintf(tmp, "%d", qcFin + 1);
  ajour_quad(qcDeb, 1, tmp);
}
;

FinSi: MC_END_IF
{
  int qcFin;
  qcSi = depiler(qcSi, &qcFin);
  sprintf(tmp, "%d", qc);
  ajour_quad(qcFin, 1, tmp);
}
;


%%

int yyerror(char *msg) {
  printf("Erreur syntaxique (%d - %d): %s, %s\n", nb_ligne, col, yytext, msg);
  return 1;
}

int yywrap() {
}

int main(int argc, char **argv) {
  ++argv, --argc;
  initialisation();
  if (argc > 0)
    yyin = fopen(argv[0], "r");
  else
    yyin = stdin;
  yyparse();
  afficher();
  afficher_qdr();
  return 0;
}

