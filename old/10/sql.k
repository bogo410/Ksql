// Prima implementazione di Sql DENTRO K

//sintassi
module SQL-SYNTAX 
	
// ------ comandi SQL ------ //
syntax Stmt ::=	"CREATE DATABASE" Id ";"
			|	"CREATE TABLE" Id "(" Attributes ")" ";"
			|	"ALTER TABLE" Id AlterCommands ";"
			|	"DROP TABLE" Tables ";"
			|	"INSERT INTO" Id "(" Columns ")" "VALUES" "(" Values ")" ";"
			|	"UPDATE" Id "SET" Substitutions "WHERE" Conditions ";"	//aggiunto da qui(per l'UPDATE) 


syntax Stmts ::= 	Stmt
				|	Stmt Stmts

// ------ tipi SQL ------ //
syntax Type ::=	"VARCHAR"
			|	"VARCHAR" "(" Int ")"	//aggiunto da qui(per il campo del VARCHAR) 
			|	"SMALLINT"

// ------ comandi e tipi di supporto utilizzati solo da K ------ //
syntax Command ::=	"ADD SCHEMA" Id "(" Attributes ")" ";"

syntax Attribute ::= 	Id Type	

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

//aggiunto da qui(per l'UPDATE) 
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

syntax Substitution ::=	Id "=" Id
					|	Id "=" Exp
					|	Id "=" "'" String "'"
					|	Id "=" "'" Int "'"

syntax Substitutions ::=	List{Substitution,","}

syntax Condition ::=	Id "=" "'" String "'"
					|	Id "=" "'" Int "'"
					|	Id "=" Exp

syntax Conditions ::=	Condition
					|	Conditions "AND" Conditions
					|	Conditions "OR" Conditions
//a qui(per l'UPDATE) 

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
									<values multiplicity="*" color="gray">
										<value color="black"> .Map </value>
									</values>
								</table>
							</tables> 
						</database> 
				  	</T>

//valuta il primo comando poi il secondo gruppo di comandi
rule S1:Stmt S2:Stmts => S1 ~> S2

// ------ CREATE DATABASE  ------- //
//crea il database
rule <k> CREATE DATABASE N:Id ; => .K ... </k>
	<database-name> .Set => SetItem(N) </database-name>

// ------ CREATE TABLE  ------- //
//crea la tabella senza attributi
rule <k> CREATE TABLE N:Id (A:Attributes) ; => ADD SCHEMA N ( A ) ; ... </k>
       ( . => <table>...
               	<table-name> SetItem(N) </table-name>
               	<schema> .Map </schema>
               	<values>
					.Bag
				 </values>
         ... </table> )

//comando di supporto: aggiunge gli attributi alla tabella
rule <k> ADD SCHEMA N:Id ( X:Id T:Type , A:Attributes => A) ; ... </k>
	<table-name> SetItem(N) </table-name>
	<schema> M:Map => M[X <- T] </schema>

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
rule <k> INSERT INTO N:Id ( C:Columns ) VALUES ( V:Values ) ; => .K ... </k>	
		<table-name> SetItem(N) </table-name>
		<schema> M:Map </schema>
			<values>...	
				. => <value> insertValues( C , V , M ) </value>
			... </values> 
		when (size(C) ==Int size(V) andBool charControl(M,C,V))

// ------ FUNZIONI ------ //
//inserisce i valori nella tupla (null se non viene specificato il valore per qualche attributo)
syntax Map ::= "insertValues" "(" Columns "," Values "," Map ")"    [function]
rule insertValues ( C:Id , S:Columns , V:Value , W:Values , M:Map) => C |-> V insertValues( S , W , M -Map (C |-> (M[C])))
rule insertValues( .Columns , .Values , (X:Id |-> T:Type) M:Map) => X |-> null insertValues( .Columns , .Values , M )
rule insertValues( .Columns , .Values , .Map) => .Map

//calcola la dimensione della lista di colonne
syntax Int ::= "size" "(" Columns ")"	[function]
rule size( C:Id , S:Columns ) => 1 +Int size(S)
rule size(.Columns) => 0

//calcola la dimensione della lista di valori
syntax Int ::= "size" "(" Values ")"	[function]
rule size(V:Value , W:Values) => 1 +Int size(W)
rule size(.Values) => 0

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


endmodule



















