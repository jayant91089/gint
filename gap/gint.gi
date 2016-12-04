################################################################################
##
##                                                 gint package
##
##  Copyright 2016,                   Jayant Apte, Drexel University
##
##  The .gi file containing implementation part of the gint package.
##
################################################################################

##
##Utility functions
if not IsBound(DeepCopy_lol) then
DeepCopy_lol:=function(lol)
  local olol,l;
  olol:=[];
  for l in lol do
  Append(olol,[ShallowCopy(l)]);
  od;
  return olol;
end;
fi;

if not IsBound(RecNamesInt) then
RecNamesInt:=function(r)
  # Returns all values in a record
  local i,intnames;
  intnames:=[];
  for i in RecNames(r) do
   Append(intnames,[Int(i)]);
  od;
  return intnames;
end;
fi;

if not IsBound(skipline) then
skipline:=function(str,i)
local j;
if i>Size(str) or i<0 then
  return -1;
fi;
for j in [i..Size(str)] do
  if str[j]='\n' then
    if j=Size(str) then
      return -1;
    else
      return j+1;
    fi;
  fi;
od;
return -1;
end;
fi;


if not IsBound(set2int) then
set2int:=function(s)
  local i,j;
  i:=0;
  for j in s do
    i:=i+2^(Int(j)-1);
  od;
  return i;
end;
fi;

if not IsBound(GenShannonBounded) then
GenShannonBounded:=function(n)
local rlist,mtx,str,i,j,shineq,nset_i,ineq,pairs,p,Klist,K,nset_ij,greq,neq,A,b,sum2one,s;
shineq:=[];
# first add H(X_i|rest)>=0 type inequalities
for i in [1..n] do
  nset_i:=[1..n];
  SubtractSet(nset_i,[i]);
  ineq:=ZeroMutable([1..2^n]);
  ineq[set2int([1..n])+1]:=1;
  ineq[set2int(nset_i)+1]:=-1;
  Append(shineq,[ineq]);
od;
# second, add I(X_i,X_j|X_K) >=0
pairs:=Combinations([1..n],2);
for p in pairs do
  nset_ij:=[1..n];
  SubtractSet(nset_ij,p);
  Klist:=Combinations(nset_ij);
  for K in Klist do
    ineq:=ZeroMutable([1..2^n]);
    ineq[set2int(Union(K,[p[1]]))+1]:=1;
    ineq[set2int(Union(K,[p[2]]))+1]:=1;
    ineq[set2int(Union(K,p))+1]:=-1;
    if Size(K)>0 then
      ineq[set2int(K)+1]:=-1;
    fi;
    Append(shineq,[ineq]);
  od;
od;
shineq:=-shineq;
sum2one:=ZeroMutable([1..2^n-1]);
for i in [1..2^n-1] do
sum2one[i]:=1;
od;
A:=[];
b:=[];
for s in shineq do
  Append(A,[s{[2..Size(s)]}]);
  Append(b,[0]);
od;
Append(A,[sum2one]);
Append(b,[1]);
return [A,b];
end;
fi;

if not IsBound(GenShannonUnBounded) then
GenShannonUnBounded:=function(n)
local rlist,mtx,str,i,j,shineq,nset_i,ineq,pairs,p,Klist,K,nset_ij,greq,neq,A,b,sum2one,s;
shineq:=[];
# first add H(X_i|rest)>=0 type inequalities
for i in [1..n] do
  nset_i:=[1..n];
  SubtractSet(nset_i,[i]);
  ineq:=ZeroMutable([1..2^n]);
  ineq[set2int([1..n])+1]:=1;
  ineq[set2int(nset_i)+1]:=-1;
  Append(shineq,[ineq]);
od;
# second, add I(X_i,X_j|X_K) >=0
pairs:=Combinations([1..n],2);
for p in pairs do
  nset_ij:=[1..n];
  SubtractSet(nset_ij,p);
  Klist:=Combinations(nset_ij);
  for K in Klist do
    ineq:=ZeroMutable([1..2^n]);
    ineq[set2int(Union(K,[p[1]]))+1]:=1;
    ineq[set2int(Union(K,[p[2]]))+1]:=1;
    ineq[set2int(Union(K,p))+1]:=-1;
    if Size(K)>0 then
      ineq[set2int(K)+1]:=-1;
    fi;
    Append(shineq,[ineq]);
  od;
