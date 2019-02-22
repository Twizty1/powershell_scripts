###########################################
###
##
#Transcription Log Script
##
###
###########################################

#Change DocsPath to the path you want to check against
$DocsPath = "c:\scripts\"
$Today = Get-Date -UFormat "%m/%d/%Y"

#Change this to the dir path you want the generated HTML file to be stored in
$LogFile = "c:\scripts\log-report.html"

#Email Variables  CHANGE THESE!
$emailTo = "YOUREMAIL@GOESHERE"
$emailFrom = "SENDEREMAIL@GOESHERE"
$emailSubject = "File Log for $($Today)"
$SmtpServer = "EMAIL SERVER GOES HERE"

#If setting a manual printer, change line 36 to Out-Printer -Name $LogPrinter -InputObject $Docs.
#Otherwise it will use the users default printer.
$LogPrinter = "PATH TO PRINTER IF YOU SET MANUALLY"

#Gets a list of all docs created in the last 24hrs.
$Docs = Get-ChildItem -Path "$($DocsPath)" | Where-Object { $_.CreationTime -gt (Get-Date).AddDays(-1) } | select Name,CreationTime

#Converts output from above into HTML and saves file.
$Docs | ConvertTo-Html -Property Name, CreationTime | out-file $LogFile

#Sets body of email to be the HTML file that was just created.
$FullBody = Get-Content -Path c:\scripts\log-report.html | Out-String

#Prints the list of files created in last 24hrs to default printer.
Out-Printer -InputObject $Docs

#Sends email with list of files created in last 24hrs to recipient defined above.
Send-MailMessage -To $emailTo -From $emailFrom -Subject $emailSubject -Body $FullBody -BodyAsHtml -SmtpServer $SmtpServer
