use Mix.Config

config :ex_razorpay,
  key: System.get_env("RAZORPAY_KEY_ID"),
  secret: System.get_env("RAZORPAY_KEY_SECRET")