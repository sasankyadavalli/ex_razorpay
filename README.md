# ExRazorpay

**TODO: Razorpay Payment Gateway API library for Elixir**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_razorpay` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_razorpay, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/ex_razorpay](https://hexdocs.pm/ex_razorpay).

## Configuration

```elixir
config :ex_razorpay, 
   key: "RAZORPAY_KEY_ID",
   secret: "RAZORPAY_KEY_SECRET"
```