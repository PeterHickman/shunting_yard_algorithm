#!/usr/bin/env ruby

class Shunt
  def process(input)
    stack = []
    queue = []

    while input.any?
      token = input.shift

      if is_operand(token)
        queue << token
      elsif is_operator(token)
        pre = operator_precedence(token)

        while stack.any? && pre <= operator_precedence(stack.last) && operator_associativity(token) == 'left'
          queue << stack.pop
        end

        stack << token
      elsif token == '('
        stack << token
      elsif token == ')'
        while stack.last != '('
          queue << stack.pop
        end

        stack.pop
      else
        raise "Do not know what to do with [#{token}]. Not an operator or operand or '(' or ')'"
      end
    end

    while stack.any?
      queue << stack.pop
    end

    queue
  end

  private

  def is_operand(token)
    ('A'..'Z').include?(token) || ('0'..'9').include?(token)
  end

  def is_operator(token)
    %w[+ - * / ^ < <= > >= = != && ||].include?(token)
  end

  def operator_precedence(token)
    case token
    when '(', ')'
      0
    when '^'
      13
    when '*', '/'
      12
    when '+', '-'
      11
    when '<', '<=', '>', '>='
      9
    when '=', '!='
      8
    when '&&'
      4
    when '||'
      3
    else
      raise "Precedence unknown for [#{token}]"
    end
  end

  def operator_associativity(token)
    case token
    when '(', ')'
      nil
    when '^'
      'right'
    when '*', '/'
      'left'
    when '+', '-'
      'left'
    when '<', '<=', '>', '>='
      'left'
    when '=', '!='
      'left'
    when '&&'
      'left'
    when '||'
      'left'
    else
      raise "Associativity unknown for [#{token}]"
    end
  end
end

def test(shunt, index, input, expected)
  actual = shunt.process(input.dup)

  if expected == actual
    puts "PASS ##{index}"

    1
  else
    puts "FAIL ##{index}"
    puts "     input ....: #{input.join('')}"
    puts "     expected .: #{expected.join('')}"
    puts "     got ......: #{actual.join('')}"

    0
  end
end

def run_tests
  s = Shunt.new

  tests = [
    [%w[A * B + C], %w[A B * C +]],
    [%w[A + B * C], %w[A B C * +]],
    [%w[A * ( B + C )], %w[A B C + *]],
    [%w[A - B + C], %w[A B - C +]],
    [%w[A * B ^ C + D], %w[A B C ^ * D +]],
    [%w[A * ( B + C * D ) + E], %w[A B C D * + * E +]],
    [%w[A + B * ( C ^ D - E ) ^ ( F + G * H ) - I], %w[A B C D ^ E - F G H * + ^ * + I -]],
    [%w[5 + 2 / ( 3 - 8 ) ^ 5 ^ 2], %w[5 2 3 8 - 5 2 ^ ^ / +]],
    [%w[3 + 4 * 2 / ( 1 - 5 ) ^ 2 ^ 3], %w[3 4 2 * 1 5 - 2 3 ^ ^ / +]]
  ]

  passes = 0
  tests.each_with_index do |t, i|
    passes += test(s, i+1, *t)
  end
  puts "Passed #{passes} of #{tests.size}"
end

run_tests
