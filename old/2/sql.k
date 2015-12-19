// Prima implementazione di Sql DENTRO K

//sintassi
module SQL-SYNTAX 
	
//comandi SQL
syntax Stmt ::=	"CREATE DATABASE" Id ";"
			|	"CREATE TABLE" Id "(" Attributes ")" ";"

//comandi di supporto utilizzati solo da K 
syntax Command ::=	"ADD SCHEMA" Id "(" Attributes ")" ";"

syntax Type ::=	"VARCHAR"
			|	"SMALLINT"

syntax Attribute ::= 	Id Type	

syntax Attributes ::= 	List{Attribute,","}

syntax Stmts ::= 	Stmt
				|	Stmt Stmts


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

//crea il database
rule <k> CREATE DATABASE N:Id ; => .K ... </k>
	<database-name> .Set => SetItem(N) </database-name>

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

endmodule