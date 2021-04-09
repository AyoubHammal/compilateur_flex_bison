flex lexical.l;
bison -d syntaxique.y;
gcc lex.yy.c syntaxique.tab.c utils.c -lfl -ly -o prog;
.\prog input.txt;