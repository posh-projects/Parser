using module ColoredText
using module Parser

using module .\Rules.psm1


$text = @'
[19/01/16 00:00:00] WARNING : Warning Message
[19/01/16 00:00:00] ERROR : Error Message
[19/01/16 00:00:00] INFO : Info Message
'@

$global:calback = {
    param (
        [Parser.Node]$node,
        [Object]$writer
    )
    
    if ($node.fields.message_type -match 'ERROR')
    {
        # Send Email or SMS
    }
}

$rules = New-Object ParsingRules
$coloredText = New-Object ColoredText

$parser = [Parser]@{ output = $coloredText; rules = $rules }
$parser.parse([Parser]::split($text))