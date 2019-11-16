Function Get-Session {
    
    # Get input from qwinsta (we use this to resolve sessions on current computer!)
    #
    $Sessions = qwinsta

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
