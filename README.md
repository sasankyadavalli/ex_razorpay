# ExRazorpay

**Razorpay Payment Gateway API library for Elixir**

## Installation

The package can be installed by adding :ex_razorpay to your list of dependencies in mix.exs:

```elixir
def deps do
  [
    {:ex_razorpay, "~> 0.1.1"}
  ]
end
```
Docs can be found at [https://hexdocs.pm/ex_razorpay](https://hexdocs.pm/ex_razorpay).

## Configuration

```elixir
config :ex_razorpay, 
   key: "RAZORPAY_KEY_ID",
   secret: "RAZORPAY_KEY_SECRET"
```