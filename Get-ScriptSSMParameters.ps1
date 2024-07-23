

function Get-ScriptSSMParameters {

    param (
        [Parameter(Mandatory=$true, Position=0)]
        [AllowEmptyString()]
        [string]$Prefix,
        
        [Parameter(Mandatory=$true, Position=1)]
        [string[]]$ParameterNames,
        
        [Parameter(Mandatory=$false, Position=2)]
        [boolean]$WithDecryption
    )

  #  $ssmParameterPrefix = $Env:SSM_PARAMETER_PREFIX
#If (($ssmParameterPrefix) eq "") {
$ssmParameterPrefix = "/eResScripts"
#}

    $namePrefix = $ssmParameterPrefix + $Prefix

    $parameters = @{}
    Get-SSMParametersByPath -Path $namePrefix -WithDecryption $WithDecryption | ForEach-Object {
        $parameters[$_.Name.Substring($namePrefix.Length + 1)] = $_.Value
    }

    $ParameterNames | ForEach-Object {
        if (!$parameters.ContainsKey($_)) {
            throw "Parameter $($_) not found in SSM."
        }
    }

    $parameters
}
