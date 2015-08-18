defmodule Assertion do
  defmacro __using__(_options) do
    quote do
      import unquote(__MODULE__)

      # http://elixir-lang.org/docs/stable/elixir/Module.html#register_attribute/3
      Module.register_attribute __MODULE__, :tests, accumulate: true

      # http://elixir-lang.org/docs/stable/elixir/Module.html
      # @before_compile indicate MODULE have __before_compile__ method.
      @before_compile unquote(__MODULE__) # Assertion module
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def run, do: Assertion.Test.run(@tests, __MODULE__)
    end
  end

  defmacro test(description, do: test_block) do
    test_func = String.to_atom(description)
    quote do
      @tests {unquote(test_func), unquote(description)}
      def unquote(test_func)(), do: unquote(test_block)
    end
  end

  defmacro assert({operator, _, [lhs, rhs]}) do
    quote bind_quoted: [operator: operator, lhs: lhs, rhs: rhs] do
      Assertion.Test.assert operator, lhs, rhs
    end
  end
end

defmodule Assertion.Test do
  def run(tests, module) do
    pid = self()

    Enum.each tests, fn {test_func, description} ->
      spawn_link fn ->
        case apply(module, test_func, []) do
          :ok             ->
            send pid, IO.write "."
          {:fail, reason} ->
            send pid, IO.puts """
            ==================================
            FAILURE: #{description}
            ==================================
            #{reason}
            """
        end
      end
    end

  end

  def assert(:==, lhs, rhs) when lhs == rhs do
    :ok
  end
  def assert(:==, lhs,  rhs) do
    {:fail, """
      FAILURE:
        Expected:       #{lhs}
        to be equal to: #{rhs}
      """
    }
  end

  def assert(:>, lhs, rhs) when lhs > rhs do
    :ok
  end
  def assert(:>, lhs, rhs) do
    {:fail, """
      FAILURE:
        Expected:       #{lhs}
        to be equal to: #{rhs}
      """
    }
  end
end

###########################
### Test used my assertion
###########################

defmodule MathTest do
  use Assertion

  test "integraters can be added and subtraced" do
    assert 1 + 1 == 2
    assert 2 + 3 == 5
    assert 5 - 5 == 10
  end

  test "integraters can be multiplied and divided" do
    assert 5 * 5 == 25
    assert 10 / 2 == 5
  end
end
