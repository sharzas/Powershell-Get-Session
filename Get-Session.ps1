Function Get-Session {
    
    #
    # This function either resolves session locally on this computer by running
    # qwinsta and objectifying the output, or parsing output from qwinsta
    # supplied via the $Sessions parameter, and doing the same.
    #

    Param (
        [Parameter(ValueFromPipeline=$true)]$Sessions # Must be output from Qwinsta
    )

    Begin {
        # Init session data variables
        #
        $SessionData = $null
        $SessionPipe = @()

        # If -Sessions supplied as named parameter, grab data from it.
        #
        if ($PSBoundParameters.ContainsKey("Sessions")) {
            $SessionData = @($Sessions)
        }
    }

    Process {
        # Grab any data from pipeline, and build array from it.
        #
        $SessionPipe += @(ForEach ($Session in $Sessions) {$Session})
    }

    End {
        if ($null -eq $SessionData) {
            #
            # -Sessions not supplied, check if we have pipeline data
            #
            if ($null -eq $SessionPipe -or $SessionPipe.Count -eq 0) {
                #
                # No pipeline data, run qwinsta an grab data from there.
                #
                $Sessions = qwinsta 
            } else {
                #
                # We have pipeline data, use that.
                #
                $Sessions = $SessionPipe
            }
        } else { 
            #
            # -Sessions supplied - use data from there.
            #
            $Sessions = $SessionData
        }

        # Replace top row with a generic one to overcome localization issues, and to
        # fit our needs.
        #
        $Sessions[0] = "SessionName,Username,Id,State,Type,Device,CurrentSession"

        # Trim each line, replace any spaces with ",", and build an object by using
        # the ConvertFrom-Csv
        #
        $Sessions = $Sessions|ForEach-Object {$_.Trim() -replace ("\s+",",")}|ConvertFrom-Csv

        # Normalize data, by ensuring correct values in the right properties.
        #
        ForEach ($Session in $Sessions) {
            if (!$Session.State) {
                $Session.State = $Session.Id
                $Session.Id = $Session.Username
                $Session.Username = ""
            }

            if ($Session.SessionName -match "^>(.+)") {
                $Session.SessionName = $Matches[1]
                $Session.CurrentSession = $true
            } else {
                $Session.CurrentSession = $false
            }
        }

        # Return session object.
        #
        Return $Sessions
    }
}