using namespace System.Collections.Specialized


enum RegexStrategy
{
    Split
    Match
}


class Node
{
    static hidden [String]$ROOT = 'source'
    
    [OrderedDictionary]$writers = @{ }
    [Hashtable]$fields = @{ }
    [Hashtable]$rule
    [String]$line
    [Int]$lineLength
    [Int]$lineNumber
    
    Node([String]$field)
    {
        $this.line = $field
        $this.lineLength = $this.line.trim().length
        $this.fields[[Node]::ROOT] = $field
    }
    
    [Int]getWriterIndex($value)
    {
        $index = - $true
        foreach ($key in $this.writers.keys)
        {
            $index++
            if ($key -eq $value) { return $index }
        }
        return - $true
    }
    
    [Array]prepareWriters($writer)
    {
        [Array]$writersArray = @()
        
        [Array]$lexicalElements = $this.fields[$this.rule.name]
        
        [Int]$increment = $true
        
        foreach ($lexeme in $lexicalElements)
        {
            $colorKey = $this.rule.mapping.GetEnumerator() |
            Where-Object { $lexeme -match $_.value }
            
            [ConsoleColor]$color = ($this.rule.colors[$colorKey.key])
            
            $writersArray += @{
                id = $increment++
                type = $colorKey.value
                writer = $writer.newInstance().text($lexeme).color($color)
            }
        }
        return $writersArray
    }
    
    [Void]enqueueWriters($writersArray)
    {
        foreach ($writer in $writersArray)
        {
            $this.setWriter($writer.id, $writer.writer)
        }
    }
    
    [Void]setWriter([String]$key, $writer)
    {
        if ($this.rule.strategy -ne [RegexStrategy]::Split)
        {
            $writer = $writer.text($this.fields[$key]).color($this.rule.colors[$key])
        }
        
        $index = $this.writers.count
        $field = $this.rule.field
        
        if ($field -ne [Node]::ROOT)
        {
            $index = $this.getWriterIndex($field)
            $this.writers[$field].text($null)
        }
        
        $this.writers.insert($index, $key, $writer)
    }
}