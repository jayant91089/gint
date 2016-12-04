This is README.md file of ```gint```, which is a [GAP](http://www.gap-system.org/) package providing an interface to the [Gurobi Optimizer](http://www.gurobi.com/), which is a commercial optimization solver. It currently interfaces only to the linear programming part of Gurobi, via its C API. To install ```gint``` on a Linux computer - assuming that you have a working GAP installation, follow the steps below:

## Step 1:  Download the package
Navigate to the ```pkg``` directory of your GAP installation. If you have ```git``` installed, use

    git clone https://github.com/jayant91089/gint.git 
 
 else, 
		 

    wget https://github.com/jayant91089/gint/archive/master.zip
	unzip gint-master.zip
	mv -r gint-master itap

## Step 2: Install the package
Assuming that you have already obtained the Gurobi Optimizer (Either commercial or academic trial version), copy-paste the absolute paths to the ```include``` and ```lib``` directories of your Gurobi installation in the ```...../pkg/gint/Makefile``` to set the ```gurobilibpath``` and ```gurobiincludepath``` variables. Also edit the ```gmplibpath``` and ```gmpincludepath``` variables accordingly, based on where your [GMP](https://gmplib.org/) is installed. Finally, set the ```gurobiname``` variable based on what version of Gurobi you have at hand (e.g. ```gurobi65``` if your version number is 6.5). Now type the following inside the ```gint``` directory:

    make gint
Above command creates an executable called ```gint```, which serves as the middleman between GAP and Gurobi C API.  

## Step 3: End of installation##
You can now type the following in the gap console to start using ```gint```:

    gap> LoadPackage("gint");