od;
shineq:=-shineq;
sum2one:=ZeroMutable([1..2^n-1]);
for i in [1..2^n-1] do
sum2one[i]:=1;
od;
A:=[];
b:=[];
for s in shineq do
  Append(A,[s{[2..Size(s)]}]);
  Append(b,[0]);
od;
#Append(A,[sum2one]);
#Append(b,[1]);
return [A,b];
end;
fi;

if not IsBound(DeepSort) then
DeepSort:=function(list,nlevels,l)
  local soretdlist,i;
  # l is current level
  # level:=1: only ``list`` is sorted at top level
  # level:=2: each element of list is also sorted and so on...
  # levels 1 and nlevels won't be sorted
  if nlevels = 1 then
    return list;
  fi;
  if nlevels=l then
    return list;
  else
    soretdlist:=EmptyPlist(Size(list));
    for i in [1..Size(list)] do
      soretdlist[i]:=DeepSort(list[i],nlevels,l+1);
      od;
    return soretdlist;
  fi;
end;
fi;

if not IsBound(nextnum) then
nextnum:=function(str,i)
local foundnum, j,k,isneg;
if i>Size(str) or i<0 then
  return -1;
fi;
foundnum:=false;
isneg:=false;
for j in [i..Size(str)] do
  if not str[j]=' ' then
    if IsDigitChar(str[j]) then
      if j-1>=1 and str[j-1]='-' then
        isneg:=true;
      fi;
      foundnum:=true;
      break;
    fi;
  fi;
od;
if foundnum=false then
 return [false,-1,-1]; # [found?, number, next_i]
fi;
for k in [j+1..Size(str)] do
  if not IsDigitChar(str[k]) then
    break;
  fi;
od;
if isneg=true then
  return [true,Int(str{[j-1..k-1]}),k];
else
  return [true,Int(str{[j..k-1]}),k];
fi;
end;
fi;

if not IsBound(writeinefile) then
writeinefile:=function(fname,lin,mtx)
local ostr,row,i,r;
ostr:="";
if Size(lin)=0 then
  ostr:=Concatenation(ostr,"H-representation\nbegin\n",String(Size(mtx))," ",String(Size(mtx[1])), " rational\n");
else
  ostr:= Concatenation(ostr,"H-representation\n","linearity ",String(Size(lin))," ");
  for r in lin do
      ostr:=Concatenation(ostr,String(r)," ");
  od;
  ostr:=Concatenation(ostr,"\nbegin\n",String(Size(mtx))," ",String(Size(mtx[1])), " rational\n");
fi;
for i in [1..Size(mtx)] do
    row:=mtx[i];
    #ostr:=Concatenation(ostr,"0 ");
    for r in row do
        ostr:=Concatenation(ostr,String(r)," ");
    od;
    ostr:=Concatenation(ostr,"\n");
od;
ostr:=Concatenation(ostr,"end");
PrintTo(fname,ostr);
end;
fi;


