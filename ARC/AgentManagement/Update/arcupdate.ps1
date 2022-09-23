


    [CmdletBinding()]
    param (
        [string]$OutFile,
        [string]$AltDownload,
        [string]$Proxy    
    )
    
    $ErrorActionPreference = 'Stop'
    $ProgressPreference = 'SilentlyContinue'
    $refVersion = [version] '4.6'
    
    $global:errorcode="AZCM0150"
    $msifile = 'AzureConnectedMachineAgent.msi'
    
    function Which-MSIVersion {
        param (
            [Parameter(Mandatory = $true, HelpMessage = 'Specifies path to MSI file.')][ValidateScript({
            if ($_.EndsWith('.msi')) {
                $true
            } else {
                throw ("{0} must be an '*.msi' file." -f $_)
            }
        })]
        [String[]] $msifile
        )
    
        $invokemethod = 'InvokeMethod'
        try {
    
            #calling com object
            $FullPath = (Resolve-Path -Path $msifile).Path
            $windowsInstaller = New-Object -ComObject WindowsInstaller.Installer
    
            ## opening database from file
            $database = $windowsInstaller.GetType().InvokeMember(
                'OpenDatabase', $invokemethod, $Null, 
                $windowsInstaller, @($FullPath, 0)
            )
    
            ## select productversion from database
            $q = "SELECT Value FROM Property WHERE Property = 'ProductVersion'"
            $View = $database.GetType().InvokeMember(
                'OpenView', $invokemethod, $Null, $database, ($q)
            )
    
            ##execute
            $View.GetType().InvokeMember('Execute', $invokemethod, $Null, $View, $Null)
    
            ## fetch
            $record = $View.GetType().InvokeMember(
                'Fetch', $invokemethod, $Null, $View, $Null
            )
    
            ## write to variable
            $productVersion = $record.GetType().InvokeMember(
                'StringData', 'GetProperty', $Null, $record, 1
            )
    
            $View.GetType().InvokeMember('Close', $invokemethod, $Null, $View, $Null)
    
    
            ## return productversion
            return $productVersion
    
        }
        catch {
            throw 'Failed to get MSI file version the error was: {0}.' -f $_
        }
    }
    
    ###
    try {
        # Download the package
        Write-Verbose -Message "Downloading agent package" -Verbose
        $TlsVersions = [enum]::GetNames('System.Net.SecurityProtocolType') | Where-Object { $_ -ge 'Tls12' }
        $TlsVersions.ForEach({
            [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor $_
        })
        try {
            if ($AltDownload) {
                if ($Proxy) {
                    Invoke-WebRequest -UseBasicParsing -Proxy $Proxy -Uri $AltDownload -OutFile AzureConnectedMachineAgent.msi
                } else {
                    Invoke-WebRequest -UseBasicParsing -Uri $AltDownload -OutFile AzureConnectedMachineAgent.msi
                }
        } else {
                if ($Proxy) {
                    Invoke-WebRequest -UseBasicParsing -Proxy $Proxy -Uri https://aka.ms/AzureConnectedMachineAgent -OutFile AzureConnectedMachineAgent.msi	
                } else {
                    Invoke-WebRequest -UseBasicParsing -Uri https://aka.ms/AzureConnectedMachineAgent -OutFile AzureConnectedMachineAgent.msi	
                }
            }
        }
        catch {
            $errorcode="AZCM0148"
            throw "Invoke-WebRequest failed: $_"
        }
        #CHECK VERSION
        $installedversion =(azcmagent.exe version).Replace('azcmagent version  ','')
        [string]$newversion = Which-MSIVersion -msifile AzureConnectedMachineAgent.msi
    
        If([System.Version]$newversion -gt [System.Version]$installedversion)
        {# Install the package
            echo "Installing"
            Write-Verbose -Message "Installing agent package" -Verbose
            $exitCode = (Start-Process -FilePath msiexec.exe -ArgumentList @("/i", "AzureConnectedMachineAgent.msi" , "/l*v", "installationlog.txt", "/qn") -Wait -Passthru).ExitCode
            if ($exitCode -ne 0) {
                $message = (net helpmsg $exitCode)        
                $errorcode="AZCM0149"
                throw "Upgrade failed: $message See installationlog.txt for additional details."
        }
    }
        else {
            Write-Verbose -Message "current version is up to date" -Verbose
            #Remove-Item .\AzureConnectedMachineAgent.msi -Force
        }
    
    
        # Check if we need to set proxy environment variable
        if ($Proxy) {
            Write-Verbose -Message "Setting proxy configuration: $Proxy" -Verbose
            & "$env:ProgramW6432\AzureConnectedMachineAgent\azcmagent" config set proxy.url ${Proxy}
        }
        
    } catch {
        if ($OutFile) {
            [ordered]@{
                status  = "failed"
                error = [ordered]@{
                    code = $errorcode
                    message = $_.Exception.Message
                }
            } | ConvertTo-Json | Out-File $OutFile
        }
        Write-Error $_ -ErrorAction Continue
        exit 1
    }
    
    # Installation was successful if we got this far
    if ($OutFile) {
        [ordered]@{
            status  = "success"
            message = "Installation of azcmagent completed successfully"
        } | ConvertTo-Json | Out-File $OutFile
    }
    
    Write-Host "Installation of azcmagent completed successfully"
    
    exit 0
    
