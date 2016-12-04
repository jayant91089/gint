/*******************************************************************************/
/* Command codes:
The GAP  part of the interface communicates with the C part via stdout, and in
particular, via command codes. These are integers that tell the C part of the
code to take some action eg. read the following numbers and load them into the
objective or read the following number to change a particular rhs oefficient.
The numbers following the command code follow a certain pattern, irrespective of
what the command is. The general format is as follows:
cmdcode <nargs> <rat/int (opt)> <numerators> <denominators>
Here, <nargs> is an argument used to specify the number of numbers
following cmdcode, if it is variable-length (not used otherwise). <rat/int> is a
0/1 flag that indicates if the numbers are rational/integers. If numbers are rational
then they are sent as a list of numerators followed by a list of denominators.
The command codes and their meanings are as follows:
1 - load a LP. FORMAT: cmdcode nargs <rat/int (opt)> <numerators> <denominators>
2 - exit. FORMAT: cmdcode
3 - get new objective and load it.
    FORMAT: cmdcode nargs <rat/int (opt)> <numerators> <denominators>
4 - solve LP
5 - get primal solution. FORMAT: cmdcode
6 - get dual solution. FORMAT: cmdcode
7 - delete a row from constraint matrix. FORMAT: cmdcode rowindex(base 0)
8 - modify a specified rhs coef.
    FORMAT: cmdcode nargs rowindex numcoef dencoef(optional, for rationals)
9 - modify rhs sense (<= or =). FORMAT: cmdcode nargs rowindex sense
10 - change a particular entry in constraint matrix.
    FORMAT: cmdcode nargs rowindex colindex numcoef dencoef(optional, for rationals)
11 - print currently loaded LP to stedrr. FORMAT: cmdcode
12 - display status on stderr. FORMAT: cmdcode
/**/
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <stdlib.h>
#include <gurobi_c.h>
#include <gmp.h>
long getargs(char*, long**);
//int load_test (mpq_QSprob *p);
int setGRBobj(GRBmodel*, long* , long ); // gint: set gurobi objective using attributes
int setGRBlp(GRBenv*,GRBmodel**,long* , long );
int solveGRBlp(GRBmodel*,int);
int nextnum(char* ,int);
int getlpsol_primal(GRBmodel*);
int getlpsol_dual(GRBmodel*);
int delrow(GRBmodel* , int);
int changerhs(GRBmodel* , int , mpq_t );
int changesense(GRBmodel* , int , char );
int changecoef(GRBmodel*,int ,int ,mpq_t );

