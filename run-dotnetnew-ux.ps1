
# to run this script:
#  (new-object Net.WebClient).DownloadString('https://gist.githubusercontent.com/sayedihashimi/899ed1a47953ea6a45f60220687cfdd6/raw/0e8abc6baaefc9e69c9225a6f90fd667bc83b08f/run-dotnetnew-ux.ps1') | iex

# this file will be executed as a string
$scripturl = 'https://gist.githubusercontent.com/sayedihashimi/899ed1a47953ea6a45f60220687cfdd6/raw/7127b81d07a02fda4f2676e312329810bbf4696f/dotnet-new-ux.ps1'
# create temp folder if missing
$tempfilepath = (join-path $env:TEMP 'dotnetnewux\dotnet-new-ux.ps1' )
$temppath = ([System.IO.Path]::GetDirectoryName($tempfilepath))

if(-not (test-path $temppath)){
    new-item -Path $temppath -ItemType Directory
}

if(test-path $tempfilepath){
    remove-item -Path $tempfilepath
}

'Downloading script from [{0}] to [{1}]' -f $scripturl,$tempfilepath | Write-Output
Invoke-WebRequest -Uri $scripturl -OutFile $tempfilepath 
'Running script' | Write-Output
& $tempfilepath
