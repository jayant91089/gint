

  #############################################################################
  ##
  ##  PackageInfo.g for the package `gint'           Jayant Apte
  ##
  ##  This is a GAP readable file. Of course you can change and remove all
  ##  comments as you like.
  ##
  ##  This file contains meta-information on the package. It is used by
  ##  the package loading mechanism and the upgrade mechanism for the
  ##  redistribution of the package via the GAP website.
  ##
  ##  Entries that are commented out are based on the EDIM package and
  ##  are there for purposes of illustration of a possible alternative,
  ##  especially in the case where the Example package's entry is blank.
  ##
  ##  For the LoadPackage mechanism in GAP >= 4.5 the minimal set of needed
  ##  entries is .PackageName, .Version, and .AvailabilityTest, and an error
  ##  will occur if any of them is missing. Other important entries are
  ##  .PackageDoc and .Dependencies. The other entries are relevant if the
  ##  package will be distributed for other GAP users, in particular if it
  ##  will be redistributed via the GAP Website.
  ##
  ##  With a new release of the package at least the entries .Version, .Date
  ##  and .ArchiveURL must be updated.

  SetPackageInfo( rec(

  ##  This is case sensitive, use your preferred spelling.
  ##
  PackageName := "gint",

  ##  This may be used by a default banner or on a Web page, should fit on
  ##  one line.
  Subtitle := "An Interface to Gurobi Optimizer",

  ##  See '?Extending: Version Numbers' in GAP help for an explanation
  ##  of valid version numbers. For an automatic package distribution update
  ##  you must provide a new version number even after small changes.
  Version := "1.0",
  ##  Release date of the current version in dd/mm/yyyy format.
  ##
  Date := "23/01/2016",
  ##  Optional: if the package manual uses GAPDoc, you may duplicate the
  ##  version and the release date as shown below to read them while building
  ##  the manual using GAPDoc facilities to distibute documents across files.
  ##  <#GAPDoc Label="PKGVERSIONDATA">
  ##  <!ENTITY VERSION "3.4.2">
  ##  <!ENTITY RELEASEDATE "02 June 2012">
  ##  <#/GAPDoc>

  PackageWWWHome :="https://github.com/jayant91089/gint",


  ##  URL of the archive(s) of the current package release, but *without*
  ##  the format extension(s), like '.tar.gz' or '-win.zip', which are given next.
  ##  The archive file name *must be changed* with each version of the archive
  ##  (and probably somehow contain the package name and version).
  ##  The paths of the files in the archive must begin with the name of the
  ##  directory containing the package (in our "example" probably:
  ##  example/init.g, ...    or example-3.3/init.g, ...  )
  #
  ArchiveURL := ~.PackageWWWHome,

  ##  All provided formats as list of file extensions, separated by white
  ##  space or commas.
  ##  Currently recognized formats are:
  ##      .tar.gz    the UNIX standard
  ##      .tar.bz2   compressed with 'bzip2', often smaller than with gzip
  ##      -win.zip   zip-format for DOS/Windows, text files must have DOS
  ##                 style line breaks (CRLF)
  ##
  ##  In the future we may also provide .deb or .rpm formats which allow
  ##  a convenient installation and upgrading on Linux systems.
  ##
  # ArchiveFormats := ".tar.gz", # the others are generated automatically
  ArchiveFormats := ".zip",


  Persons := [
  rec(
    LastName      := "Apte",
    FirstNames    := "Jayant",
    IsAuthor      := true,
    IsMaintainer  := true,
    Email         := "jayant91089@gmail.com",
    WWWHome       := "https://sites.google.com/site/jayantapteshomepage/",
    PostalAddress := Concatenation( [
                       "Department of Electrical and Computer Engineering\n",
                       "Drexel University\n",
                       "Philadelphia, PA 19104\n"] ),
    Place         := "Philadelphia",
    Institution   := "Drexel University"
  )
  # provide such a record for each author and/or maintainer ...

  ],

  ##  Status information. Currently the following cases are recognized:
  ##    "accepted"      for successfully refereed packages
  ##    "submitted"     for packages submitted for the refereeing
  ##    "deposited"     for packages for which the GAP developers agreed
  ##                    to distribute them with the core GAP system
  ##    "dev"           for development versions of packages
  ##    "other"         for all other packages
  ##
  # Status := "accepted",
  Status := "dev",

  ##  You must provide the next two entries if and only if the status is
  ##  "accepted" because is was successfully refereed:
  # format: 'name (place)'
  # CommunicatedBy := "Mike Atkinson (St. Andrews)",
  #CommunicatedBy := "",
  # format: mm/yyyy
  # AcceptDate := "08/1999",
  #AcceptDate := "",

  ##  For a central overview of all packages and a collection of all package
  ##  archives it is necessary to have two files accessible which should be
  ##  contained in each package:
  ##     - A README file, containing a short abstract about the package
  ##       content and installation instructions.
  ##     - The PackageInfo.g file you are currently reading or editing!
  ##  You must specify URLs for these two files, these allow to automate
  ##  the updating of package information on the GAP Website, and inclusion
  ##  and updating of the package in the GAP distribution.
  #
  README_URL :=
    Concatenation( ~.PackageWWWHome, "/blob/master/README" ),
  PackageInfoURL :=
    Concatenation( ~.PackageWWWHome, "/blob/master/PackageInfo.g" ),

  ##  Here you  must provide a short abstract explaining the package content
  ##  in HTML format (used on the package overview Web page) and an URL
  ##  for a Webpage with more detailed information about the package
  ##  (not more than a few lines, less is ok):
  ##  Please, use '<span class="pkgname">GAP</span>' and
  ##  '<span class="pkgname">MyPKG</span>' for specifing package names.
  ##
  # AbstractHTML := "This package provides  a collection of functions for \
  # computing the Smith normal form of integer matrices and some related \
  # utilities.",
  AbstractHTML :=
    "The <span class=\"pkgname\"gint</span> An Interface to the Gurobi Optimizer",
  PackageDoc := rec(
    # use same as in GAP
    BookName  := "gint",
    # format/extension can be one of .tar.gz, .tar.bz2, -win.zip, .zoo.
    ArchiveURLSubset := ["doc"],
    HTMLStart := "doc/chap0.html",
    PDFFile   := "doc/manual.pdf",
    # the path to the .six file used by GAP's help system
    SixFile   := "doc/manual.six",
    # a longer title of the book, this together with the book name should
    # fit on a single text line (appears with the '?books' command in GAP)
    # LongTitle := "Elementary Divisors of Integer Matrices",
    LongTitle := "An Interface to the Gurobi Optimizer",
  ),


  ##  Are there restrictions on the operating system for this package? Or does
  ##  the package need other packages to be available?
  Dependencies := rec(
    # GAP version, use the version string for specifying a least version,
    # prepend a '=' for specifying an exact version.
    GAP := "4.5.3",

    # list of pairs [package name, version], package name is case
    # insensitive, exact version denoted with '=' prepended to version string.
    # without these, the package will not load
    # NeededOtherPackages := [["GAPDoc", "1.5"]],
    NeededOtherPackages := [["GAPDoc", "1.5"]],

    # list of pairs [package name, version] as above,
    # these package are will be loaded if they are available,
    # but the current package will be loaded if they are not available
    # SuggestedOtherPackages := [],

    SuggestedOtherPackages := [],

    # *Optional*: a list of pairs as above, denoting those needed packages
    # that must be completely loaded before loading of the current package
    # is started (if this is not possible due to a cyclic dependency
    # then the current package is regarded as not loadable);
    # this component should be used only if functions from the needed packages
    # in question are called (or global lists or records are accessed)
    # while the current package gets loaded
    # OtherPackagesLoadedInAdvance := [],

    # needed external conditions (programs, operating system, ...)  provide
    # just strings as text or
    # pairs [text, URL] where URL  provides further information
    # about that point.
    # (no automatic test will be done for this, do this in your
    # 'AvailabilityTest' function below)
    # ExternalConditions := []
    ExternalConditions := []

  ),

  ##  Provide a test function for the availability of this package.
  ##  For packages containing nothing but GAP code, just say 'ReturnTrue' here.
  ##  For packages which may not work or will have only partial functionality,
  ##  use 'LogPackageLoadingMessage( PACKAGE_WARNING, ... )' statements to
  ##  store messages which may be viewed later with `DisplayPackageLoadingLog'.
  ##  Do not call `Print' or `Info' in the `AvailabilityTest' function of the
  ##  package.
  ##
  ##  With the package loading mechanism of GAP >=4.4, the availability
  ##  tests of other packages, as given under .Dependencies above, will be
  ##  done automatically and need not be included in this function.
  ##
  #AvailabilityTest := ReturnTrue,
  AvailabilityTest := function()
      #local path, file;
      # test for existence of the compiled binary
      #path:= DirectoriesPackagePrograms( "example" );
      #file:= Filename( path, "hello" );
      #if file = fail then
      #  LogPackageLoadingMessage( PACKAGE_WARNING,
      #      [ "The program `hello' is not compiled,",
      #        "`HelloWorld()' is thus unavailable.",
      #        "See the installation instructions;",
      #        "type: ?Installing the Example package" ] );
      #fi;
      # if the hello binary was vital to the package we would return
      # the following ...
      # return file <> fail;
      # since the hello binary is not vital we return ...
      return true;
    end,

  ##  *Optional*: path relative to package root to a file which
  ##  shall be read immediately before the package is loaded.
  #PreloadFile := "...",

  ##  *Optional*: the LoadPackage mechanism can produce a default banner from
  ##  the info in this file. If you are not happy with it, you can provide
  ##  a string here that is used as a banner. GAP decides when the banner is
  ##  shown and when it is not shown (note the ~-syntax in this example).
  PackageDoc := rec(
    BookName  := "gint",
    ArchiveURLSubset := ["doc"],
    HTMLStart := "doc/chap0.html",
    PDFFile   := "doc/manual.pdf",
    SixFile   := "doc/manual.six",
    LongTitle := "An Interface to the Gurobi Optimizer",
    Autoload  := false
  ),
  BannerString := Concatenation(
"  _______ _________ _       _________    __       _______ \n",
" (  ____ \\\\__   __/( (    /|\\__   __/   /  \\     (  __   )\n",
" | (    \\/   ) (   |  \\  ( |   ) (      \\/) )    | (  )  |\n",
" | |         | |   |   \\ | |   | |        | |    | | /   |\n",
" | | ____    | |   | (\\ \\) |   | |        | |    | (/ /) |\n",
" | | \\_  )   | |   | | \\   |   | |        | |    |   / | |\n",
" | (___) |___) (___| )  \\  |   | |      __) (_ _ |  (__) |\n",
" (_______)\\_______/|/    )_)   )_(      \\____/(_)(_______)\n",
"                                                             \n",
      "Loading  gint ", ~.Version, "\n",
      "by ",
      JoinStringsWithSeparator( List( Filtered( ~.Persons, r -> r.IsAuthor ),
                                      r -> Concatenation(
          r.FirstNames, " ", r.LastName, " (", r.WWWHome, ")\n" ) ), "   " ),
      "For help, type: ?gint \n",
"-----------------------------------------------------------------------\n" )
      ));
