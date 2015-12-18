// Prima implementazione di Sql DENTRO K

module SQL-SYNTAX 
	
syntax Stmt ::=	"CREATE DATABASE" Id ";"
			|	"CREATE TABLE" Id "(" Attributes ")" ";"

syntax Type ::=	"VARCHAR"
			|	"SMALLINT"

syntax Attribute ::= 	Id Type	

syntax Attributes ::= 	List{Attribute,","}

syntax Stmts ::= 	Stmt
				|	Stmt Stmts


endmodule

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

rule <k> CREATE DATABASE X:Id ; => .K ... </k>
	<database-name> .Set => SetItem(X) </database-name>

rule S1:Stmt S2:Stmts => S1 ~> S2 //valuta il primo poi il secondo

rule <k> CREATE TABLE N:Id ( X:Id T:Type, A1:Attributes => A1) ; ... </k>
       (. => <table>...
               <table-name> SetItem(N) </table-name>
               <schema> .Map </schema>
         ... </table>) 

rule <k> CREATE TABLE N ( X:Id T:Type, A1:Attributes => A1) ; => .K ... </k>
		<table-name> SetItem(N) </table-name>

rule <k> CREATE TABLE N ( X:Id T:Type, A1:Attributes => A1) ; => .K ... </k>
		<table-name> SetItem(N) </table-name>
		<schema> M:Map => M[X / T] </schema>

// rule <k> CREATE TABLE N ( .Attributes ) ; => .K ... </k>

endmodule