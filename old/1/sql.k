// Prima implementazione di Sql DENTRO K

module SQL-SYNTAX 
	
syntax Stmt ::= "CREATE DATABASE" Id ";"
				| 

syntax Stmts ::= 


endmodule

module SQL
	imports SQL-SYNTAX

	configuration 	<T color="yellow">
						<k color="green"> $PGM:Stmt </k>
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
endmodule