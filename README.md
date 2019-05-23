# <img src="/Docs/Logo/parser.png" alt="Logo" width="48" align="left"/> Parser

[![Powershellgallery Badge][psgallery-badge]][psgallery-status]

<img src="/Docs/Logo/github.png" alt="Logo" width="150" align="left"/>

Very powerful text parser with color highlighting.

The main goal of this module is to process the plain text line by line,
highlight and transform it, and perform various callback events.
If you need a multiline solution please take a look at PowerShell
built-in `Abstract Syntax Tree` parser.

For an advanced example take a look at:
[Debug](https://github.com/n8tb1t/Debug)
it's a robust and extremely helpful module for printing and highlighting PowerShell objects for debugging purposes.

## Install:

```powershell
PS> Install-Module Parser
```

The Module is using:
- [ColoredText](https://github.com/n8tb1t/ColoredText) - for highlighting.

Projects using `Parser`:
- [Debug](https://github.com/n8tb1t/Debug).

## Features:

 - Implemented with the latest powershell 5 features (Classes, Enums, etc.)
 - Custom callbacks.
 - Fully adjustable.
 - Unlimited rules nesting.
 - Lots of syntactic sugar.
 - Simplified syntax for rapid development.
 - Advanced API with strong typing, inheritance and extensibility.
 - extremely adjustable rules system, the result could be achieved in many different ways, your imagination is the only limit

## Disclaimer:

In order to get the most out of color highlighted modules, and enjoy their full potential,<br>
it is highly recommended to use the [ConEmu console](https://conemu.github.io/) with the [Oceans16 theme](https://github.com/joonro/ConEmu-Color-Themes)!<br>
Also, check out the other numerous themes over there, maybe you'll find one you like even better!

## Examples:

The example is taking a chunk of plain text,
and parsing it line by line. It highlights, multiple parts of the string,
replaces specified parts with a custom text, formats paddings. and calls
custom callbacks if you want for example to sand an email or to emit specific action on a pattern match.

See the [Test rules](https://github.com/n8tb1t/Parser/blob/master/Tests/Rules.psm1) for a working example.

```powershell
PS> powershell -NoProfile .\Tests\Parser.Test.ps1
```
![test](/Docs/Screenshots/text.png)

```powershell
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
```
## Callbacks

Each rule could have a callback. you can define callbacks inside the rules class, or in a global namespace.


```powershell
# in this callback, we replace the matched chunk of the text with its aligned version to 9 characters.
# And then adding white foreground to it.
[void]rule002_calback($node, $writer)
{
    $node.fields.type_highlighted = '{0, 9}' -f $node.fields.type_highlighted
    $node.setWriter('type_highlighted', $writer.invoke().on().white())
}
```

## Rules

Rules are organized in a simple hash table.
You can have unlimited nested rules.
Each rule is parsed one after another like a waterfall.
You can set a callback to add custom events and to tweak
the parsing even more.

there are two types of rules `[RegexStrategy]::Split` and regular ones, the regular rules are mapped to the previous match fields, let's say, we parse the string, divide it into 3 parts, left, center and right. Then in the next rule, we can parse each part to, even more, parts by mapping to it's field name.

You can define multiple `[RegexStrategy]::Split` rules, but note, that only one such rule is allowed per field so if you apply the `[RegexStrategy]::Split` rule to a field, it should be the last rule for that field.

```powershell
using module Parser

class ParsingRules
{
    [Array]$rules = (@{
        enabled = $true
        field = [Parser.Node]::ROOT
        descr = 'Split the line into simple parts. and assign colors to each part'
        pattern = '(?<time>^\[[\w\d:/ ]+\])(?<message_type>[ ](\w+)[ ])(?<message>.*?$)'

        colors = [Parser.OrderedHash]{
            time = [ConsoleColor]::Magenta
            message_type = [ConsoleColor]::Green
            message = [ConsoleColor]::DarkBlue
        }

        # callback is optional, we need it to even further control the string.
        callback = $global:calback

        # Infinite nested rules.
        # each following rule should be mapped to a field from the previous match
        rules = @{
            enabled = $true
            field = 'time'
            name = 'splitText'
            descr = 'Parsing elemental lexemes.:)'
            pattern = '(\/)|(:)|(\[|\])'
            strategy = [RegexStrategy]::Split

            mapping = @{
                colon = '\:'
                backslash = '\/'
                squareBraces = '\[|\]'
                text = '^[^\/:\[\]]*$'
            }

            colors = @{
                text = [ConsoleColor]::Yellow
                backslash = [ConsoleColor]::Red
                squareBraces = [ConsoleColor]::DarkMagenta
                colon = [ConsoleColor]::White
            }

            callback = $this.rule001
        },
        @{
            enabled = $true
            field = 'message'
            descr = "Highlight errors"
            pattern = '(?<error>^.*?ERROR.*?$)'
            colors = @{
                error = [ConsoleColor]::DarkRed
            }
        },
```

[psgallery-badge]: https://img.shields.io/badge/PowerShell_Gallery-1.0.14-green.svg
[psgallery-status]: https://www.powershellgallery.com/packages/Parser/1.0.14