int main()
{
int i,j,row;
int newarg;
long nb_args;
int cmdcode,status;
/* GRB_METHOD = -1 (auto), 0 (primal simplex), 1 (dual simplex), 
 * 2 (barrier), 3 (concurrent), 4 (deterministic concurrent). */
int GRB_METHOD = 0;
 
long* args= (long*)NULL;
char* buf=(char*)NULL;
char* buf_original=(char*)NULL; // to free getline's buffer
char* tempbuf;
size_t bufsize;
GRBenv *env     = NULL;
int     error   = 0;

/* Create environment */
error = GRBloadenv(&env, NULL);
if (error) goto QUIT;

/* Silence stdout */
error = GRBsetintparam (env, "OutputFlag", 0);
if (error) goto QUIT;

GRBmodel* model = (GRBmodel*)NULL;
GRBmodel** modelptr = &model;

while(1)
{
    if(getline(&buf_original,&bufsize,stdin)!=-1)
    {
        buf=buf_original;
        //fprintf(stderr,"buffer addresses = %p",buf_original);
        sscanf(buf,"%d",&cmdcode);
        //printf("read line %s, cmdcode=%d ",buf,cmdcode);
        if(cmdcode==1) // load LP
        {
            i=0;
            buf=buf+2;
            sscanf(buf,"%ld",&nb_args);
            //fprintf(stderr,"nargs = %ld",nb_args);
            args=(long*)malloc(nb_args*sizeof(long));
            for(j=0;j<nb_args;j++)
            {
                i=nextnum(buf,i);
                sscanf(buf+i,"%ld",args+j);
                //printf("j= %d ,num = %ld||",j,args[j]);
            }
            //fprintf(stderr,"loading problem\n");
            error = setGRBlp(env,modelptr,args,nb_args);
            if (error) goto QUIT;
            free(args);
        }
        else if(cmdcode==2)
        {
            break;
        }
        else if(cmdcode==3) // get new objective and load it
        {
            // set obj
            //fprintf(stderr,"Loading obj, here 0\n");
            i=0;
            buf=buf+2;
            sscanf(buf,"%ld",&nb_args);
            //printf("nargs = %ld",nb_args);
            args=(long*)malloc(nb_args*sizeof(long));
            for(j=0;j<nb_args;j++)
            {
                i=nextnum(buf,i);
                sscanf(buf+i,"%ld",args+j);
            }
            error = setGRBobj(model,args, nb_args);
            free(args);
            if (error) goto QUIT;
        }
        else if(cmdcode==4) // solve LP (GRB)
        {
            buf=buf+2;
            sscanf(buf,"%d",&GRB_METHOD);
            error = solveGRBlp(model,GRB_METHOD);
            if (error) goto QUIT;
        }
        else if(cmdcode==5)// get primal solution
        {
            error = getlpsol_primal(model);
            if (error) goto QUIT;
            
        }
        else if(cmdcode==6)// get dual solution
        {
            error = getlpsol_dual(model);
            if (error) goto QUIT;
        }
        else if(cmdcode==7)
        {
            buf=buf+2;
            sscanf(buf,"%d",&row);
            error = delrow(model, row);
            if (error) goto QUIT;
        }
        else if(cmdcode==8)
        {
            // get new rhs coef and row index
            i=0;
            buf=buf+2;
            sscanf(buf,"%ld",&nb_args);
            //printf("nargs = %ld",nb_args);
            args=(long*)malloc(nb_args*sizeof(long));
            for(j=0;j<nb_args;j++)
            {
                i=nextnum(buf,i);
                sscanf(buf+i,"%ld",args+j);
            }
            mpq_t coef;
            mpq_init(coef);
            if(nb_args==2)// integer
            {
                mpq_set_si(coef,args[1],1);
            }
            else
            {
                mpq_set_si(coef,args[1],args[2]);
            }
            error = changerhs(model,(int)(args[0]),coef);
            free(args);
            if (error) goto QUIT;
        }
        else if(cmdcode==10)
        {
                // get new coef and row,column indices
            i=0;
            buf=buf+3;
            sscanf(buf,"%ld",&nb_args);
            //printf("nargs = %ld",nb_args);
            args=(long*)malloc(nb_args*sizeof(long));
            for(j=0;j<nb_args;j++)
            {
                i=nextnum(buf,i);
                sscanf(buf+i,"%ld",args+j);
            }
            mpq_t coef;
            mpq_init(coef);
            if(nb_args==3)// integer
            {
                mpq_set_si(coef,args[2],1);
            }
            else
            {
                mpq_set_si(coef,args[2],args[3]);
            }
            //gmp_fprintf(stderr,"Recieved coef %Qd, row=%ld,col=%ld\n",coef,args[0],args[1]);
            error = changecoef(model,args[0],args[1],coef);
            free(args);
            if (error) goto QUIT;
        }
        else if(cmdcode==9)
        {
            // change rhs sense of a row
            i=0;
            buf=buf+2;
            sscanf(buf,"%ld",&nb_args);

            args=(long*)malloc(nb_args*sizeof(long));
            for(j=0;j<nb_args;j++)
            {
                i=nextnum(buf,i);
                sscanf(buf+i,"%ld",args+j);
            }
            if(args[1]==76)
            error = changesense(model,(int)(args[0]),'<');
            else
            error = changesense(model,(int)(args[0]),'=');
            free(args);
            if (error) goto QUIT;
        }
        else if(cmdcode==11) // print LP TODO: How to do this in Gurobi
        {
            
        }
        else if(cmdcode==12) // display status on stderr
        {
            int status_current=0;
            error = GRBgetintattr(model, "Status", &status_current);
            fprintf(stderr,"Current status = %d",status_current);
            if (error) goto QUIT;
        }
        //fprintf(stderr,"original buffer address = %p, mod = %p",buf_original,buf);
    }
    if(buf_original!=(char*)NULL)
    free(buf_original);
    buf_original=(char*)NULL;
}
QUIT:

  /* Error reporting */

  if (error) {
    printf("ERROR: %s\n", GRBgeterrormsg(env));
    exit(1);
  }

  /* Free model */

  GRBfreemodel(model);
  return 1;
}