## Gurobi interface functions
InstallGlobalFunction(qsoptformatstr,
function(obj,A,b,linrows,optargs)
local At,cmatval,cmatcnt,cmatind,sense,i,j,c,r,ccnt,x,ostr,hasrat,qs_algo;
# find out if A or b have rationals
hasrat:=false;
for i in [1..Size(obj)] do
  if not DenominatorRat(obj[i])=1 then
    hasrat:=true;
    break;
  fi;
od;
for i in [1..Size(A)] do
  for j in [1..Size(A[i])] do
    if not DenominatorRat(A[i][j] )=1 then
      hasrat:=true;
      break;
    fi;
  od;
od;
if hasrat=false then
  for i in [1..Size(b)] do
    if not DenominatorRat(b[i])=1 then
      hasrat:=true;
      break;
    fi;
  od;
fi;
At:=TransposedMat(A);
cmatval:=[];
cmatcnt:=[];
cmatind:=[];
sense:=[];
for c in [1..Size(At)] do
  ccnt:=0;
  for r in [1..Size(At[c])] do
    if not At[c][r]=0 then
      ccnt:=ccnt+1;
      Append(cmatval,[At[c][r]]);
      Append(cmatind,[r-1]);
    fi;
  od;
  Append(cmatcnt,[ccnt]);
od;
for i in [1..Size(A)] do
  if i in linrows then
    Append(sense,[1]);
  else
    Append(sense,[0]);
  fi;
od;
if hasrat=false then
 #Display("norat");
 ostr:=[];
 Append(ostr,[String(1)]);
 Append(ostr,[String(Size(A))]);
 Append(ostr,[String(Size(obj))]);
 Append(ostr,[String(Size(obj))]);;
 for x in obj do
  Append(ostr,[String(x)]);
 od;
 Append(ostr,[String(Size(cmatval))]);
 for x in cmatval do
  Append(ostr,[String(x)]);
 od;
 Append(ostr,[String(Size(cmatcnt))]);
 for x in cmatcnt do
  Append(ostr,[String(x)]);;
 od;
 Append(ostr,[String(Size(cmatind))]);;
 for x in cmatind do
  Append(ostr,[String(x)]);;
 od;
 Append(ostr,[String(Size(sense))]);;
 for x in sense do
  Append(ostr,[String(x)]);
 od;
 Append(ostr,[String(Size(b))]);
 for x in b do
  Append(ostr,[String(x)]);
 od;
else
 #Display("yesrat");
  ostr:="";
  Append(ostr,[String(0)]);
  Append(ostr,[String(Size(A))]);
  Append(ostr,[String(Size(obj))]);
  Append(ostr,[String(Size(obj))]);
  for x in obj do
   Append(ostr,[String(NumeratorRat(x))]);
  od;
  for x in obj do
   Append(ostr,[String(DenominatorRat(x))]);
  od;
  ##
  Append(ostr,[String(Size(cmatval))]);
  for x in cmatval do
    Append(ostr,[String( NumeratorRat(x))]);
  od;
  for x in cmatval do
    Append(ostr,[String( DenominatorRat(x))]);
  od;
  Append(ostr,[String(Size(cmatcnt))]);
  for x in cmatcnt do
   Append(ostr,[String(x)]);
  od;
  Append(ostr,[String(Size(cmatind))]);
  for x in cmatind do
   Append(ostr,[String(x)]);
  od;
  Append(ostr,[String(Size(sense))]);
  for x in sense do
   Append(ostr,[String(x)]);
  od;
  Append(ostr,[String(Size(b))]);
  for x in b do
   Append(ostr,[String(NumeratorRat(x))]);
  od;
  for x in b do
   Append(ostr,[String(DenominatorRat(x))]);
  od;
fi;
if not Size(optargs) > 0 then
  qs_algo:=0; # primal simplex
else
  qs_algo:=optargs[1];
fi;
Append(ostr,[String(qs_algo)]);
return ostr;
end);

InstallGlobalFunction(qsoptformatstr2,
function(obj,A,b,linrows,optargs)
local At,cmatval,cmatcnt,cmatind,sense,i,j,c,r,ccnt,x,ostr,hasrat,qs_algo,ostr2;
# find out if A or b have rationals
hasrat:=false;
for i in [1..Size(obj)] do
  if not DenominatorRat(obj[i])=1 then
    hasrat:=true;
    break;
  fi;
od;
for i in [1..Size(A)] do
  for j in [1..Size(A[i])] do
    if not DenominatorRat(A[i][j] )=1 then
      hasrat:=true;
      break;
    fi;
  od;
od;
if hasrat=false then
  for i in [1..Size(b)] do
    if not DenominatorRat(b[i])=1 then
      hasrat:=true;
      break;
    fi;
  od;
fi;
At:=TransposedMat(A);
cmatval:=[];
cmatcnt:=[];
cmatind:=[];
sense:=[];
for c in [1..Size(At)] do
  ccnt:=0;
  for r in [1..Size(At[c])] do
    if not At[c][r]=0 then
      ccnt:=ccnt+1;
      Append(cmatval,[At[c][r]]);
      Append(cmatind,[r-1]);
    fi;
  od;
  Append(cmatcnt,[ccnt]);
od;
for i in [1..Size(A)] do
  if i in linrows then
    Append(sense,[1]);
  else
    Append(sense,[0]);
  fi;
od;
if hasrat=false then
 #Display("norat");
 ostr:=[];
 Append(ostr,[String(1)]);
 Append(ostr,[String(Size(A))]);
 Append(ostr,[String(Size(obj))]);
 Append(ostr,[String(Size(obj))]);;
 for x in obj do
  Append(ostr,[String(x)]);
 od;
 Append(ostr,[String(Size(cmatval))]);
 for x in cmatval do
  Append(ostr,[String(x)]);
 od;
 Append(ostr,[String(Size(cmatcnt))]);
 for x in cmatcnt do
  Append(ostr,[String(x)]);;
 od;
 Append(ostr,[String(Size(cmatind))]);;
 for x in cmatind do
  Append(ostr,[String(x)]);;
 od;
 Append(ostr,[String(Size(sense))]);;
 for x in sense do
  Append(ostr,[String(x)]);
 od;
 Append(ostr,[String(Size(b))]);
 for x in b do
  Append(ostr,[String(x)]);
 od;
else
 #Display("yesrat");
  ostr:="";
  Append(ostr,[String(0)]);
  Append(ostr,[String(Size(A))]);
  Append(ostr,[String(Size(obj))]);
  Append(ostr,[String(Size(obj))]);
  for x in obj do
   Append(ostr,[String(NumeratorRat(x))]);
  od;
  for x in obj do
   Append(ostr,[String(DenominatorRat(x))]);
  od;
  ##
  Append(ostr,[String(Size(cmatval))]);
  for x in cmatval do
    Append(ostr,[String( NumeratorRat(x))]);
  od;
  for x in cmatval do
    Append(ostr,[String( DenominatorRat(x))]);
  od;
  Append(ostr,[String(Size(cmatcnt))]);
  for x in cmatcnt do
   Append(ostr,[String(x)]);
  od;
  Append(ostr,[String(Size(cmatind))]);
  for x in cmatind do
   Append(ostr,[String(x)]);
  od;
  Append(ostr,[String(Size(sense))]);
  for x in sense do
   Append(ostr,[String(x)]);
  od;
  Append(ostr,[String(Size(b))]);
  for x in b do
   Append(ostr,[String(NumeratorRat(x))]);
  od;
  for x in b do
   Append(ostr,[String(DenominatorRat(x))]);
  od;
fi;
if not Size(optargs) > 0 then
  qs_algo:=0; # primal simplex
else
  qs_algo:=optargs[1];
fi;
Append(ostr,[String(qs_algo)]);
ostr2:="";
for x in ostr do
  ostr2:=Concatenation(ostr2,x," ");
od;
return ostr2;
end);


