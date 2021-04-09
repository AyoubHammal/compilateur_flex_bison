#include <stdio.h>
#include <stdlib.h>
#include "utils.h"

void initialisation() {
  listeIdfCst = NULL;
   listeMc = NULL;
   listeSep = NULL;
}


/* insertion des entititées lexicales dans les tables des symboles*/

void inserer(char *name, char *code, char *type, float valNum, char *valStr, int y, Element *element, Elt *elt) {
  switch (y) { 
    case 0:/*insertion dans la table des IDF et CONST*/
      element->state = 1;
      strcpy(element->name, name);
      strcpy(element->code, code);
      strcpy(element->type, type);
      element->valNum = valNum;
      strcpy(element->valStr, valStr);
      if (strcmp(code, "const") == 0 && (strcmp(type, "INTEGER") == 0 || strcmp(type, "REAL") == 0 || strcmp(type, "CHAR") == 0))
        element->taille = 1;
      else if (strcmp(code, "const") == 0 && strcmp(type, "STRING") == 0)
        element->taille = strlen(name) - 2;
      break;

    case 1:/*insertion dans la table des mots clés*/
      elt->state = 1;
      strcpy(elt->name, name);
      strcpy(elt->type, type);
      break; 
    
    case 2:/*insertion dans la table des séparateurs*/
      elt->state = 1;
      strcpy(elt->name, name);
      strcpy(elt->type, type);
      break;
 }

}

/**************************chercher si l'entité existe dèja dans la table*/
void rechercher(char *name, char *code, char *type, float valNum, char *valStr, int y) {
  Element *p = NULL;
  Elt *q = NULL;
  switch(y) {
    case 0:/*verifier si la case dans la tables des IDF et CONST est libre*/
      p = listeIdfCst;
      while (p != NULL && strcmp(name, p->name) != 0)
        p = p->svt;
      if (p == NULL) {
        // Creer un nouvel element
        if (listeIdfCst == NULL) {
          // La liste est vide
          listeIdfCst = (Element*) malloc(sizeof(Element));
          p = listeIdfCst;
          p->state = 0;
          p->valNum = 0;
          p->estCst = 0;
          p->taille = 0;
          p->estTab = 0;
          p->bornInf = 0;
          p->bornSup = 0;
          p->svt = NULL;
        } else {
          p = listeIdfCst;
          while (p->svt != NULL)
            p = p->svt;
          p->svt = (Element*) malloc(sizeof(Element));
          p = p->svt;
          p->state = 0;
          p->valNum = 0;
          p->estCst = 0;
          p->taille = 0;
          p->estTab = 0;
          p->bornInf = 0;
          p->bornSup = 0;
          p->svt = NULL;
        }
        inserer(name, code, type, valNum, valStr, 0, p, NULL);
      }
      break;
  
    case 1:/*verifier si la case dans la tables des mots clés est libre*/
      q = listeMc;
      while (q != NULL && strcmp(name, q->name) != 0)
        q = q->svt;
      if (q == NULL) {
        // Creer un nouvel element
        if (listeMc == NULL) {
          // La liste est vide
          listeMc = (Elt*) malloc(sizeof(Elt));
          q = listeMc;
          q->svt = NULL;
        } else {
          q = listeMc;
          while (q->svt != NULL)
            q = q->svt;
          q->svt = (Elt*) malloc(sizeof(Elt));
          q = q->svt;
          q->svt = NULL;
        }
        inserer(name, code, type, valNum, valStr, 1, NULL, q);
      }
      break; 
      
    case 2:/*verifier si la case dans la tables des séparateurs est libre*/
      q = listeSep;
      while (q != NULL && strcmp(name, q->name) != 0)
        q = q->svt;
      if (q == NULL) {
        // Creer un nouvel element
        if (listeSep == NULL) {
          // La liste est vide
          listeSep = (Elt*) malloc(sizeof(Elt));
          q = listeSep;
          q->svt = NULL;
        } else {
          q = listeSep;
          while (q->svt != NULL)
            q = q->svt;
          q->svt = (Elt*) malloc(sizeof(Elt));
          q = q->svt;
          q->svt = NULL;
        }
        inserer(name, code, type, valNum, valStr, 2, NULL, q);
      }
      break; 
  }
}