int solveGRBlp(GRBmodel *model,int method)
{
    // solve the lp *p and return solution and arg-solution
    int status,rval,i;
    int error = 0;
    int nb_cols = 0;
    int status_current=0;
    GRBenv* modelenv;
    modelenv = GRBgetenv(model);
    
    error = GRBgetintattr(model, "NumVars", &nb_cols);
    if (error) goto SOLVELP_ERR;
    
    error = GRBsetintparam (modelenv, "Method", method );
    if (error) goto SOLVELP_ERR;
    
    error = GRBupdatemodel(model); 
    if(error) goto SOLVELP_ERR;
    
    error = GRBoptimize(model);
    if (error) goto SOLVELP_ERR;
        
    error = GRBgetintattr(model, "Status", &status_current);
    if (error) goto SOLVELP_ERR;
    printf("status:=%d;;",status_current);
    
    error = GRBsetintparam (modelenv, "Method", method );
    if (error) goto SOLVELP_ERR;
    
    error = GRBupdatemodel(model); 
    if(error) goto SOLVELP_ERR;
    
    SOLVELP_ERR:
    
    if(error) fprintf(stderr,"Error while solving LP, Error Code = %d\n",error);
    return error;
}

int getlpsol_primal(GRBmodel* model)
{
    int rval,i,status;
    mpq_t* x_rat;
    double objval = 0;
    mpq_t objval_rat;
    mpq_init(objval_rat);
    int nb_cols = 0;
    int error = 0;
    
    error = GRBgetintattr(model, "NumVars", &nb_cols);
    if (error) goto GETPRIMALSOL_ERR;
    
    double* x = (double*)malloc(nb_cols*sizeof(double));
    
    error = GRBgetintattr(model, "Status", &status);
    if (error) goto GETPRIMALSOL_ERR;
    printf("status:=%d;;",status);    // compose format string to print to stdout, to be picked up by GAP
    fprintf(stderr,"here0\n");
    switch (status) {
    case 2:
        printf ("status:=%d;;",status);
        error = GRBgetdblattr(model, GRB_DBL_ATTR_OBJVAL, &objval);
        fprintf(stderr,"here1\n");
        if (error)
        {
            fprintf(stderr,"here2\n");
            printf("val_rval:= %d;;", error);
            printf("val:= -1");
            goto GETPRIMALSOL_ERR;
        }
        else
        {
            fprintf(stderr,"here3\n");
            mpq_set_d(objval_rat,objval);
            printf("val_rval:= %d;;", error);
            gmp_printf("val:= %Qd;;", objval_rat);
        }
        x_rat = (mpq_t *) malloc (nb_cols * sizeof (mpq_t));
        for (i = 0; i < nb_cols; i++) mpq_init (x_rat[i]);
        error = GRBgetdblattrarray(model, GRB_DBL_ATTR_X, 0, nb_cols, x);
        if (error)
        {
            printf("x_rval:= %d;;", error);
            printf("x:= [];;");
            goto GETPRIMALSOL_ERR;
        }
        else
        {
            printf("x_rval:= %d;;", error);
            printf("x:=[");
            for (i = 0; i < nb_cols-1; i++)
            {
                mpq_set_d(x_rat[i],x[i]);
                gmp_printf("%Qd,", x_rat[i]);
            }
            mpq_set_d(x_rat[nb_cols-1],x[nb_cols-1]);
            gmp_printf("%Qd];;", x_rat[nb_cols-1]);
        }
        break;
    default:
        printf ("status:=%d;;", status);
        break;
    }
    
    GETPRIMALSOL_ERR:
    if(error) fprintf(stderr,"Error while retrieving primal solution, Error Code = %d\n",error);
    mpq_clear(objval_rat);
    if(x_rat) 
    {
        for(i=0;i<nb_cols;i++) mpq_clear(x_rat[i]);
        free(x_rat);
    }
    if(x) free(x);
    return error;
}


