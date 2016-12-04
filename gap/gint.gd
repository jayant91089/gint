#############################################################################
##
##                                                   gint package
##
##  Copyright 2016,                              Jayant Apte, Drexel University
##
##  The .gd file containing global function declarations and the documentation
##  of the gint package. The documentation is written using the AutoDoc Package.
##
##
#############################################################################
#! @Chapter Introduction
#! $\texttt{gint}$ is a GAP package that provides an interface to Gurobi optimizer <Cite Key="gurobi"/>.
#! This is a minimalist package exposing the LP solver functionality of to GAP.
#! $\texttt{gint}$ provides a C wrapper gint.c to the Gurobi Optimizer's C API.
#! It is currently available for Unix/Linux systems running GAP $4.5+$.
#! @Chapter Installation
#!   @BeginCode pkg
GAPInfo.("RootPaths");
#!   @EndCode
#! Assuming you already have GAP 4.5+ installed, you can follow the step-by-step ProcedureToNormalizeGenerators
#! mentioned in the README.md file that comes with this package. Then, to start using the package, invioke the following
#! @BeginCode Read
 LoadPackage( "gint");
 #! @EndCode
#! @InsertCode Read
#! from within GAP.
#! @Chapter Usage
#! @Section Available functions
#!  In this section we shall look at the functions provided by gint. $\texttt{gint}$ allows
#! GAP to communicate with external LP solver process via a stream object of category IsInputOutputStream(). This stream serves as a
#! handle via which one can load/solve/modify linear programs. Note that it is possible to maintain several such steams (and hence LPs)
#! at any given time. However, the gap commands to solve/modify these LPs that currently available in this package are blocking functions.
#! Note that Gurobi is a floating-point solver. All matrices and lists to be passed to and returned by the functions of this package are assumed to containing
#! rational numbers. Internally, they are converted to double precision floats using the Gnu Multiple Precision (GMP) library <Cite Key="Granlund12"/>.
#! @Description
#! This function loads an LP by invoking external Gurobi LP solver process.
#! It accepts following arguments:
#! * $obj$ - Objective function coefficients, provided as a list
#! * $A$ - A list of lists corresponding to constraints
#! * $b$ - Right hand side of constraints
#! * $linrows$ - A list of indices of members of $A$ that are equalities
#! * $gint\_exec$ - A string describing complete path to 'gint' executable (including 'gint')
#! Returns a list $[s,rval]$ where 's' is a gap object of category IsInputOutputStream() and 'rval'
#! $=$zero/non-zero indicates success/failure. If 'rval=0', 's' is ready to be be used to solve linear programs.
#! @Returns A list
#! @Arguments obj,A,b,linrows,gint_exec,optargs
DeclareGlobalFunction("LoadGRBLP");
#! @Description
#! This function loads a new objective.
#! It accepts following arguments:
#! * $s$ - gap object of category IsInputOutputStream(), handle to an already loaded LP
#! * $obj$ - Objective function coefficients, provided as a list
#! Returns an integer 'rval' $=$zero/non-zero that indicate success/failure. If 'rval=0',
#! the LP associated with 's' is successfully modified.
#! @Returns An integer
#! @Arguments s,obj
DeclareGlobalFunction("LoadGRBLPobj");
#! @Description
#! This function loads an LP by invoking external qsopt-exact LP solver process.
#! It accepts following arguments:
#! * $s$ - gap object of category IsInputOutputStream(), handle to an already loaded LP
#! * $optargs$ - A list of optional arguments. Currently supports only one optional argument, which is an integer
#!   specifying the algorithm to use: -$1=$automatic, $0=$primal simplex, $1=$dual simplex, $2=$barrier, $3=$concurrent, $4=$deterministic concurrent
#! Returns an integer $status$ that is the integer value of the Status attribute associated with the Gurobi model.
#! @Returns An integer
#! @Arguments s,optargs
DeclareGlobalFunction("SolveGRBLP");
#! @Description
#! This function terminates the external processes associated with given LP handle.
#! It accepts following arguments:
#! * $s$ - gap object of category IsInputOutputStream(), handle to an already loaded LP
#! Returns Nothing
#! @Returns
#! @Arguments s
DeclareGlobalFunction("FlushGRBLP");
#! @Description
#! This function obtains the primal solution along with the associated vertex, for the most recently solved LP.
#! It accepts following arguments:
#! * $s$ - gap object of category IsInputOutputStream(), handle to an already loaded LP
#! Returns A list $[status,val\_rval,val,x\_rval,x]$ if optimal solution exists and a list $[status]$ otherwise. If $status=2$,
#! $val\_rval$ and $x\_rval$ indicate validity of $val$ and $x$ (valid if $0$ and invalid otherwise) which are optimal solution
#! and (primal) vertex achieving the optimal solution respectively. Other status values correspond to the integer value of the Status attribute associated with the Gurobi model.
#! @Returns A list
#! @Arguments s
DeclareGlobalFunction("GetGRBLPsol_primal");
#! @Description
#! This function obtains the dual solution along with the associated vertex, for the most recently solved LP.
#! It accepts following arguments:
#! * $s$ - gap object of category IsInputOutputStream(), handle to an already loaded LP
#! Returns A list $[status,val\_rval,val,x\_rval,x]$ if optimal solution exists and a list $[status]$ otherwise. If $status=2$,
#! $val\_rval$ and $x\_rval$ indicate validity of $val$ and $x$ (valid if $0$ and invalid otherwise) which are optimal solution
#! and (dual) vertex achieving the optimal solution respectively. Other status values correspond to the integer value of the Status attribute associated with the Gurobi model.
#! @Returns A list
#! @Arguments s
DeclareGlobalFunction("GetGRBLPsol_dual");
#! @Description
#! This function changes the value of single rhs coefficient in specified row.
#! It accepts following arguments:
#! * $s$ - gap object of category IsInputOutputStream(), handle to an already loaded LP
#! * $row$ - row index of the inequility whose rhs is to be changed
#! * $coef$ - new rhs coefficient
#! Returns A an integer which is itself returned by the Gurobi function to modify the rhs
#! @Returns An integer
#! @Arguments s,row,coef
DeclareGlobalFunction("ChangeGRBrhs");
#! @Description
#! This function deletes the specified row.
#! It accepts following arguments:
#! * $s$ - gap object of category IsInputOutputStream(), handle to an already loaded LP
#! * $row$ - row index of the inequality to be deleted
#! Returns A an integer which is itself returned by Gurobi function to delete a constraint
#! @Returns An integer
#! @Arguments s,row
DeclareGlobalFunction("DelGRBrow");
#! @Description
#! This function changes the sense (equality or inequality) of a particular row.
#! It accepts following arguments:
#! * $s$ - gap object of category IsInputOutputStream(), handle to an already loaded LP
#! * $row$ - row index of the inequility whose sense is to be changed
#! * $newsense$ - A single character string describing the new sense, "L" for $\leq$ and "E" for $=$
#! Returns A an integer which is itself returned by Gurobi function to change the sense of a constraint
#! @Returns An integer
#! @Arguments s,row,coef
DeclareGlobalFunction("ChangeGRBsense");
#! @Description
#! This function changes a particular coefficient in the constraint matrix.
#! It accepts following arguments:
#! * $s$ - gap object of category IsInputOutputStream(), handle to an already loaded LP
#! * $row$ - row index of the inequility to which the coefficient to be changed belongs
#! * $col$ - column index of the inequility whose sense is to be changed
#! * $coef$ - A rational number or an integer
#! Returns A an integer which is itself returned by QSopt$\_$ex function $\texttt{mpq}\_\texttt{QSchange}\_\texttt{sense}$
#! @Returns An integer
#! @Arguments s,row,coef
DeclareGlobalFunction("ChangeGRBcoef");

DeclareGlobalFunction("qsoptformatstr");
DeclareGlobalFunction("qsoptformatstr2");
