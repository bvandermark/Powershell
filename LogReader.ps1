function LogReader{
	param(
		[Parameter(Mandatory=$True,Position=1,ValueFromPipeline=$true)]
		$path=$_
	)
	
	if(Test-Path $path){
		$rawLog = [System.IO.File]::ReadAllLines($path)
		$headers = $rawLog[3].split(" ") | ?{$_ -ne "#Fields:"}
		$logData = Import-Csv -Delimiter " " -Header $headers -Path $path | ?{$_.date -notlike "#*"}
		$logData
	}
}