int getlpsol_dual(GRBmodel* model)
{
    int rval,i,status;
    mpq_t* y_rat;
    double objval = 0;
    mpq_t objval_rat;
    mpq_init(objval_rat);
    int nb_rows = 0;
    int error = 0;
    
    error = GRBgetintattr(model, "NumConstrs", &nb_rows);
    if (error) goto GETDUALSOL_ERR;
    
    double* y = (double*)malloc(nb_rows*sizeof(double));
    
    error = GRBgetintattr(model, "Status", &status);
    if (error) goto GETDUALSOL_ERR;
    printf("status:=%d;;",status);    // compose format string to print to stdout, to be picked up by GAP
    fprintf(stderr,"here0\n");
    switch (status) {
    case 2:
        printf ("status:=%d;;",status);
        error = GRBgetdblattr(model, GRB_DBL_ATTR_OBJVAL, &objval);
        fprintf(stderr,"here1\n");
        if (error)
        {
            fprintf(stderr,"here2\n");
            printf("val_rval:= %d;;", error);
            printf("val:= -1");
            goto GETDUALSOL_ERR;
        }
        else
        {
            fprintf(stderr,"here3\n");
            mpq_set_d(objval_rat,objval);
            printf("val_rval:= %d;;", error);
            gmp_printf("val:= %Qd;;", objval_rat);
        }
        y_rat = (mpq_t *) malloc (nb_rows * sizeof (mpq_t));
        for (i = 0; i < nb_rows; i++) mpq_init (y_rat[i]);
        error = GRBgetdblattrarray(model, GRB_DBL_ATTR_PI, 0, nb_rows, y);
        if (error)
        {
            printf("y_rval:= %d;;", error);
            printf("y:= [];;");
            goto GETDUALSOL_ERR;
        }
        else
        {
            printf("y_rval:= %d;;", error);
            printf("y:=[");
            for (i = 0; i < nb_rows-1; i++)
            {
                mpq_set_d(y_rat[i],y[i]);
                gmp_printf("%Qd,", y_rat[i]);
            }
            mpq_set_d(y_rat[nb_rows-1],y[nb_rows-1]);
            gmp_printf("%Qd];;", y_rat[nb_rows-1]);
        }
        break;
    default:
        printf ("status:=%d;;", status);
        break;
    }
    
    GETDUALSOL_ERR:
    if(error) fprintf(stderr,"Error while retrieving primal solution, Error Code = %d\n",error);
    mpq_clear(objval_rat);
    if(y_rat) 
    {
        for(i=0;i<nb_rows;i++) mpq_clear(y_rat[i]);
        free(y_rat);
    }
    if(y) free(y);
    return error;
    //int rval,i,status;
    //mpq_t*y;
    //mpq_t value;
    //mpq_init(value);
    //long nb_rows = mpq_QSget_rowcount (*p);;
    //rval = mpq_QSget_status (*p, &status);
    //// compose format string to print to stdout, to be picked up by GAP
    //switch (status) {
    //case QS_LP_OPTIMAL:
        //printf ("status:=%d;;",status);
        //rval = mpq_QSget_objval (*p, &value);
        //if (rval)
        //{
            //printf("val_rval:= %d;;", rval);
            //printf("val:= -1");
        //}
        //else
        //{
            //printf("val_rval:= %d;;",rval);
            //gmp_printf("val:= %Qd;;", value);
        //}
        //y = (mpq_t *) malloc (nb_rows * sizeof (mpq_t));
        //for (i = 0; i < nb_rows; i++) mpq_init (y[i]);
        //rval = mpq_QSget_pi_array (*p, y);
        //if (rval)
        //{
            //printf("y_rval:= -1;;");
            //printf("y:= [];;");
        //}
        //else
        //{
            //printf("y_rval:= %d;;",rval);
            //printf("y:=[");
            //for (i = 0; i < nb_rows-1; i++)
            //{
                //gmp_printf("%Qd,", y[i]);
            //}
            //gmp_printf("%Qd];;", y[nb_rows-1]);
        //}
        //break;
    //default:
        //printf ("status:=%d;;", status);
        //break;
    //}
    return 1;
}


