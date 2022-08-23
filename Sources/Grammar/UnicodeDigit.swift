/// A generic context for unicode digit rules.
public 
enum UnicodeDigit<Location, Terminal, Construction> where Construction:BinaryInteger 
{
}
extension UnicodeDigit where Terminal:BinaryInteger 
{
    public 
    enum Natural:TerminalRule where Construction:BinaryInteger
    {
        @inlinable public static 
        func parse(terminal:Terminal) -> Construction? 
        {
            guard 0x31 ... 0x39 ~= terminal 
            else 
            {
                return nil 
            }
            return .init(terminal - 0x30)
        }
    }
    public 
    enum Decimal:DigitRule where Construction:BinaryInteger
    {
        @inlinable public static 
        var radix:Construction 
        {
            10
        }
        @inlinable public static 
        func parse(terminal:Terminal) -> Construction? 
        {
            guard 0x30 ... 0x39 ~= terminal 
            else 
            {
                return nil 
            }
            return .init(terminal - 0x30)
        }
    }
    public 
    enum Hex:DigitRule where Construction:BinaryInteger 
    {
        @inlinable public static 
        var radix:Construction 
        {
            16
        }
        @inlinable public static 
        func parse(terminal:Terminal) -> Construction?
        {
            switch terminal 
            {
            case 0x30 ... 0x39: return Construction.init(terminal - 0x30)
            case 0x61 ... 0x66: return Construction.init(terminal +   10 - 0x61)
            case 0x41 ... 0x46: return Construction.init(terminal +   10 - 0x41)
            default:            return nil
            }
        }
        
        public 
        enum Lowercase:DigitRule
        {
            @inlinable public static 
            var radix:Construction 
            {
                16
            }
            @inlinable public static 
            func parse(terminal:Terminal) -> Construction?
            {
                switch terminal 
                {
                case 0x30 ... 0x39: return Construction.init(terminal - 0x30)
                case 0x61 ... 0x66: return Construction.init(terminal +   10 - 0x61)
                default:            return nil
                }
            }
        }
    }
}
extension UnicodeDigit where Terminal == Unicode.Scalar 
{
    public 
    enum NaturalScalar:TerminalRule 
    {
        public 
        typealias Terminal = Unicode.Scalar 
        
        @inlinable public static 
        func parse(terminal:Unicode.Scalar) -> Construction?
        {
            "1" ... "9" ~= terminal ? 
                Construction.init(terminal.value - ("0" as Unicode.Scalar).value) : nil
        }
    }
    public 
    enum DecimalScalar:DigitRule 
    {
        public 
        typealias Terminal = Unicode.Scalar 
        
        @inlinable public static 
        var radix:Construction 
        {
            10
        }
        @inlinable public static 
        func parse(terminal:Unicode.Scalar) -> Construction?
        {
            "0" ... "9" ~= terminal ? 
                Construction.init(terminal.value - ("0" as Unicode.Scalar).value) : nil
        }
    }
    public 
    enum HexScalar:DigitRule 
    {
        public 
        typealias Terminal = Unicode.Scalar 
        
        @inlinable public static 
        var radix:Construction 
        {
            16
        }
        @inlinable public static 
        func parse(terminal:Unicode.Scalar) -> Construction?
        {
            switch terminal 
            {
            case "0" ... "9":
                return Construction.init(terminal.value      - ("0" as Unicode.Scalar).value)
            case "a" ... "f":
                return Construction.init(terminal.value + 10 - ("a" as Unicode.Scalar).value)
            case "A" ... "F":
                return Construction.init(terminal.value + 10 - ("A" as Unicode.Scalar).value)
            default:
                return nil
            }
        }
        
        public 
        enum Lowercase:DigitRule
        {
            public 
            typealias Terminal = Unicode.Scalar 
            
            @inlinable public static 
            var radix:Construction 
            {
                16
            }
            @inlinable public static 
            func parse(terminal:Unicode.Scalar) -> Construction?
            {
                switch terminal 
                {
                case "0" ... "9":
                    return Construction.init(terminal.value      - ("0" as Unicode.Scalar).value)
                case "a" ... "f":
                    return Construction.init(terminal.value + 10 - ("a" as Unicode.Scalar).value)
                default:
                    return nil
                }
            }
        }
    }
}