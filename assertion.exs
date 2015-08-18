defmodule Assertion do
  defmacro assert({operator, _, [lhs, rhs]}) do
    quote bind_quoted: [operator: operator, lhs: lhs, rhs: rhs] do
      Assertion.Test.assert operator, lhs, rhs
    end
  end

  defmacro extend(option \\ []) do
    quote do
      import unquote __MODULE__

      def run do
        IO.puts "Running the tests..."
      end
    end
  end
end


defmodule Assertion.Test do
  def assert(:==, lhs, rhs) when lhs == rhs do
    IO.write "."
  end
  def assert(:==, lhs,  rhs) do
    IO.puts """
    FAILURE:
      Expected:       #{lhs}
      to be equal to: #{rhs}
    """
  end

  def assert(:>, lhs, rhs) when lhs > rhs do
    IO.write "."
  end
  def assert(:>, lhs, rhs) do
    IO.puts """
    FAILURE:
      Expected:       #{lhs}
      to be equal to: #{rhs}
    """
  end
end

###########################
### Test used my assertion
###########################

defmodule MathTest do
  require Assertion
  Assertion.extend

#  test "integraters can be added and subtraced" do
#    assert 1 + 1 == 2
#    assert 2 + 3 == 5
#    assert 5 - 5 == 10
#  end
#
#  test "integraters can be multiplied and divided" do
#    assert 5 * 5 == 25
#    assert 10 / 2 == 5
#  end
end