int setGRBobj(GRBmodel *model, long* args, long len)
{
    int j,i,rval;
    int nb_cols, error;
    error = 0;
    nb_cols = 0;
    error = GRBgetintattr(model, "NumVars", &nb_cols);;
    if(error) goto SETOBJ_ERR;
    
    //fprintf(stderr,"Loading obj, here 1\n");
    double* obj=(double*)malloc(nb_cols*sizeof(double));
    if(args[0]==1) // integer obj
    {
        for(j=1;j<nb_cols+1;j++)
        {
            obj[j-1] = (double)(args[j]);
        }
    }
    else
    {
        //fprintf(stderr,"Loading obj, here 2\n");
        long* objnum=(long*)malloc(nb_cols*sizeof(long));
        long* objden=(long*)malloc(nb_cols*sizeof(long));
        for(j=1;j<1+nb_cols;j++)
           objnum[j-1]=args[j];
        for(j=nb_cols+1;j<2*nb_cols+1;j++)
           objden[j-nb_cols-1]=args[j];
        for(j=0;j<nb_cols;j++)
        {
            obj[j] = ((double)(objnum[j]))/((double)(objden[j]));
        }
        free(objnum);
        free(objden);
    }
    rval=0;
    error = GRBsetdblattrarray (model, "Obj", 0, nb_cols, obj );
    free(obj);
    if(error)
    printf("rval_obj:=-1;;");
    else
    printf("rval_obj:=1;;");
    error = GRBupdatemodel(model); 
    if(error) goto SETOBJ_ERR;
    error = GRBwrite(model, "/home/aspitrg3-users/jayant/dense.lp");
    if(error) goto SETOBJ_ERR;
    
    SETOBJ_ERR:
    if(error) fprintf(stderr,"Error while setting up Obj, Error Code = %d\n",error);
    return error;
    
}

////long getargs(long** argspointer)
////{
    ////long i;
    ////long nb_args;
    ////scanf("%ld",&nb_args);
    ////*argspointer=(long*)malloc(nb_args*sizeof(long));
    ////for(i=0;i<nb_args;i++)
    ////scanf("%ld",*argspointer+i);
    ////return nb_args;
////}
////long getargs(char* buf, long** argspointer)
////{
    ////long i,j;
    ////long nb_args;
    ////sscanf(buf,"%ld",&nb_args);
    ////buf=nextnum(buf);
    ////*argspointer=(long*)malloc(nb_args*sizeof(long));
    ////for(i=0;i<nb_args;i++)
    ////{
        ////sscanf(buf,"%ld",(*argspointer)+i);
        //////fprintf(stdout,"i=%ld/args[i]=%ld/nargs=%ld\n",i,(*argspointer)[i],nb_args);
        ////if(i!=nb_args-1)
        ////{
            ////buf=nextnum(buf);
        ////}
    ////}
    ////return nb_args;
    //return 0;
//}

int delrow(GRBmodel* model, int row)
{
    //row is base-0 index
    int error;
    
    error = GRBdelconstrs(model, 1, &row );
    if(error) goto DELROW_ERR;
    
    error = GRBupdatemodel(model); 
    if(error) goto DELROW_ERR;
    
    DELROW_ERR:
    if(error) fprintf(stderr,"Error while deleting row %d, Error Code = %d\n",row,error);
    printf("delrow_rval:=%d;;",error);
    return error;
}

int changerhs(GRBmodel* model, int row, mpq_t coef)
{
    //// row is base 0 index
    int error;
    error = GRBsetdblattrelement (model, "RHS", row, mpq_get_d(coef));
    if(error) goto CHRHS_ERR;
    
    error = GRBupdatemodel(model); 
    if(error) goto CHRHS_ERR;
    
    CHRHS_ERR:
    if(error) fprintf(stderr,"Error while changing rhs coef %d, Error Code = %d\n",row,error);
    printf("rhs_rval:=%d;;",error);
    return error;
}

