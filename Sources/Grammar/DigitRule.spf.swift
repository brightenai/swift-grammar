
#if swift(>=5.7)
public
protocol DigitRule<Terminal, Construction>:TerminalRule where Construction:BinaryInteger
{    
    static 
    var radix:Construction 
    {
        get 
    }
}
#else 
public
protocol DigitRule:TerminalRule where Construction:BinaryInteger
{    
    static 
    var radix:Construction 
    {
        get 
    }
}
#endif 

extension Grammar 
{
    @available(*, deprecated, renamed: "UnicodeDigit.Natural")
    public 
    typealias   NaturalDecimalDigit<Location, Terminal, Construction> = 
                UnicodeDigit<Location, Terminal, Construction>.Natural
        where Terminal:BinaryInteger, Construction:BinaryInteger
    @available(*, deprecated, renamed: "UnicodeDigit.Decimal")
    public 
    typealias   DecimalDigit<Location, Terminal, Construction> = 
                UnicodeDigit<Location, Terminal, Construction>.Decimal
        where Terminal:BinaryInteger, Construction:BinaryInteger
    @available(*, deprecated, renamed: "UnicodeDigit.Hex")
    public 
    typealias   HexDigit<Location, Terminal, Construction> = 
                UnicodeDigit<Location, Terminal, Construction>.Hex
        where Terminal:BinaryInteger, Construction:BinaryInteger
    
    @available(*, deprecated, renamed: "UnicodeDigit.NaturalScalar")
    public 
    typealias   NaturalDecimalDigitScalar<Location, Construction> = 
                UnicodeDigit<Location, Unicode.Scalar, Construction>.NaturalScalar
        where Construction:BinaryInteger
    @available(*, deprecated, renamed: "UnicodeDigit.DecimalScalar")
    public 
    typealias   DecimalDigitScalar<Location, Construction> = 
                UnicodeDigit<Location, Unicode.Scalar, Construction>.DecimalScalar
        where Construction:BinaryInteger
    @available(*, deprecated, renamed: "UnicodeDigit.HexScalar")
    public 
    typealias   HexDigitScalar<Location, Construction> = 
                UnicodeDigit<Location, Unicode.Scalar, Construction>.HexScalar
        where Construction:BinaryInteger
}

extension Grammar 
{
    @frozen public
    struct IntegerOverflowError<T>:Error, CustomStringConvertible 
    {
        // don’t mark this @inlinable, since we generally don’t expect to 
        // recover from this
        public 
        init()
        {
        }
        public
        var description:String 
        {
            "parsed value overflows integer type '\(T.self)'"
        }
    }
    
    public
    typealias UnsignedIntegerLiteral<Digit> = UnsignedNormalizedIntegerLiteral<Digit, Digit>
    where Digit:DigitRule, Digit.Construction:FixedWidthInteger
    
    public
    enum UnsignedNormalizedIntegerLiteral<First, Next>:ParsingRule
    where   First:ParsingRule, Next:DigitRule, Next.Construction:FixedWidthInteger, 
            First.Construction == Next.Construction, 
            First.Location == Next.Location, 
            First.Terminal == Next.Terminal
    {
        public
        typealias Location = First.Location
        public
        typealias Terminal = First.Terminal
        
        @inlinable public static 
        func parse<Diagnostics>(_ input:inout ParsingInput<Diagnostics>) throws -> Next.Construction
        where   Diagnostics:ParsingDiagnostics, 
                Diagnostics.Source.Index == Location, 
                Diagnostics.Source.Element == Terminal
        {
            var value:Next.Construction = try input.parse(as: First.self)
            while let remainder:Next.Construction = input.parse(as: Next?.self)
            {
                guard   case (let shifted, false) = value.multipliedReportingOverflow(by: Next.radix), 
                        case (let refined, false) = shifted.addingReportingOverflow(remainder)
                else 
                {
                    throw IntegerOverflowError<Next.Construction>.init()
                }
                value = refined
            }
            return value
        }
    }
}
