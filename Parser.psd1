@{
    RootModule = 'Parser.psm1'
    ModuleVersion = '1.0.14'
    GUID = '95ce2d72-4160-417a-b978-f0bc15d18c4e'
    Author = 'n8tb1t'
    CompanyName = 'n8tb1t'
    Copyright = '(c) 2016 n8tb1t, licensed under MIT License.'
    Description = 'A Simple yet powerful PowerShell plain text parser. The main goal of this module is to process the plain text line by line, highlight and transform it, and to perform various callback events.'
    PowerShellVersion = '5.0'
    HelpInfoURI = 'https://github.com/n8tb1t/Parser/blob/master/README.md'
    RequiredModules = @('ColoredText')
    NestedModules = @('Src\Node.psm1', 'Src\OrderedHash.psm1')
    FunctionsToExport = ''
    PrivateData = @{
        PSData = @{
            Tags = @('parser', 'log', 'color', 'colored', 'ast', 'regex')
            LicenseUri = 'https://github.com/n8tb1t/Parser/blob/master/LICENSE'
            ProjectUri = 'https://github.com/n8tb1t/Parser'
            IconUri = 'https://raw.githubusercontent.com/n8tb1t/Parser/master/Docs/Logo/parser.png'
            ReleaseNotes = '
Check out the project site for more information:
https://github.com/n8tb1t/Parser'
        }
        DevTools = @{
            Dependencies = (
                @{
                    deploy = $false
                    name = 'ColoredText'
                }
            )
        }
    }

}
