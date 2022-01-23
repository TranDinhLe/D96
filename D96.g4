//1912267
grammar D96;

@lexer::header {
from lexererr import *
}

options {
	language = Python3;
}

program: mptype 'main' LB RB LP body? RP EOF;

mptype: INTTYPE | VOIDTYPE;

body: funcall SEMI;

exp: funcall | exp0 | typlit;

funcall: ID LB exp? RB;

cls: CLS ID (COLON ID)? LP mems RP;

mems: mem mems | mem;

mem: att | met;

attlist: att attlist | att;

explist: exp COMMA explist | exp;

idlist: ID COMMA idlist | ID;

paramdecl: idlist COLON typ;

paramlist: paramdecl SEMI paramlist | paramdecl;

attdecl: (VAL | VAR) attlist COLON typ (ASSIGNOP explist)? SEMI;

vcdecl: (VAL | VAR) attlist COLON typ (ASSIGNOP explist)? SEMI;

metdecl: ID | INS paramlist? blockstmt;

arrdecl: ARR LSB (typ | ARR) COMMA [1-9][_0-9]* RSB;

clsdecl: typ ID; 

objcrt: NEW ID LB (explist)? RB;

//Array ??type
idarr: ARR LB explist RB;
idarrlist: idarr COMMA idarrlist | idarr;
multidarr: ARR LB idarrlist RB;

//Expressions
exp0: ;  
//BoolExp
bexp: bexp NOT bexp | bexp AND bexp | bexp OR bexp | bexp EQ bexp | bexp NEQ bexp | BOOLLIT;
//IntExp
iexp: SUB iexp | iexp ADD iexp | iexp SUB iexp | iexp MUL iexp | iexp DIV iexp | iexp PER iexp | iexp EQ iexp | iexp NEQ iexp | iexp MORE iexp | iexp MEQ iexp | iexp LESS iexp | iexp LEQ iexp;
//FloatExp
fexp: SUB fexp | fexp ADD fexp | fexp SUB fexp | fexp MUL fexp | fexp DIV fexp | fexp MORE fexp | fexp MEQ fexp | fexp LESS fexp | fexp LEQ fexp;
strexp: strexp SADD strexp | strexp SEQ strexp | STRLIT;
operand: subexp | ID | typlit;
subexp: LB exp RB;

//Statements
stmts: stmt stmts | stmt;
stmt: vcdecl | assignstmt | ifstmt | forstmt | brkstmt | contstmt | retstmt | ins_met_inv | stt_met_inv | blockstmt;
assignstmt: ID | elmtexp ASSIGNOP exp SEMI;
ifstmt: IF LB exp RB blockstmt ((elsifs)? ELSE blockstmt)?;
elsifs: elsif elsifs | elsif;
elsif: ELSEIF LB exp RB blockstmt;
forstmt: FE LB ID IN exp DOT DOT exp (BY exp)? RB blockstmt;
brkstmt: BRK SEMI;
contstmt: CONT SEMI;
retstmt: RET (exp)? SEMI;
blockstmt: LP stmts? RP;

//Index Operators
elmtexp: exp idop;
idop: LSB exp RSB idop | LSB exp RSB;

//Member access
ins_att_a: exp DOT ID;
stt_att_a: exp COLON COLON ID;
ins_met_inv: exp DOT ID LB explist? RB;
stt_met_inv: exp COLON COLON ID LB explist? RB;

//Self
SELFTYPE: 'Self';

//Type
typ: INTTYPE | FLOATTYPE | BOOLTYPE | STRTYPE;
typlit: INTLIT | FLOATLIT | BOOLLIT | STRLIT;

//Comment
cmt: CMT (~(CMT | EOF))* CMT;

//Keywords
BRK: 'Break';
CONT: 'Continue';
IF: 'If';
ELSEIF: 'Elseif';
ELSE: 'Else';
FE: 'Foreach';
ARR: 'Array';
IN: 'In';
INTTYPE: 'Int';
VOIDTYPE: 'Null';
FLOATTYPE: 'Float';
BOOLTYPE: 'Boolean';
STRTYPE: 'String';
RET: 'Return';
VAL: 'Val';
VAR: 'Var';
CLS: 'class';
CONS: 'Constructor';
DEST: 'Destructor';
NEW: 'New';
BY: 'By';

//Operators
ADD: '+';
SUB: '-';
MUL: '*';
DIV: '/';
PER: '%';
NOT: '!';
AND: '&&';
OR: '||';
EQ: '==';
ASSIGNOP: '=';
NEQ: '!=';
LESS: '<';
LEQ: '<=';
MORE: '>';
MEQ: '>=';
SADD: '+.';
SEQ: '==.';

DOLID: '$'[_a-zA-Z0-9]+;

ID: [_a-zA-Z][_a-zA-Z0-9]*;

//Literals
fragment OCT: '0'[_0-9]+;
fragment HEX: '0'[xX][_0-9A-F]+;
fragment BIN: '0'[bB]][_01]+;
fragment DEC: '0' | [1-9][_0-9]*;
INTLIT: DEC | BIN | OCT | HEX { self.text = self.text.replace("_","") };
fragment EXPPART: [eE][+-]? DEC;
FLOATLIT: DEC DOT EXPPART;
BOOLLIT: 'True' | 'False';
fragment CHAR: ('\'"' | ~'"') | ESCSQ;
fragment ESCSQ: '\\'[bfrnt'\];
STRLIT: '"'CHAR*'"';

//Seperators
LB: '(';
RB: ')';
LP: '{';
RP: '}';
LSB: '[';
RSB: ']';
SEMI: ';';
COMMA: ',';
DOT: '.';

COLON: ':';

CMT: '##';
fragment NEWLINE: '\n';
WS: [ \t\r\n\b\f]+ -> skip; // skip spaces, tabs, newlines

//

UNCLOSE_STRING: '"'CHAR* ([\r\n]| EOF){raise UncloseString(self.text.replace("\"",""))};;
ILLEGAL_ESCAPE: '"'CHAR* '\\'~[bfrnt'\]{raise IllegalEscape(self.text.replace("\"",""))};
ERROR_TOKEN: .{raise ErrorToken(self.text)};