InstallGlobalFunction(LoadGRBLPobj,
function(s,obj)
# setup a Gurobi LP
# return the stream
# if obj is empty list, a dummy all-coefficients-1 objective is loaded
  local ostr,hasrat,ostr_list,x,i,istr;
  hasrat:=false;
  for i in [1..Size(obj)] do
    if not DenominatorRat(obj[i])=1 then
      hasrat:=true;
      break;
    fi;
  od;
  ostr:="";
  ostr_list:=[];
  if hasrat=true then
    ostr:=Concatenation(ostr,"0 ");
    Append(ostr_list,[0]);
    for x in obj do
      ostr:=Concatenation(ostr,String(NumeratorRat(x))," ");
      Append(ostr_list,[String(NumeratorRat(x))]);
    od;
    for x in obj do
      ostr:=Concatenation(ostr,String(DenominatorRat(x))," ");
      Append(ostr_list,[String(DenominatorRat(x))]);
    od;
  else
    ostr:=Concatenation(ostr,"1 ");
    Append(ostr_list,[1]);
    for x in obj do
      Append(ostr_list,[String(x)]);
      ostr:=Concatenation(ostr,String(x)," ");
    od;
  fi;
  ostr:=Concatenation("3 ",String(Size(ostr_list))," ",ostr);
  WriteLine(s,ostr);
  istr:=Concatenation("local rval_obj;", ReadLine(s), "return rval_obj;");
  istr:= InputTextString( istr);;
  return ReadAsFunction(istr)();
end);

InstallGlobalFunction(GetGRBLPsol_primal,
function(s)
# solve the already loaded Gurobi LP on stream s
# use specified algorithm if mentioned in optargs[1]
local ostr,i;
WriteLine(s,"5 ");
ostr:=ReadLine(s);;
#Display(ostr);
ostr:=Concatenation("local status,val,val_rval,x,x_rval;",ostr,"if status=2 then return [status,val_rval,val,x_rval,x];else return [status]; fi;");
i := InputTextString( ostr);;
return ReadAsFunction(i)();
end);

InstallGlobalFunction(GetGRBLPsol_dual,
function(s)
# solve the already loaded Gurobi LP on stream s
# use specified algorithm if mentioned in optargs[1]
local ostr,i;
WriteLine(s,"6 ");
ostr:=ReadLine(s);;
ostr:=Concatenation("local status,val,val_rval,y,y_rval;",ostr,"if status=2 then return [status,val_rval,val,y_rval,y]; else return [status]; fi;");
i := InputTextString( ostr);;
return ReadAsFunction(i)();
end);

