# Various OrderedDictionary Implementations
# with Initialization at declaration time.
# The OrderedHash is the recomended one!

using namespace System.Collections.Specialized


function orderedAppender { return [Ordered]@{ } }


class OrderedHash: OrderedDictionary
{
    OrderedHash([Scriptblock]$plainText)
    {
        foreach ($line in ($plainText -split [Environment]::NewLine).trim())
        {
            if (-not $line) { continue }
            [String]$key, [String]$value = $line.split([Char]61).trim()
            $value = Invoke-Expression($value)
            $this.add($key, $value)
        }
    }
}


class UtilityHelper
{
    static [OrderedDictionary]arrayToOrderedDict([Array]$arrayOfHashes)
    {
        $sortedDictionary = New-Object OrderedDictionary
        
        $arrayOfHashes | ForEach-Object {
            
            $item = $_.GetEnumerator()
            $item.MoveNext()
            
            $sortedDictionary[$item.key] = $item.value
        }
        return $sortedDictionary
    }
}

return

# Examples

$colors = (orderedAppender) +
@{ variable = [ConsoleColor]::Magenta } +
@{ equals = [ConsoleColor]::Darkgray } +
@{ value = [ConsoleColor]::Yellow }



$colors = [UtilityHelper]::arrayToOrderedDict((
    @{ variable = [ConsoleColor]::Magenta },
    @{ equals = [ConsoleColor]::Darkgray },
    @{ value = [ConsoleColor]::Yellow }
))


$colors = [OrderedHash]{
    variable = [ConsoleColor]::Magenta
    equals = [ConsoleColor]::Darkgray
    value = [ConsoleColor]::Yellow
}

Write-Host ($colors | Format-List | Out-String)