[cmdletbinding()]
param()

# to run this script:
#  (new-object Net.WebClient).DownloadString("https://gist.githubusercontent.com/sayedihashimi/899ed1a47953ea6a45f60220687cfdd6/raw/b3ad6ab230b5c4a9cf5b39d3142fc7b36df8c54f/run-dotnetnew-ux.ps1") | iex

function StartDefault{
    [cmdletbinding()]
    param()
    process{

@'
~/projects/> mkdir mynewproj                                             |
~/projects/> cd mynewproj                                                |
~/projects/mynewproj/> dotnet new                                        |
'@ | Write-Host -ForegroundColor DarkYellow -BackgroundColor Black

        "`r`nFiles will be added in the current working directory" | Write-Host 

        ShowTemplateList
        "? What type of project do you want to create? [1]: " | Write-Host -NoNewline

        $id = Read-Host
        if([string]::IsNullOrWhiteSpace($id)){
            $id = '1'
        }
#        '' | Write-Host
        switch ($id) {
            1 { StartClassLib }
            2 { StartConsole }
            3 { StartWeb }
            4 { StartWebApi }
            5 { StartUnittest }
            Default {'throw unknown option'}
        }
    }
}

function GetProjectName{
    [cmdletbinding()]
    param(
        [string]$defaultProjName = 'Project1'
    )
    process{
        "`r`nEnter a project name [{0}]: " -f $defaultProjName | Write-Host -NoNewline
        $projName = Read-Host
        if([string]::IsNullOrWhiteSpace($projName)){
            $projName = $defaultProjName
        }        
        '    {0}' -f $projName | Write-Host

        # return the project name
        $projName
    }
}

function GetUnittestOption{
    [cmdletbinding()]
    param()
    process{
@'

Unit test framework options:
    1. XUnit                            [xunit]
    2. MSTest                           [mstest]

'@ | Write-Host

    '? Select a unit test framework [1]: ' | Write-Host -NoNewline
        $value = Read-Host
        if([string]::IsNullOrWhiteSpace($value)){
            $value = '1'
        }

        $result = @{
            Id = [int]$value
            Value = [string]''
            Key = [string]''
        }

        switch ($value) {
            '1' { 
                $result.Value = 'XUnit'
                $result.Key = 'xunit'
             }
            '2' { 
                $result.Value = 'MSTest'
                $result.Key = 'mstest'
             }
            Default {
                throw ('Unknown option [{0}]' -f $value)
             }
        }

        $result
    }
}

function GetAuthOption{
    [cmdletbinding()]
    param(
        [ValidateSet('web','api')]
        [string]$weborapi = 'web'
    )
    process{

        if('web'.Equals($weborapi)) {
@'

Auth options:
    1. No Auth                          [noauth]
    2. Individual Auth                  [indauth]
    3. Windows Auth                     [winauth] 

'@ | Write-Host
        }
        else{
@'

Auth options:
    1. No Auth                          [noauth]
    2. Windows Auth                     [winauth] 

'@ | Write-Host
        }

        '? Select an authentication method [1]: ' | Write-Host -NoNewline
        $value = Read-Host
        if([string]::IsNullOrWhiteSpace($value)){
            $value = '1'
        }

        $result = @{
            Id = [int]$value
            Value = [string]''
            Key = [string]''
        }

        if('web'.Equals($weborapi)) {
            switch($value){
                '1' { 
                    $result.Value = 'No Auth'
                    $result.Key = 'noauth' 
                }
                '2' { 
                    $result.Value = 'Individual Auth'
                    $result.Key = 'indauth' 
                }
                '3' { 
                    $result.Value = 'Windows Auth'
                    $result.Key = 'winauth' 
                }
            }
        }
        else{
            switch($value){
                '1' { 
                    $result.Value = 'No Auth'
                    $result.Key = 'noauth' 
                }
                '2' { 
                    $result.Value = 'Windows Auth'
                    $result.Key = 'winauth' 
                }
            }
        }
        # return the result
        $result
    }
}

function PrintCreatingFiles{
    [cmdletbinding()]
    param(
        [string]$projectname = 'Project1',
        [string]$sampleFilename = 'Startup.cs'
    )
    process{
        @'

  Creating file ~/projects/mynewproj/{0}.csproj
  Creating file ~/projects/mynewproj/{1}
  Creating file ~/projects/mynewproj/...
  Created project "{0}" in ~/projects/mynewproj
'@ -f $projectname,$sampleFilename | Write-Output
    }
}

function StartConsole {
    [cmdletbinding()]
    param()
    process{
        ' Console app' | Write-Host -ForegroundColor Cyan
        $projectname = GetProjectName -defaultProjName 'ConsoleApp'
        $path = ('' -f $projectname)
        PrintCreatingFiles -projectname $projectname
        PrintNextSteps -templateName 'console' -projectname $projectname
    }
}

function StartClassLib {
    [cmdletbinding()]
    param()
    process{
        '  Class library template selected' | Write-Host
        $projectname = GetProjectName -defaultProjName 'ClassLibrary'
        $path = ('' -f $projectname)
        PrintCreatingFiles -projectname $projectname -sampleFilename 'Class1.cs'
        PrintNextSteps -templateName 'classlib' -projectname $projectname
    }
}

function StartWeb {
    [cmdletbinding()]
    param()
    process{
        "  Web App template selected" | Write-Host
        $projectname = GetProjectName -defaultProjName 'WebApplication'
        $auth = GetAuthOption

        "  Selected {0} [{1}]" -f $auth.Value,$auth.Key | Write-Host

        PrintCreatingFiles -projectname $projectname
        PrintNextSteps -auth $auth -templateName web -projectname $projectname
    } 
}