/****************affichage*******************/
void afficher() {
  Element *p = NULL;
  Elt *q = NULL;
  printf("\n-----------------------------------------------------------------------------------------------------------------------------------------------\n");
  printf("|                                                           Table des symboles IDF                                                            |\n"); 
  printf("-----------------------------------------------------------------------------------------------------------------------------------------------\n");
  printf("| State |   Name    | Code/Nature |   Type   |    ValeurNum    |    ValeurStr    | Canstante |   Taille   |  Tableau  |  BornInf  |  BornSup  |\n");
  printf("-----------------------------------------------------------------------------------------------------------------------------------------------\n");
  p = listeIdfCst;
  while (p != NULL) {
    printf("|%7d|%11s|%13s|", p->state, p->name, p->code);
    printf("%10s|", p->type);
    printf("%17f|%17s|%11d|", p->valNum, p->valStr, p->estCst);
    printf("%12d|%11d|%11d|%11d|\n", p->taille, p->estTab, p->bornInf, p->bornSup);
    p = p->svt;
  }
  printf("-----------------------------------------------------------------------------------------------------------------------------------------------\n");
  

  printf("\n--------------------------------\n");
  printf("| Table des symboles mots cles |\n"); 
  printf("--------------------------------\n");
  printf("| State |   Name    |   Type   |\n");
  printf("--------------------------------\n");
  q = listeMc;
  while (q != NULL) {
    printf("|%7d|%11s|%10s|\n", q->state, q->name, q->type);
    q = q->svt;
  }
  printf("--------------------------------\n");
  

  printf("\n--------------------------------\n");
  printf("|Table des symboles separateurs|\n"); 
  printf("--------------------------------\n");
  printf("| State |   Name    |   Type   |\n");
  printf("--------------------------------\n");
  q = listeSep;
  while (q != NULL) {
    printf("|%7d|%11s|%10s|\n", q->state, q->name, q->type);
    q = q->svt;
  }
  printf("--------------------------------\n");
  
}

/*********************estDeclaree***********/
/* Si la variable est declaree elle retourne 1
   Sinon elle retourne 0 et si le type n'est pas null elle affecte le type à la varialbe
  */
int estDeclaree(char *name) {
  Element *p = listeIdfCst;
  while (p != NULL && strcmp(name, p->name) != 0)
    p = p->svt;
  if (p != NULL) {
    if (strcmp(p->type, "") == 0) {
      // premiere declaration
      return 0; // varibale non declaree
    }
    return 1; // variable declaree
  }
  // cas identifiant ne se trouve pas dans la table des idf : impossible car l'analyse lexical l'ajoute deja
  return 0; // variable non declaree
}

void setTypeTaille(char *name, char *type, int taille) {
  Element *p = listeIdfCst;
  while (p != NULL && strcmp(name, p->name) != 0)
    p = p->svt;
  if (p != NULL) {
    if (taille > 0) {
      p->taille = taille;
    }
    if (strcmp(p->type, "") == 0 && type != NULL) {
      strcpy(p->type, type);
    }
  }
}

void setAsConst(char *name) {
  Element *p = listeIdfCst;
  while (p != NULL && strcmp(name, p->name) != 0)
    p = p->svt;
  if (p != NULL) {
    p->estCst = 1;
  }
}

void setAsTab(char *name) {
  Element *p = listeIdfCst;
  while (p != NULL && strcmp(name, p->name) != 0)
    p = p->svt;
  if (p != NULL) {
    p->estTab = 1;
  }
}

void setBorn(char *name, int bornInf, int bornSup) {
  Element *p = listeIdfCst;
  while (p != NULL && strcmp(name, p->name) != 0)
    p = p->svt;
  if (p != NULL) {
    p->bornInf = bornInf;
    p->bornSup = bornSup;
  }
}

