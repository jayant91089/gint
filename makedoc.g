LoadPackage( "AutoDoc" );

AutoDoc( "gint" : scaffold := true );

PrintTo( "VERSION", PackageInfo( "gint" )[1].Version );

QUIT;
