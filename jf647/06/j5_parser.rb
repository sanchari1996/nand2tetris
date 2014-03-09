require 'rltk'

module JohnnyFive
    
    class Parser < RLTK::Parser

        p(:node) do
            c('COMMENT')                    { |_| Comment.new }
            c('command')                    { |c| c }
            c('')                           { Blank.new }
        end

        p(:command) do
            c('a_command')               { |a| a }
            c('c_command')               { |c| c }
        end
        
        p(:a_command) do
            # @12345
            c('AT NUMBER')          { |_,n| ACommand.new(n) }
        end
        
        p(:c_command) do
            # comp
            c('comp')                       { |c| CCommand.new(0b0, c.bits, 0b0) }
            # dest=comp
            c('dest ASSIGN comp')           { |d,_,c| CCommand.new(d.bits, c.bits, 0b0) }
            # comp;jump
            c('comp SEMI jump')             { |c,_,j| CCommand.new(0b0, c.bits, j.bits) }
            # dest=comp;jump
            c('dest ASSIGN comp SEMI jump') { |d,_,c,_,j| CCommand.new(d.bits, c.bits, j.bits) }
        end

        # refactor using enviroments to reduce the number of clauses
        p(:dest) do
            c('MREG')           { |_| Dest.new(0b001) }
            c('DREG')           { |_| Dest.new(0b010) }
            c('MREG DREG')      { |_,_| Dest.new(0b011) }
            c('AREG')           { |_| Dest.new(0b100) }
            c('AREG MREG')      { |_,_| Dest.new(0b101) }
            c('AREG DREG')      { |_,_| Dest.new(0b110) }
            c('AREG MREG DREG') { |_,_,_| Dest.new(0b111) }
        end

        # refactor using enviroments to reduce the number of clauses
        p(:comp) do
            # 0
            c('NUMBER') do |n|
                case n
                    when 0
                        Comp.new(0b0101010)
                    when 1
                        Comp.new(0b0111111)
                    else
                        nil
                end
            end
            # -1
            c('MINUS NUMBER')      { |_,_| Comp.new(0b0111010) }
            # D
            c('DREG')           { |_| Comp.new(0b0001100) }
            # A
            c('AREG')           { |_| Comp.new(0b0110000) }
            # !D
            c('NOT DREG')       { |_,_| Comp.new(0b0001101) }
            # !A
            c('NOT AREG')       { |_,_| Comp.new(0b0110001) }
            # -D
            c('MINUS DREG')     { |_,_| Comp.new(0b0001111) }
            # -A
            c('MINUS AREG')     { |_,_| Comp.new(0b0110011) }
            # D+1
            c('DREG PLUS NUMBER')  { |_,_,_| Comp.new(0b0011111) }
            # A+1
            c('AREG PLUS NUMBER')  { |_,_,_| Comp.new(0b0110111) }
            # D-1
            c('DREG MINUS NUMBER') { |_,_,_| Comp.new(0b0001110) }
            # A-1
            c('AREG MINUS NUMBER') { |_,_,_| Comp.new(0b0110010) }
            # D+A
            c('DREG PLUS AREG') { |_,_,_| Comp.new(0b0000010) }
            # D-A
            c('DREG MINUS AREG') { |_,_,_| Comp.new(0b0010011) }
            # A-D
            c('AREG MINUS DREG') { |_,_,_| Comp.new(0b0000111) }
            # D&A
            c('DREG AND AREG')  { |_,_,_| Comp.new(0b0000000) }
            # D|A
            c('DREG OR AREG')   { |_,_,_| Comp.new(0b0010101) }
            # M
            c('MREG')           { |_| Comp.new(0b1110000) }
            # !M
            c('NOT MREG')       { |_,_| Comp.new(0b1110001) }
            # -M
            c('MINUS MREG')     { |_,_| Comp.new(0b1110011) }
            # M+1
            c('MREG PLUS NUMBER')  { |_,_,_| Comp.new(0b1110111) }
            # M-1
            c('MREG MINUS NUMBER') { |_,_,_| Comp.new(0b1110010) }
            # D+M
            c('DREG PLUS MREG')  { |_,_,_| Comp.new(0b1000010) }
            # D-M
            c('DREG MINUS MREG') { |_,_,_| Comp.new(0b1010011) }
            # M-D
            c('MREG MINUS DREG') { |_,_,_| Comp.new(0b1000111) }
            # D&M
            c('DREG AND MREG')  { |_,_,_| Comp.new(0b1000000) }
            # D|M
            c('DREG OR MREG')   { |_,_,_| Comp.new(0b1010101) }
        end
        
        p(:jump) do
            c('JGT')            { |_| Jump.new(0b001) }
            c('JEQ')            { |_| Jump.new(0b010) }
            c('JGE')            { |_| Jump.new(0b011) }
            c('JLT')            { |_| Jump.new(0b100) }
            c('JNE')            { |_| Jump.new(0b101) }
            c('JLE')            { |_| Jump.new(0b110) }
            c('JMP')            { |_| Jump.new(0b111) }
        end
        
        finalize :explain => ENV.key?('EXPLAIN')
        
    end

end