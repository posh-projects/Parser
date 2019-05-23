using module Parser


class ParsingRules
{
    [Array]$rules = (
    @{
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
        #callback = global:onError(1, 2)
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
        @{
            enabled = $true
            field = 'message'
            descr = "Highlight infos"
            pattern = '(?<error>^.*?INFO.*?$)'
            colors = @{
                error = [ConsoleColor]::DarkYellow
            }
        },
        @{
            enabled = $true
            field = 'message_type'
            descr = "Highlight message type"
            pattern = '(?<type_highlightet>^.*?$)'
            colors = @{
                type_highlightet = [ConsoleColor]::DarkRed
            }
            callback = $this.rule002
        }
    })
    
    [void]rule001($node, $writer)
    {
        $writers = $node.prepareWriters($writer.invoke())
        
        foreach ($writer in $writers)
        {
            if ($writer.type -eq $node.rule.mapping.squareBraces)
            {
                $writer.writer.lpad().rpad()
            }
            
            if ($writer.type -eq $node.rule.mapping.text)
            {
                if ($writer.writer.__text -eq '00')
                {
                    $writer.writer.black().on().darkyellow()
                }
            }
            
            if ($writer.type -eq $node.rule.mapping.backslash)
            {
                $writer.writer.text('-')
            }
        }
        $node.enqueueWriters($writers)
    }
    
    [void]rule002($node, $writer)
    {
        $node.fields.type_highlightet = '{0, 9}' -f $node.fields.type_highlightet
        $node.setWriter('type_highlightet', $writer.invoke().on().white())
    }
}