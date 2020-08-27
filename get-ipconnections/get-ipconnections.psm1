function Get-IpConnections {

    [cmdletbinding()]
    param(
        [Parameter()]
        [Int64]
        $MaxEvents,
        [switch]
        $Today,
        [switch]
        $LastHour,
        [switch]
        $Last2Hours,
        [switch]
        $Last3Hours,
        [switch]
        $Yesterday,
        [Parameter()]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,
	    [Parameter(	ValueFromPipeline = $true,
					ValueFromPipelineByPropertyName	= $true)]
        [Alias("MachineName", "PSComputerName", "CSName", "CsDNSHostName")]
	    [String[]]
        $ComputerName = @($env:COMPUTERNAME),
        [Parameter(	Position = 0,
					Mandatory = $true,
					ValueFromRemainingArguments)]
        [String]
        $IpAddress
    )
	
	Begin{
		$Filter = @{
			LogName="Security"
			ID=5156
			Data=$IpAddress
		}
	}

    Process {
	
	
	

			if($Yesterday){
				$Filter.add("starttime", (get-date).AddDays(-1).Date)
				$Filter.add("endtime", (get-date).Date.AddMinutes(-1))
            }

            if($Today){
                $Filter.add("starttime", (get-date).Day)
            }

            if($Last3Hours){
                $Filter.add("starttime", (get-date).AddHours(-3))
            }

            if($Last2Hours){
                $Filter.add("starttime", (get-date).AddHours(-2))
            }

            if($LastHour){
                $Filter.add("starttime", (get-date).AddHours(-1))
            }

		$Args = @{
			Credential = $Credential
			FilterHashtable = $Filter
		}
		
		if ($MaxEvents) { $Args.add("MaxEvents", $MaxEvents) }


	    ForEach ($name in $ComputerName){ 
            Get-WinEvent -ComputerName $name @Args | select-object -property id, timecreated,
			@{label="ProcessID"; expression={$_.Properties[0].Value}},
			@{label="Process Name"; expression={$_.Properties[1].Value}},
			@{label="Source IP"; expression={$_.Properties[3].Value}},
			@{label="Source Port"; expression={$_.Properties[4].Value}},
			@{label="Destination IP"; expression={$_.Properties[5].Value}},
			@{label="Destination Port"; expression={$_.Properties[6].Value}}
        }
    }
	
	End {}
}