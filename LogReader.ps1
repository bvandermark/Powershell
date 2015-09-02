function Search-LogFiles{
	param(
		[Parameter(Position=1,ValueFromPipeline=$true)]
		[String[]]$path=$_,
        [String[]]$website=$null,
        [ValidateSet("W3SVC")]
        $logFormat="W3SVC"
	)
    
    foreach($site in $website){
        if((Get-Website $site) -ne $null){
            $siteInfo = Get-Website $site
            $siteId = $siteInfo.Id
            $logDir = ($siteInfo.LogFile.directory) + "\W3SVC" + $siteId
            if($logDir.Contains("%SystemDrive%")){
                $logDir = $logDir.Replace("%SystemDrive%", "$env:SystemDrive")
            }
            if(Test-Path $logDir){
                $path = gci $logDir | select -exp FullName
            }
        }
    }
	
	foreach($logFile in $path){
        if(Test-Path $logFile){
		    switch($logFormat){
                W3SVC{
                    $headers = ([System.IO.File]::ReadLines($logFile) | select -Index 3).split(" ") | ?{$_ -ne "#Fields:"}
                    foreach($line in [System.IO.File]::ReadLines($logFile)){
                        if($line.StartsWith("#Fields:")){
                            $headers = $line.split(" ") | ?{$_ -ne "#Fields:"}
                        }
                        elseif(-not $line.StartsWith("#")){
                            ConvertFrom-Csv -Delimiter " " -Header $headers -InputObject $line
                        }
                    }
                }
            }
	    }
        else{
            Write-Host "No file found at $($logFile). Please check file location and try again."
        }
    }
} 