InstallGlobalFunction(SolveGRBLP,
function(s,optargs)
# solve the already loaded Gurobi LP on stream s
# use specified algorithm if mentioned in optargs[1]
local qs_algo,i,ostr;
if Size(optargs)>1 then
qs_algo:=optargs[1];
else
qs_algo:=0;
fi;
WriteLine(s,Concatenation("4 ",String(qs_algo)));
ostr:=ReadLine(s);
#Display(ostr);
ostr:=Concatenation("local status;",ostr,"return status;");
i := InputTextString( ostr);;
return ReadAsFunction(i)();
end);

InstallGlobalFunction(LoadGRBLP,
function(obj,A,b,linrows,gint_exec)
# setup a Gurobi LP
# return the stream
# if obj is empty list, a dummy all-coefficients-1 objective is loaded
    local  ostr, onemap, nb_ostr, s,istr,i;
    if Size( obj ) = 0  then
        onemap := function ( x )
              return 1;
          end;
        obj := List( [ 1 .. Size( A[1] ) ], onemap );
    fi;
    ostr := qsoptformatstr2( obj, A, b, linrows, [] );;
    nb_ostr := Size( qsoptformatstr( obj, A, b, linrows, [] ) );;
    ostr := Concatenation( "1 ", String( nb_ostr ), " ", ostr );;
    s := InputOutputLocalProcess( DirectoryCurrent(  ), gint_exec, [  ] );
    # Display(ostr);
    WriteLine( s, ostr );
    istr:=ReadLine(s);
    istr:=Concatenation("local status;",istr,"return status;");
    i := InputTextString( istr);;
    return [s,ReadAsFunction(i)()];
end);

InstallGlobalFunction(FlushGRBLP,
function(s)
# flush the currently loaded Gurobi LP and close stream
WriteLine(s,"2 ");
CloseStream(s);
end);

InstallGlobalFunction(DelGRBrow,
function(s,row)
local istr,i;
WriteLine(s,Concatenation("7 ",String(row-1)));
istr:=ReadLine(s);
istr:=Concatenation("local delrow_rval;",istr,"return delrow_rval;");
i := InputTextString( istr);;
return ReadAsFunction(i)();;
end);

InstallGlobalFunction(ChangeGRBrhs,
function(s,row,coef)
local istr,i;
if DenominatorRat(coef)=1 then
  WriteLine(s,Concatenation("8 2 ",String(row-1)," ",String(coef)));
else
  WriteLine(s,Concatenation("8 3 ",String(row-1)," ",String(NumeratorRat(coef))," ",String(DenominatorRat(coef))));
fi;
istr:=ReadLine(s);
istr:=Concatenation("local rhs_rval;",istr,"return rhs_rval;");
i := InputTextString( istr);;
return ReadAsFunction(i)();;
end);

InstallGlobalFunction(ChangeGRBsense,
function(s,row,newsense)
# newsense is a string "L" or "E"
local istr,i;
if newsense="L" then
  WriteLine(s,Concatenation("9 2 ",String(row-1)," ",String(76)));
else
  WriteLine(s,Concatenation("9 2 ",String(row-1)," ",String(69)));
fi;
istr:=ReadLine(s);
istr:=Concatenation("local sense_rval;",istr,"return sense_rval;");
i := InputTextString( istr);;
return ReadAsFunction(i)();;
end);

InstallGlobalFunction(ChangeGRBcoef,
function(s,row,col,coef)
local istr,i;
if DenominatorRat(coef)=1 then
  WriteLine(s,Concatenation("10 3 ",String(row-1)," ",String(col-1)," ",String(coef)));
else
  WriteLine(s,Concatenation("10 4 ",String(row-1)," ",String(col-1)," ",String(NumeratorRat(coef))," ",String(DenominatorRat(coef))));
fi;
istr:=ReadLine(s);
istr:=Concatenation("local coef_rval;",istr,"return coef_rval;");
i := InputTextString( istr);;
return ReadAsFunction(i)();;
end);

# InstallGlobalFunction(DisplayLPQS,
# function(s)
#   WriteLine(s,"11");
# end);

gint_exec:="/home/aspitrg3-users/jayant/catpit/gap4r8/pkg/gint/gint";
# 1 30 1 4 2 2 1 1 4 1 -1 1 -1 2 2 2 4 0 2 1 3 4 0 0 0 0 4 1 1 0 0 0
