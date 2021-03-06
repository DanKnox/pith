Feature: unrecognised input files are copied into output intact

  I want any unrecognised file to be copied into the site verbatim
  So that I can mix dynamic and static content
  
Scenario: text file

  Given input file "resource.txt" contains
    """
    Blah de blah
    """
    
  When I build the site
  
  Then output file "resource.txt" should contain
    """
    Blah de blah
    """

Scenario: file in subdirectory

  Given input file "blah/resource.txt" contains
    """
    Blah de blah
    """
    
  When I build the site
  
  Then output file "blah/resource.txt" should contain
    """
    Blah de blah
    """

Scenario: dot-file

  Given input file ".htaccess" contains
    """
    DirectoryIndex index.html
    """
    
  When I build the site
  
  Then output file ".htaccess" should contain
    """
    DirectoryIndex index.html
    """

Scenario: extension-less filename

  Given input file "foo" contains "bar"
  When I build the site
  Then output file "foo" should contain "bar"
