// Core di SQL in K

//sintassi
module SQL-SYNTAX 
	
// ------ comandi SQL ------ //
syntax Stmt ::=	"CREATE DATABASE" Id ";"
			|	"CREATE TABLE" Id "(" Attributes ")" ";"
			|	"ALTER TABLE" Id AlterCommands ";"
			|	"DROP TABLE" Tables ";"
			|	"INSERT INTO" Id "(" Columns ")" "VALUES" "(" Values ")" ";"
			|	"UPDATE" Id "SET" Substitutions ";"
			|	"UPDATE" Id "SET" Substitutions "WHERE" Conditions ";"


syntax Stmts ::= 	Stmt
				|	Stmt Stmts

// ------ tipi SQL ------ //
syntax Type ::=	"VARCHAR"
			|	"VARCHAR" "(" Int ")"
			|	"SMALLINT"

// ------ comandi e tipi di supporto utilizzati solo da K ------ //
syntax Command ::=	"ADD SCHEMA" Id "(" Attributes ")" ";"
				|	"SAVE KEY" Id "(" Columns ")" "VALUES" "(" Values ")" ";"

syntax Attribute ::= 	Id Type	
					|	Id Type	"PRIMARY KEY"

syntax Attributes ::= 	List{Attribute,","}
	
syntax Columns ::= 	List{Id,","}

syntax Value ::=	Int
				|	"'" String "'"
				|	"null"

syntax Values ::=	List{Value,","}

syntax Add ::=	"ADD"	
			|	"ADD COLUMN"

syntax AddAttribute ::=	Add Attribute

syntax AddAttributes ::=	List{AddAttribute,","}

syntax Drop ::=	"DROP"	
			|	"DROP COLUMN"
			|	"DROP IF EXISTS" 
			|	"DROP COLUMN IF EXISTS"

syntax DropAttribute ::=	Drop Id

syntax DropAttributes ::= 	List{DropAttribute,","}

syntax RenameColumnAttribute ::= "RENAME COLUMN" Id "TO" Id

syntax RenameColumnAttributes ::= List{RenameColumnAttribute,","}

syntax Tables ::= 	List{Id,","}

syntax RenameTable ::=	"RENAME TO" Id

syntax Exp ::= Int | Bool | String | Id
               | "(" Exp ")"             [bracket]
               | "-" Exp                 [strict]
               > left:
                 Exp "*" Exp             [strict, left]
               | Exp "/" Exp             [strict, left]
               > left:
                 Exp "+" Exp             [strict, left]
               | Exp "-" Exp             [strict, left]
               > left:
                 Exp "AND" Exp            [strict(1), left]
               | Exp "OR" Exp            [strict(1), left]

syntax Exps ::= List{Exp,","}          [strict]

//sostituzioni dell'update
syntax Substitution ::=	Id "=" "null"
					|	Id "=" Exp
					|	Id "=" "'" String "'"
					|	Id "=" "'" Int "'"

syntax Substitutions ::=	List{Substitution,","}

//condini per l'update
syntax Condition ::=	Id "=" "'" String "'"
					|	Id "=" "'" Int "'"
					|	Id "=" Exp

syntax Conditions ::=	Condition
					|	Conditions AndOr Conditions

syntax AndOr ::=	"AND"
				|	"OR" 

//L'idea è di avere un comando tipo: ALTER TABLE Id AlterCommands
syntax AlterCommand ::=	AddAttribute
					|	DropAttribute
					|	RenameColumnAttribute
					|	RenameTable

syntax AlterCommands ::=	List{AlterCommand,","}


endmodule

//semantica
module SQL
	imports SQL-SYNTAX

	configuration 	<T color="yellow">
						<k color="green"> $PGM:Stmts </k>
						<database color="orange">
							<database-name color="blue"> .Set </database-name>
							<tables color="LightSkyBlue">
								<table multiplicity="*" color="red"> 
									<table-name color="blue"> .Set </table-name>
									<schema color="Orchid"> .Map </schema>
									<key color="purple"> .Set </key>
									<keyvalues> .Set </keyvalues>
									<numvalues> #counter </numvalues>
									<values multiplicity="*" color="gray">
										<value color="black"> 
											<numvalue> #counter </numvalue>
											<val> .Map </val> 
										</value>
									</values>
								</table>
							</tables> 
						</database>
						<count> #counter </count>
				  	</T>

