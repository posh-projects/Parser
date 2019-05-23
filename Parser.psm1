#requires -Version 5.0

using module .\Src\Node.psm1


class Parser
{
    [Object]$output

    [Array]$text
    [Object]$rules
    [Int]$lineCounter

    [Object]writer() { return $this.output.newInstance() }

    [Node]applyRules([Node]$node, [Array]$rules)
    {
        $node.lineNumber = $this.lineCounter
        
        foreach ($rule in $rules)
        {
            [Hashtable]$matches = @{ }

            [String]$field = $node.fields[$rule.field]

            if (-not $rule.enabled -or -not $field) { continue }

            if ($rule.strategy -eq [RegexStrategy]::Split)
            {
                $matches[$rule.name] = [Regex]::Split($field, $rule.pattern)
            }
            elseif ($field -match $rule.pattern) { $matches.remove([Int]$false) }

            if ($matches.count)
            {
                $node.fields.remove($rule.field)

                $node.fields += $matches
                $node.rule = $rule

                if ($rule.callback) { $rule.callback.Invoke($node, $this.writer) }

                if (!$rule.callback -or $node.writers.Count -eq $false)
                {
                    $rule.colors.GetEnumerator() |
                    ForEach-Object { $node.setWriter($_.key, $this.writer()) }
                }

                if ($rule.rules) { $this.applyRules($node, $rule.rules) }
            }
        }
        return $node
    }

    static [Array]split($text) { return $text.Trim() -split [Environment]::NewLine }

    [Void]parse($plainText)
    {
        foreach ($line in $plainText)
        {
            $this.lineCounter++
            
            $node = $this.applyRules([Node]$line, $this.rules.rules)
            
            $node.writers.getEnumerator() |

            Select-Object -ExpandProperty Value -PipelineVariable writer |

            ForEach-Object { $writer.print() }

            $this.writer().cr()
        }
    }
}
