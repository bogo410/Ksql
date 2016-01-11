// Prima implementazione di Sql DENTRO K

//sintassi
module SQL-SYNTAX 
	
// ------ comandi SQL ------ //
syntax Stmt ::=	"CREATE DATABASE" Id ";"
			|	"CREATE TABLE" Id "(" Attributes ")" ";"
			|	"ALTER TABLE" Id AlterCommands ";"

/*			|	"ALTER TABLE" Id AddAttributes ";"
			|	"ALTER TABLE" Id DropAttributes ";"
	//Da verificare
			|	"ALTER TABLE" Id RenameTable ";"
			|	"ALTER TABLE" Id RenameColumnAttributes ";"
*/
			|	"DROP TABLE" Tables ";"

syntax Stmts ::= 	Stmt
				|	Stmt Stmts

// ------ tipi SQL ------ //
syntax Type ::=	"VARCHAR"
			|	"SMALLINT"

// ------ comandi e tipi di supporto utilizzati solo da K ------ //
syntax Command ::=	"ADD SCHEMA" Id "(" Attributes ")" ";"

syntax Attribute ::= 	Id Type	
syntax Attributes ::= 	List{Attribute,","}

syntax Add ::=	"ADD"	
			|	"ADD COLUMN"
syntax AddAttribute ::=		Add Attribute
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

//PROVA: l'idea è di avere un comando tipo: ALTER TABLE Id AlterCommands
syntax AlterCommand ::=	AddAttribute
					|	DropAttribute
					|	RenameColumnAttribute
					|	RenameTable
syntax AlterCommands ::=	List{AlterCommand,","}

//syntax OpCodes ::= "ADD" Id | "ADD COLUMN" Id | "DROP COLUMN" Id | "RENAME TO" Id | "RENAME COLUMN" Id "TO" Id
//syntax OpCodess ::= List{OpCodes,","}
//non so se questo sopra è giusto ma per poter fare un uso casuale di queste queary dobbiamo unirle tutte
//un uso simile lo ho trovato nel file /K/samples/wcet/wcet.k (su dropbox)

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
               <values> .Bag </values>
         ... </table> )

//comando di supporto: aggiunge gli attributi alla tabella
rule <k> ADD SCHEMA N:Id ( X:Id T:Type , A:Attributes => A) ; ... </k>
	<table-name> SetItem(N) </table-name>
	<schema> M:Map => M[T / X] </schema>

//se gli attributi sono finiti consuma il comando( lo rimpiazza con .K cioè il comando vuoto di tipo K )
rule <k> ADD SCHEMA N:Id ( .Attributes ) ; => .K ... </k>

// ------ ALTER TABLE ADD o ADD COLUMN  ------- //
//aggiunge gli attributi alla tabella
rule <k> ALTER TABLE N:Id ( Add X:Id T:Type , A:AlterCommands => A ); ... </k>
	<table-name> SetItem(N) </table-name>
	<schema> M:Map => M[T / X] </schema> when notBool(A =/=K .K)

//se l'attributo è uno solo consuma il comando e aggiunge l'attributo
rule <k> ( ALTER TABLE N:Id Add X:Id T:Type ; ) => .K ... </k>
	<table-name> SetItem(N) </table-name>
	<schema> M:Map => M[T / X] </schema>

// ------ ALTER TABLE DROP o DROP COLUMN o DROP IF EXISTS DROP COLUMN IF EXISTS ------- //
//elimina la colonna o le colonne in questione
rule <k> ALTER TABLE N:Id ( Drop X:Id , A:AlterCommands => A ); ... </k>
	<table-name> SetItem(N) </table-name>
	<schema> M:Map X |-> _ => M </schema> when notBool(A =/=K .K)

rule <k> ( ALTER TABLE N:Id Drop X:Id ; ) => .K ... </k>
	<table-name> SetItem(N) </table-name>
	<schema> M:Map X |-> _ => M </schema>

// ------ ALTER TABLE RENAME COLUMN ------- //
rule <k> ALTER TABLE N:Id RENAME COLUMN X:Id TO B:Id , A:AlterCommands => A; ... </k>
	<table-name> SetItem(N) </table-name>
	<schema> M:Map X |-> T:Type => M[T / B] </schema> when notBool(A =/=K .K)

rule <k> ALTER TABLE N:Id RENAME COLUMN X:Id TO B:Id ; => .K ... </k>
	<table-name> SetItem(N) </table-name>
	<schema> M:Map X |-> T:Type => M[T / B] </schema>

// ------ ALTER TABLE RENAME TABLE ------- //
rule <k> ALTER TABLE N:Id RENAME TO X:Id ; => .K ... </k>
	<table-name> SetItem(N) => SetItem(X) </table-name>

// ------ DROP TABLE ------- // 											DA FARE
rule <k> DROP TABLE ( N:Id , T:Tables => T ) ; ... </k>
	<table-name> SetItem(N) </table-name>
//	<table> B:Bag => .B </table>

rule <k> DROP TABLE N:Id ; => .K ... </k>
	<table-name> SetItem(N) </table-name>
//	<table> B:Bag => .B </table>

endmodule