int changesense(GRBmodel* model, int row, char sense)
{
    //// row is base 0 index
    int error;
    //mpq_QSwrite_prob_file(*p,stderr,"LP");
    error = GRBsetcharattrelement(model, "RHS", row, sense);
    if(error) goto CHSENSE_ERR;
    
    error = GRBupdatemodel(model); 
    if(error) goto CHSENSE_ERR;
    
    CHSENSE_ERR:
    if(error) fprintf(stderr,"Error while changing rhs sense of row %d, Error Code = %d\n",row,error);
    printf("sense_rval:=%d;;",error);
    return error;
}

int changecoef(GRBmodel* model,int row,int col,mpq_t coef)
{
     //// row is base 0 index
    int error;
    double coef_dbl = mpq_get_d(coef);
    error = GRBchgcoeffs( model, 1, &row, &col, &coef_dbl); 
    if(error) goto CHCOEF_ERR;
    
    error = GRBupdatemodel(model); 
    if(error) goto CHCOEF_ERR;
    
    CHCOEF_ERR:
    if(error) fprintf(stderr,"Error while changing coef (%d,%d), Error Code = %d\n",row,col,error);    
    printf("coef_rval:=%d;;",error);
    
    return error;
}

int nextnum(char* buf,int i)
{
    //// caveat emptor: assumes infinite buffer. Use only when you are certain
    //// there is indeed a number at or after buf[0]
    while(buf[i]!=' ' && buf[i]!='\0')
    i++;
    return i+1;
}