/*verifTableau*/
int verifTableau(char *name, int indice) {
  Element *p = listeIdfCst;
  while (p != NULL && strcmp(name, p->name) != 0)
    p = p->svt;
  if (p != NULL) {
    if (p->taille == 0)
      return 1; // n'est pas un tableau
    if (indice > p->bornSup || indice < p->bornInf)
      return 2; // indice errone
    return 0; // acces correcte 
  } else {
    // cas identifiant ne se trouve pas dans la table des idf : impossible car l'analyse lexical l'ajoute deja
    return 1;
  }
}

char *extraireName(char *s) {
  int len = strlen(s), i;
  char *name = (char*)malloc(sizeof(char) * 20);
  for (i = 0; i <= len - 1 && s[i] != '['; i++)
    name[i] = s[i];
  name[i] = '\0';
  return name;
}

Element extraireElement(char *name) {
  Element *p = listeIdfCst;
  while (p != NULL && strcmp(name, p->name) != 0)
    p = p->svt;
  if (p != NULL) {
    return *p;
  }
}

void quadr(char *opr, char *op1, char *op2, char *res) {
  Qdr *p = NULL;
  if (listeQdr == NULL) {
    listeQdr = (Qdr*) malloc(sizeof(Qdr));
    p = listeQdr;
    p->svt = NULL;
  } else {
    p = listeQdr;
    while (p->svt != NULL)
      p = p->svt;
    p->svt = (Qdr*) malloc(sizeof(Qdr));
    p = p->svt;
    p->svt = NULL;
  }
  p->qc = qc;
	strcpy(p->oper, opr);
	strcpy(p->op1, op1);
	strcpy(p->op2,op2);
	strcpy(p->res, res);
  qc++;
}

void ajour_quad(int num_quad, int colon_quad, char *val) {
  Qdr *p = listeQdr;
  while (p != NULL && p->qc != num_quad)
    p = p->svt;
  if (p != NULL) {
    if (colon_quad==0) strcpy(p->oper, val);
    else if (colon_quad==1) strcpy(p->op1, val);
    else if (colon_quad==2) strcpy(p->op2, val);
    else if (colon_quad==3) strcpy(p->res, val);
  }
}

void afficher_qdr() {
  printf("*********************Les Quadruplets***********************\n");
  Qdr *p = listeQdr;
  while (p != NULL) {
    printf("\n %d - ( %s  ,  %s  ,  %s  ,  %s )", p->qc, p->oper, p->op1, p->op2, p->res); 
    printf("\n--------------------------------------------------------\n");
    p = p->svt;
  }
}

char chaineValideLecture(char *s) {
  int i, len = strlen(s);
  char c = 0;
  for (i = 0; i < len; i++) {
    if (s[i] != ';' && s[i] != '%' && s[i] != '#' && s[i] != '&' && s[i] != ' ') {
      return 0;
    } else if (s[i] != ' ') {
      if (c == 0)
        c = s[i];
      else
        return 0;
    }
  }
  return c;
}

int prochainFormateur(char *s) {
  int i, len = strlen(s);
  static int j = 0;
  for (i = j; i < len; i++) {
    if (s[i] == ';' || s[i] == '%' || s[i] == '#' || s[i] == '&')
      break;
  }
  if (i == len) {
    j = 0;
    return -1;
  } else {
    j = i + 1;
    return s[i];
  }
}


Pile initPile() {
	return NULL;
}

Pile empiler(Pile sommet, int x) {
	ElementPile *p = (ElementPile*)malloc(sizeof(ElementPile));
	if (p == NULL) {
		printf("erreur allocation dynamique");
		exit(EXIT_FAILURE);
	}
	p->info = x;
	p->svt = sommet;
	
	return p;
}

Pile depiler(Pile sommet, int *x) {
	ElementPile *p = sommet;
	sommet = sommet->svt;
	*x = p->info;
	free(p);
	
	return sommet;
}

int sommetPile(Pile sommet) {
	return sommet->info;
}

int pileVide(Pile sommet) {
	if (sommet == NULL)
		return 1; 
	else
		return 0;
}