function StartWebApi {
    [cmdletbinding()]
    param()
    process{
        '  Web API  template selected' | Write-Host
        $projectname = GetProjectName -defaultProjName 'WebApi'
        $auth = GetAuthOption -weborapi api

        "  Selected {0} [{1}]" -f $auth.Value,$auth.Key | Write-Host

        PrintCreatingFiles -projectname $projectname -sampleFilename 'Controllers/ValuesController.cs'
        PrintNextSteps -auth $auth -templateName webapi -projectname $projectname
    }
}

function StartUnittest{
    [cmdletbinding()]
    param()
    process{
        '  Unittest  template selected' | Write-Host
        $projectname = GetProjectName -defaultProjName 'Unittest'
        $unittest = GetUnittestOption

        "  Selected {0} [{1}]" -f $unittest.Value,$unittest.Key | Write-Host

        PrintCreatingFiles -projectname $projectname -sampleFilename 'Unittest1.cs'
        PrintNextSteps -templateName unittest -projectname $projectname -runortest test
    }
}

function PrintNextSteps{
    [cmdletbinding()]
    param(
        [Parameter(Position=0)]
        $auth,

        [Parameter(Position=1)]
        [string]$templateName,

        [Parameter(Position=2)]
        [string]$projectname,

        [Parameter(Position=3)]
        [ValidateSet('run','test')]
        [string]$runortest = 'run'
    )
    process{
@'

  Another project can be created with: ~/>dotnet new {0} --name "{1}"
'@ -f $templatename, $projectname | Write-Host -NoNewline
    if( $auth -ne $null){
        ' -authtype {0}' -f $auth.Key | Write-Host
    }
    else{
        '' | Write-Host
    }


        "`r`n  You can use the following commands to get going" | Write-Host
@'
      dotnet restore
      dotnet build (optional, build will also happen when it's run)
'@ | Write-Host

    if( ($auth -ne $null) -and ('indauth'.Equals($auth.Key)) ){
        '      dotnet ef database update (to create the database for the project)' | Write-Host
    }
    '      dotnet {0}' -f $runortest | Write-Host
    }
}



function StartHelp{
    [cmdletbinding()]
    param()
    process{
@'

~/projects/> dotnet new --help

Usage:
    dotnet new
    dotnet new <templatename> [-n|--name <Projectname>] [[--<property> <value>] [--<property> <value>]]'
    dotnet new <command>

    Arguments:
        <templatename>                                  The name of the template to use
        -n|--name <ProjectName>                         The name of the new project, created in the current folder if not specified
        -<p>|--<property> <value>                       Template specific properties. Use "dotnet new <templatename> --help" for more info.
    
    Commands:
        list                                            List installed templates
'@ | Write-Host        
    }
}

function StartHelpWeb{
    [cmdletbinding()]
    param()
    process{
@'

~/projects/> dotnet new web --help

Usage:
    dotnet new web
    dotnet new web [-n|--name <projectname>] [-at|--authtype <noauth|indauth|winauth>]'

    Arguments:
        -n|--name <projectname>                         The name of the new project, created in the current folder if not specified

    Template Properties:
        authtype                                        Authentication option for the template.

'@ | Write-Host        
    }
}

function ShowTemplateList{
    [cmdletbinding()]
    param(
        [switch]$showListCommand
    )
    process{
        if($showListCommand){
            '~/projects/> dotnet new list'
        }
@'

 Templates
  ------------------------------------------------------------------------
  1. Class Library                                  [classlib]
  2. Console App                                    [console]
  3. Web App                                        [web]
  4. Web API                                        [webapi]
  5. Unit test                                      [unittest]

'@ | Write-Output
    }
}

function PromptForTemplateSelection{
    [cmdletbinding()]
    param()
    process{
        ShowTemplateList
        switch ($id) {
            condition {  }
            Default {}
        }
    }
}

function PrintNewSection{
    [cmdletbinding()]
    param(
        [string]$message
    )
    process{
@'
******************************************************************
**** ~/> {0}
******************************************************************
'@ -f $message | Write-Host -ForegroundColor Cyan
    }
}

function EndNewSection{
    [cmdletbinding()]
    param(
        [string]$message
    )
    process{
        @'

Press any key to start: > {0}
'@ -f $message | Write-Host -ForegroundColor Cyan
        Read-Host
    }
}

function StartDemo{
    [cmdletbinding()]
    param()
    process{
        $stop = $false
while($stop -ne $true){

@'

|------------------------------------------------------------------------|
| dotnet new CLI user experience demo                                    |
|                                                                        |
| What command do you want to try out [1]?                               |
|  1: dotnet new                                                         |
|  2: dotnet new --help                                                  |
|  3. dotnet new list                                                    |
|  4: dotnet new web                                                     |
|  5: dotnet new web --help                                              |
|  Q. Quit                                                               |
|------------------------------------------------------------------------|

'@ | Write-Host -BackgroundColor Black -ForegroundColor White

': ' | Write-Host -BackgroundColor Black -ForegroundColor White -NoNewline

    $item = Read-Host
    '' | Write-Host # blank line 
    if([string]::IsNullOrWhiteSpace($item)){
        $item = '1'
    }
    switch ($item) {
        '1' {
            PrintNewSection -message 'dotnet new'
            StartDefault 
        }
        '2' { 
            PrintNewSection -message 'dotnet new --help'
            StartHelp
        }
        '3' { 
            PrintNewSection -message 'dotnet new list'
            ShowTemplateList -showListCommand
        }
        '4' { 
            PrintNewSection -message 'dotnet new web'
            StartWeb
        }
        '5' { 
            PrintNewSection -message 'dotnet new web --help'
            StartHelpWeb
        }
        Default {
            $stop = $true
        }
    }
}
    }
}

# Begin script
cls
StartDemo