int setGRBlp(GRBenv* env, GRBmodel **modelptr, long* args, long len)
{
    //printf("setqslp received %ld numbers",len);
    long i=0;// current index
    int qs_algo=0;
    long j,nb_cmatval,nb_cmatcnt,nb_cmatind,nb_sense,nb_obj,nb_rhs;
    mpq_t *cmatval,*x;
    int *cmatcnt, *cmatbeg, *cmatind;
    char* sense,**rownames,**colnames;
    int nb_rows,nb_cols,rval,error;
    long temp;
    /* variables to be passed to GRBloadmodel */
    double *vval, *obj;
    double *rhs;
    /*****************************************/ 
    mpq_t value;
    mpq_init(value);
    if(args[i]==1) // integers only
    {
        //fprintf(stderr, "integers only\n");
        i++;
        nb_rows=args[i];
        i++;
        nb_cols=args[i];
        i++;
        nb_obj=args[i];
        i++;

        obj=(double*)malloc(nb_obj*sizeof(obj));
        for(j=i;j<i+nb_obj;j++)
        {   //fprintf(stderr,"here1 %ld",j);
            obj[j-i] = (double)args[j];
        }
        i=j;
        nb_cmatval=args[i];
        i++;
        vval=(double*)malloc(nb_cmatval*sizeof(double));
        for(j=i;j<i+nb_cmatval;j++)
        {
            vval[j-i] = (double)(args[j]);
        }
        i=j;
        nb_cmatcnt=args[i];
        i++;
        cmatcnt=(int*)malloc(nb_cmatcnt*sizeof(int));
        for(j=i;j<i+nb_cmatcnt;j++)
        {
            cmatcnt[j-i]=args[j];
        }
        i=j;
        nb_cmatind=args[i];
        i++;
        cmatind=(int*)malloc(nb_cmatind*sizeof(int));
        for(j=i;j<i+nb_cmatind;j++)
        {
            cmatind[j-i]=args[j];
        }
        i=j;
        nb_sense=args[i];
        i++;
        sense=(char*)malloc(nb_sense*sizeof(char));
        for(j=i;j<i+nb_sense;j++)
        {
            sense[j-i]=(args[j]==1)?'=':'<'; // 'E' or 'L' for QSopt, '=' or '<' for Gurobi
        }
        i=j;
        nb_rhs=args[i];
        i++;
        rhs=(double*)malloc(nb_rhs*sizeof(double));
        for(j=i;j<i+nb_rhs;j++)
        {
            rhs[j-i]=(double)(args[j]);
        }
        i=j;
        qs_algo=args[i];
    }
    else // rationals
    {
        //fprintf(stderr, "rationals\n");
        i++;
        nb_rows=args[i];
        i++;
        nb_cols=args[i];
        i++;
        nb_obj=args[i];
        i++;
        obj=(double*)malloc(nb_obj*sizeof(double));
        long* objnum=(long*)malloc(nb_obj*sizeof(long));
        long* objden=(long*)malloc(nb_obj*sizeof(long));
        for(j=i;j<i+nb_obj;j++)
           objnum[j-i]=args[j];
        i=j;
        for(j=i;j<i+nb_obj;j++)
           objden[j-i]=args[j];
        i=j;
        for(j=0;j<nb_obj;j++)
        {
            obj[j]=((double)(objnum[j]))/((double)(objden[j]));
        }
        free(objnum);
        free(objden);
        nb_cmatval=args[i];
        i++;
        vval=(double*)malloc(nb_cmatval*sizeof(double));
        long* valnum=(long*)malloc(nb_cmatval*sizeof(long));
        long* valden=(long*)malloc(nb_cmatval*sizeof(long));
        for(j=i;j<i+nb_cmatval;j++)
           valnum[j-i]=args[j];
        i=j;
        for(j=i;j<i+nb_cmatval;j++)
           valden[j-i]=args[j];
        i=j;
        for(j=0;j<nb_cmatval;j++)
        {
            vval[j] = ((double)(valnum[j]))/((double)(valden[j]));
        }
        free(valnum);
        free(valden);
        nb_cmatcnt=args[j];
        i++;
        cmatcnt=(int*)malloc(nb_cmatcnt*sizeof(int));
        for(j=i;j<i+nb_cmatcnt;j++)
        {
            cmatcnt[j-i]=args[j];
        }
        i=j;
        nb_cmatind=args[i];
        i++;
        cmatind=(int*)malloc(nb_cmatind*sizeof(int));
        for(j=i;j<i+nb_cmatind;j++)
        {
            cmatind[j-i]=args[j];
        }
        i=j;
        nb_sense=args[i];
        i++;
        sense=(char*)malloc(nb_sense*sizeof(char));
        for(j=i;j<i+nb_sense;j++)
        {
            sense[j-i]=(args[j]==1)?'=':'<';
        }
        i=j;
        nb_rhs=args[i];
        i++;
        rhs=(double*)malloc(nb_rhs*sizeof(double));
        long* rhsnum=(long*)malloc(nb_rhs*sizeof(long));
        long* rhsden=(long*)malloc(nb_rhs*sizeof(long));
        for(j=i;j<i+nb_rhs;j++)
           rhsnum[j-i]=args[j];
        i=j;
        for(j=i;j<i+nb_rhs;j++)
           rhsden[j-i]=args[j];
        i=j;
        for(j=0;j<nb_rhs;j++)
        {
            rhs[j]=((double)(rhsnum[j]))/((double)(rhsden[j]));
        }
        free(rhsnum);
        free(rhsden);
        qs_algo=args[i];

    }
    //// construct cmatbeg from cmatcnt
    cmatbeg=malloc(nb_cmatcnt*sizeof(int));
    cmatbeg[0]=0;
    for(j=1;j<nb_cmatcnt;j++)
    cmatbeg[j]=cmatbeg[j-1]+cmatcnt[j-1];

    /*Create a new model*/

    error = GRBnewmodel(env, modelptr, "New", nb_cols, NULL, NULL, NULL, NULL, NULL);
    if(error) goto SETLP_ERR;

    error = GRBloadmodel(env, modelptr, "New", nb_cols, nb_rows, -1, 0.0, obj, sense, rhs, cmatbeg, cmatcnt, cmatind, vval, NULL, NULL, NULL, NULL, NULL);
    
    if (error) {
        fprintf(stderr, "error = %d",error);
        printf("status:=[-1];;");
        goto SETLP_ERR;
    }
    else
    printf("status:=[1];;");
    
    ///* Write file */
    //error = GRBupdatemodel(*modelptr); 
    //if(error) goto SETLP_ERR;
    //error = GRBwrite(*modelptr, "/home/aspitrg3-users/jayant/dense.lp");
    //if(error) goto SETLP_ERR;

    SETLP_ERR:
    if(error) fprintf(stderr,"Error while setting up LP, Error Code = %d\n",error);
    return error;
}

