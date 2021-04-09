#ifndef __TS__
#define __TS__

#include <stdio.h>
#include <stdlib.h>

typedef struct Element {
  int state;
  char name[100];
  char code[100];
  char type[100];
  int estCst;
  int estTab;
  float valNum;
  char valStr[100];
  int taille;
  int bornInf;
  int bornSup;
  struct Element *svt;
} Element, *ListeElements;

typedef struct Elt { 
  int state; 
  char name[100];
  char type[100];
  struct Elt *svt;
} Elt, *ListeElts;

ListeElements listeIdfCst;
ListeElts listeMc, listeSep;

typedef struct Qdr {
  int qc;
  char oper[100]; 
  char op1[100];   
  char op2[100];   
  char res[100];
  struct Qdr *svt;
} Qdr, *ListeQdr;

ListeQdr listeQdr;
extern int qc;

typedef struct expression {
  char type[100];
  char id[100];
} expression;

typedef struct expression_taille {
  int val;
  char id[100];
} expression_taille;

typedef struct ElementPile{
	int info;
	struct ElementPile *svt;
} ElementPile, *Pile;

Pile initPile();
Pile empiler(Pile sommet, int x);
Pile depiler(Pile sommet, int *x);
int sommetPile(Pile sommet);
int pileVide(Pile sommet);


/*initialisation de l'état des cases des tables des symbloles
0: la case est libre    1: la case est occupée*/
void initialisation();
/* insertion des entititées lexicales dans les tables des symboles*/
void inserer(char *name, char *code, char *type, float valNum, char *valStr, int y, Element *element, Elt *elt);
/*chercher si l'entité existe dèja dans la table*/
void rechercher(char *name, char *code, char *type, float valNum, char *valStr, int y);
/*affichage*/
void afficher();
/*estDeclaree
   Si la variable est declaree elle retourne 1
   Sinon elle retourne 0 et si le type n'est pas null elle affecte le type à la varialbe
*/
int estDeclaree(char *name);
void setTypeTaille(char *name, char *type, int taille);
void setAsConst(char *name);
void setAsTab(char *name);
void setBorn(char *name, int bornInf, int bornSup);

int verifTableau(char *name, int indice);

char *extraireName(char *s);

Element extraireElement(char *name);

void quadr(char *opr, char *op1, char *op2, char *res);

void ajour_quad(int num_quad, int colon_quad, char *val);

void afficher_qdr();

char chaineValideLecture(char *s);

int prochainFormateur(char *s);

#endif