//valuta il primo comando poi il secondo gruppo di comandi
rule S1:Stmt S2:Stmts => S1 ~> S2

// ------ CREATE DATABASE  ------- //
//crea il database
rule <k> CREATE DATABASE N:Id ; => .K ... </k>
	<database-name> .Set => SetItem(N) </database-name>
	<count> J:Int => 0 </count>

// ------ CREATE TABLE  ------- //
//crea la tabella senza attributi
rule <k> CREATE TABLE N:Id (A:Attributes) ; => ADD SCHEMA N ( A ) ; ... </k>
       ( . => <table>...
               	<table-name> SetItem(N) </table-name>
               	<schema> .Map </schema>
               	<key> .Set </key>
               	<numvalues> 0 </numvalues>
               	<values>
					.Bag
				 </values>
         ... </table> )

//comando di supporto: aggiunge gli attributi alla tabella
rule <k> ADD SCHEMA N:Id ( X:Id T:Type , A:Attributes => A) ; ... </k>
	<table-name> SetItem(N) </table-name>
	<schema> M:Map => M[X <- T] </schema>

rule <k> ADD SCHEMA N:Id ( X:Id T:Type PRIMARY KEY , A:Attributes => A) ; ... </k>
	<table-name> SetItem(N) </table-name>
	<schema> M:Map => M[X <- T] </schema>
	<key> .Set => SetItem(X) </key>

//se gli attributi sono finiti consuma il comando( lo rimpiazza con .K cioè il comando vuoto di tipo K )
rule <k> ADD SCHEMA N:Id ( .Attributes ) ; => .K ... </k>

// ------ ALTER TABLE ADD o ADD COLUMN  ------- //
//aggiunge gli attributi alla tabella
rule <k> ALTER TABLE N:Id ( Add X:Id T:Type , A:AddAttributes => A ); ... </k>
	<table-name> SetItem(N) </table-name>
	<schema> M:Map => M[X <- T] </schema>

//se l'attributo è uno solo consuma il comando e aggiunge l'attributo
rule <k> ( ALTER TABLE N:Id Add X:Id T:Type ; ) => .K ... </k>
	<table-name> SetItem(N) </table-name>
	<schema> M:Map => M[X <- T] </schema>

rule <k> ALTER TABLE  N:Id .AddAttributes ; => .K ... </k>

// ------ ALTER TABLE DROP o DROP COLUMN o DROP IF EXISTS o DROP COLUMN IF EXISTS ------- //
//elimina la colonna o le colonne in questione
rule <k> ALTER TABLE N:Id Drop X:Id , D:DropAttributes => D ; ... </k>
	<table-name> SetItem(N) </table-name>
	<schema> M:Map X |-> _ => M </schema>

rule <k> ( ALTER TABLE N:Id Drop X:Id ; ) => .K ... </k>
	<table-name> SetItem(N) </table-name>
	<schema> M:Map X |-> _ => M </schema>

rule <k> ALTER TABLE  N:Id .DropAttributes ; => .K ... </k>

// ------ ALTER TABLE RENAME COLUMN ------- //
//rinomina la colonna in questione
rule <k> ALTER TABLE N:Id RENAME COLUMN X:Id TO B:Id ; => .K ... </k>
	<table-name> SetItem(N) </table-name>
	<schema> M:Map X |-> T:Type => M[B <- T] </schema>

// ------ ALTER TABLE RENAME TABLE ------- //
rule <k> ALTER TABLE N:Id RENAME TO X:Id ; => .K ... </k>
	<table-name> SetItem(N) => SetItem(X) </table-name>

// ------ DROP TABLE ------- // 
//elimina la tabella o le tabelle in questione
rule <k> DROP TABLE N:Id , T:Tables => T ; ... </k>
	( <table>...
               <table-name> SetItem(N) </table-name>
         ... </table> => . )

rule <k> DROP TABLE N:Id ; => .K ... </k>
	( <table>...
               <table-name> SetItem(N) </table-name>
         ... </table> => . )
//(lista vuota)
rule <k> DROP TABLE .Tables ; => .K ... </k>