//int load_test (mpq_QSprob *p)
//{
    //int i, rval = 0;
    //int cmatcnt[3] = { 3, 2, 3 };
    //int cmatbeg[3] = { 0, 3, 5 };
    //int cmatind[8] = { 0, 1, 2, 0, 1, 0, 3, 4 };
    //char sense[5] = { 'L', 'E', 'L','L','L' };
    //const char *colnames[3] = { "x", "y", "z" };
    //const char *rownames[5] = { "c1", "c2","c3","c4","c5"};
    //mpq_t cmatval[8];
    //mpq_t obj[3];
    //mpq_t rhs[5];
    //mpq_t lower[3];
    //mpq_t upper[3];

    //for (i = 0; i < 8; i++) mpq_init (cmatval[i]);
    //mpq_set_d (cmatval[0], 3.0);
    //mpq_set_d (cmatval[1], 5.0);
    //mpq_set_d (cmatval[2], -1.0);
    //mpq_set_d (cmatval[3], 2.0);
    //mpq_set_d (cmatval[4], 1.0);
    //mpq_set_d (cmatval[5], 1.0);
    //mpq_set_d (cmatval[6], 1.0);
    //mpq_set_d (cmatval[7], -1.0);

    //for (i = 0; i < 3; i++) mpq_init (obj[i]);
    //mpq_set_d (obj[0], 3.0);
    //mpq_set_d (obj[1], 2.0);
    //mpq_set_d (obj[2], 4.0);

    //for (i = 0; i < 5; i++) mpq_init (rhs[i]);
    //mpq_set_d (rhs[0], 12.0);
    //mpq_set_d (rhs[1], 10.0);
    //mpq_set_d (rhs[1], -2.0);
    //mpq_set_d (rhs[1], 10);
    //mpq_set_d (rhs[1], -1);

    //for (i = 0; i < 3; i++) mpq_init (lower[i]);
    //mpq_set (lower[0], mpq_ILL_MINDOUBLE);
    //mpq_set (lower[1], mpq_ILL_MINDOUBLE);
    //mpq_set (lower[2], mpq_ILL_MINDOUBLE);

    //for (i = 0; i < 3; i++) mpq_init (upper[i]);
    //mpq_set (upper[0], mpq_ILL_MAXDOUBLE);
    //mpq_set (upper[1], mpq_ILL_MAXDOUBLE);
    //mpq_set (upper[2], mpq_ILL_MAXDOUBLE);

    ///*  CPXcopylpwnames  */

    //*p = mpq_QSload_prob ("small", 3, 5, cmatcnt, cmatbeg, cmatind, cmatval,
                      //QS_MAX, obj, rhs, sense, lower, upper, colnames,
                      //rownames);

    //if (*p == (mpq_QSprob) NULL) {
        //fprintf (stderr, "Unable to load the LP problem\n");
        //rval = 1;  goto CLEANUP;
    //}

//CLEANUP:

    //for (i = 0; i < 8; i++) mpq_clear (cmatval[i]);
    //for (i = 0; i < 3; i++) mpq_clear (obj[i]);
    //for (i = 0; i < 5; i++) mpq_clear (rhs[i]);
    //for (i = 0; i < 3; i++) mpq_clear (lower[i]);
    //for (i = 0; i < 3; i++) mpq_clear (upper[i]);

    //return rval;
//}

//int main()
//{
    //mpq_t x;
    //double dx;
    //mpq_init(x);
    //mpq_set_ui(x,7077085128725065,2251799813685248);
    //gmp_printf("Original rational number: x1 = %#40Qd\n",x);
    //dx = mpq_get_d(x);
    //printf("After rational to double using GMP functionality: x1 = %f\n",dx);
    //mpq_set_d(x,dx);
    //gmp_printf("After converting double to rational using GMP functionality x1 = %Qd\n",x);
    //dx = mpq_get_d(x);
    //printf("After rational to double using GMP functionality (again): x1 = %f\n",dx);
    //dx = 0.3333;
    //printf("Original double: x2 = %f\n",dx);
    //mpq_set_d(x,dx);
    //gmp_printf("After converting double to rational using GMP functionality x2 = %Qd\n",x);
    //dx = mpq_get_d(x);
    //printf("After rational to double using GMP functionality (again): x2 = %f\n",dx);
    //return 0;
//}
