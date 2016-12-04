gurobiname=gurobi65
gurobilibpath=$(PWD)/../../../../gurobi_expt/lib
gurobiincludepath=$(PWD)/../../../../gurobi_expt/include
gmplibpath=$(PWD)/../../../lib
gmpincludepath=$(PWD)/../../../include


gint: gint.c
	gcc -I$(gurobiincludepath) -I$(gmpincludepath) -o gint gint.c -L$(gurobilibpath) -l$(gurobiname) -L$(gmplibpath) -lgmp -g