// ------ INSERT INTO ------- // 
rule <k> INSERT INTO N:Id ( C:Columns ) VALUES ( V:Values ) ; => SAVE KEY N:Id ( C:Columns ) VALUES ( V:Values ) ; ... </k>	
		<table-name> SetItem(N) </table-name>
		<schema> M:Map </schema>
		<key> Z:Set </key>
		<keyvalues> S:Set </keyvalues>
		<numvalues> L:Int => L +Int 1 </numvalues>
			<values> ...

				( . => <value> ...
							<numvalue> inc(L) </numvalue>
							<val> insertValues( C , V , M ) </val>
						... </value> )
				
			... </values>
		when (size(C) ==Int size(V) andBool charControl(M,C,V) andBool checkKey(C,Z,V,S))

//salva i valori della primary key in un set
rule <k> SAVE KEY N:Id ( C:Id , G:Columns ) VALUES ( V:Value , W:Values ) ; => SAVE KEY N ( G ) VALUES ( W ) ; ... </k>	
		<table-name> SetItem(N) </table-name>
		<key> Z:Set </key>
		<keyvalues> S:Set => S SetItem(V) </keyvalues>
		when ( C in Z ) //solo quando C è chiave

//se non è una primary key va avanti a controllare senza fare nulla
rule <k> SAVE KEY N:Id ( C:Id , G:Columns ) VALUES ( V:Value , W:Values ) ; => SAVE KEY N ( G ) VALUES ( W ) ; ... </k>	
		<table-name> SetItem(N) </table-name>
		<key> Z:Set </key>
		when notBool( C in Z ) //solo quando C non è chiave

rule <k> SAVE KEY N:Id ( .Columns ) VALUES ( .Values ) ; => .K ... </k>	

// ------ UPDATE ------- //
//update semplice per interi
rule <k> UPDATE N:Id SET I:Id = ' S:Int ' ; => UPDATE N:Id SET I:Id = ' S:Int ' ; ... </k>		
		<table-name> SetItem(N) </table-name>
		<numvalues> X:Int </numvalues>
		<values> ...

			<value> 
				<numvalue> L:Int </numvalue>
				<val> M:Map => updateMap( M , I |-> S ) </val>	//recupera il valore data la chiave e lo aggiorna
			</value>

		... </values>
		<count> J:Int => J +Int 1 </count>
		when ( inc(J) ==Int L andBool J <=Int X )	//solo quando ci sono ancora value

//update semplice per stringhe
rule <k> UPDATE N:Id SET I:Id = ' S:String ' ; => UPDATE N:Id SET I:Id = ' S:String ' ; ... </k>		
		<table-name> SetItem(N) </table-name>
		<numvalues> X:Int </numvalues>
		<values> ...

			<value> 
				<numvalue> L:Int </numvalue>
				<val> M:Map => updateMap( M , I |-> S ) </val>	//recupera il valore data la chiave e lo aggiorna
			</value>

		... </values>
		<count> J:Int => J +Int 1 </count>
		when ( inc(J) ==Int L andBool J <=Int X )	//solo quando ci sono ancora value

rule <k> UPDATE N:Id SET _ ; => .K ... </k>	
		<table-name> SetItem(N) </table-name>
		<numvalues> L:Int </numvalues>
		<count> J:Int => 0 </count>	//azzera il contatore
		when ( inc(J) >Int L )	//solo quando non ci sono piu value



/*
rule <k> UPDATE N:Id SET ( I:Id = ' S:Int ' , Z:Substitutions => Z ) ; ... </k>		
		<table-name> SetItem(N) </table-name>
		<values> ...
		
			 <value> M:Map[ I ] => updateMap( M , I |-> S ) </value> //recupero il valore data la chiave e lo aggiorno??
			
			//come identifico le mappe? devo ciclare sulle mappe in qualche modo 
			// e chiamare una funzione che controlla la condizione su tutte le mappe 
			//  e sostituisce i valori sempre su tutte le mappe!
		... </values>

rule <k> UPDATE N:Id SET ( .Substitutions ) ; => .K ... </k>	
*/
rule <k> UPDATE N:Id SET ( S:Substitution , Z:Substitutions ) WHERE ( C:Conditions ) ; => UPDATE N:Id SET ( Z ) WHERE ( C ) ; ... </k>		
		<table-name> SetItem(N) </table-name>
		<schema> M:Map </schema>
		<values> ...
			Bag
			//<value> Map /* updateValues(B,S,C) */ </value>
			//come identifico le mappe? devo ciclare sulle mappe in qualche modo 
			// e chiamare una funzione che controlla la condizione su tutte le mappe 
			//  e sostituisce i valori sempre su tutte le mappe!
		... </values> 
/*

syntax Substitution ::=	Id "=" "null"
					|	Id "=" Exp
					|	Id "=" "'" String "'"
					|	Id "=" "'" Int "'"

syntax Substitutions ::=	List{Substitution,","}

syntax Condition ::=	Id "=" "'" String "'"
					|	Id "=" "'" Int "'"
					|	Id "=" Exp

syntax Conditions ::=	Condition
					|	Conditions AndOr Conditions

syntax AndOr ::=	"AND"
				|	"OR" 

*/

// ------ FUNZIONI ------ //
//inserisce i valori nella tupla (null se non viene specificato il valore per qualche attributo)
syntax Map ::= "insertValues" "(" Columns "," Values "," Map ")"    [function]
rule insertValues ( C:Id , S:Columns , V:Value , W:Values , M:Map) => C |-> V insertValues( S , W , M -Map (C |-> (M[C])))
rule insertValues( .Columns , .Values , (X:Id |-> T:Type) M:Map) => X |-> null insertValues( .Columns , .Values , M )
rule insertValues( .Columns , .Values , .Map) => .Map

//controlla che la stringa inserita sia entro la lunghezza definita in CREATE TABLE
syntax Bool ::= "charControl" "(" Map "," Columns "," Values ")"	[function]
rule charControl( M:Map , I:Id , C:Columns , ' S:String ' , V:Values ) => #if ( control( S , M[I]) ) #then ( charControl( M , C , V ) ) #else false #fi
rule charControl( M:Map , I:Id , C:Columns ,  S:Int , V:Values ) => charControl( M , C , V )
rule charControl( _ , .Columns , .Values ) => true

//funzione di supporto alla funzione charControl() che controlla effettivamente se la stringa inserita è accettabile
syntax Bool ::= "control" "(" String "," Type ")"	[function]
rule control( S:String , VARCHAR ( I:Int )) => true
		when ( I >=Int lengthString(S) )
rule control( S:String , VARCHAR ) => true

//controlla che si faccia l'inserimento dell'attributo chiave se esiste una primary key nella tabella
syntax Bool ::=	"checkKey" "(" Columns "," Set "," Values "," Set ")"	[function]
rule checkKey( C:Id , G:Columns , Z:Set , V:Value , W:Values , S:Set ) => #if ( (C in Z) orBool (Z ==K .Set) ) #then ( isNotAlreadyIn( C , V , S ) ) #else ( checkKey( G , Z , W , S ) ) #fi
rule checkKey( C:Columns, .Set , _ , _ , _ ) => true	//se la primary key non esiste nella tabella va bene

//controlla se la chiave inserita esiste gia
syntax Bool ::=	"isNotAlreadyIn" "(" Id "," Value "," Set ")"	[function]
rule isNotAlreadyIn( C:Id , V:Value , S:Set ) => #if ( V in S ) #then ( false ) #else ( true ) #fi

//calcola la dimensione della lista di colonne
syntax Int ::= "size" "(" Columns ")"	[function]
rule size( C:Id , S:Columns ) => 1 +Int size(S)
rule size(.Columns) => 0

//calcola la dimensione della lista di valori
syntax Int ::= "size" "(" Values ")"	[function]
rule size(V:Value , W:Values) => 1 +Int size(W)
rule size(.Values) => 0

//calcola la dimensione del bag
syntax Int ::= "size" "(" Bag ")"   [function]
rule size(BagItem(_) B:Bag) => 1 +Int size(B)
rule size(.Bag) => 0

//verifica se l'elemento K è nel bag
syntax Bool ::= K "in" Bag    [function]
rule K1 in BagItem(K2) B:Bag => (K1 =K K2) orBool (K1 in B)
rule _ in .Bag => false

//incrementa una variabile intera
syntax Int ::= "inc" "(" Int ")"	[function]
rule inc( I:Int ) => I +Int 1

//decrementa una variabile intera
syntax Int ::= "dec" "(" Int ")"	[function]
rule dec( I:Int ) => I +Int 1

endmodule



















