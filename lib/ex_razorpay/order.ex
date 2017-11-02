defmodule ExRazorpay.Orders do
  @moduledoc """
    Handles Razorpay order requests like create an order, list all orders, get a specific order

    For more information on orders: https://docs.razorpay.com/v1/page/orders
  """

  @key :ex_razorpay |> Application.fetch_env!(:key)
  @secret :ex_razorpay |> Application.fetch_env!(:secret)

  @doc """
  Creates an Order in Razorpay.
  
  Required parameters to create an order are:
  * `amount`: Amount to be paid. Accepts only `string`
  * `currency`: Currency of the order. Currently only "INR" is supported. Accepts only `string`
  * `receipt`: Reference to the order in your local system. Accepts only `string`
  * `payment_capture`:  Payment to be captured. Accepts only `boolean`
  
  Returns `{:ok, result}` on success, else `{:error, reason}`

  ## Example

      iex> ExRazorpay.Orders.create_order("10000", "INR", "zap453", true)
      {:ok,
        %{"amount" => 10000, "amount_due" => 10000, "amount_paid" => 0,
          "attempts" => 0, "created_at" => 1509653304, "currency" => "INR",
          "entity" => "order", "id" => "order_8wj0ELqZUjWRTE", "notes" => [],
          "offer_id" => nil, "receipt" => "zap453", "status" => "created"}}


  """
  def create_order(amount, currency, receipt, payment_capture) do
    case payment_capture do
      true -> 
        create(amount, currency, receipt, 1)
      false ->
        create(amount, currency, receipt, 0)
    end
  end

  defp create(amount, currency, receipt, payment_capture) do
    "https://api.razorpay.com/v1/orders"
    |> HTTPoison.post({:form, [amount: amount, currency: currency,receipt: receipt, payment_capture: payment_capture]}, [], hackney: [basic_auth: {@key, @secret}])
    |> parse_response()
  end
  
  @doc """
  Retrieves list of all orders based on optional parameters.
  By default this returns last 10 orders.

  Optional parameters it supports are:
  * `from`: The timestamp in seconds after which the orders were created. Accepts only `timestamp (epoch)`
  * `to`:   The timestamp in seconds before which orders were created. Accepts only `timestamp (epoch)`
  * `count`: The number of orders to fetch. Accepts only `integer`
  * `skip`:  The number of orders to be skipped. Accepts only `integer`
  * `authorized`: Orders for which payments are currently in authorized state. Accepts only `1(true)` and `0(false)`
  * `receipt`: Reference to the order in your local system. Accepts only `string`

  Returns `{:ok, results}` on success, else `{:error, reason}`

  ## Example 

      iex> ExRazorpay.Orders.list_orders([count: 2])
      {:ok,
        %{"count" => 2, "entity" => "collection",
          "items" => [%{"amount" => 10000, "amount_due" => 10000, "amount_paid" => 0,
          "attempts" => 0, "created_at" => 1509653347, "currency" => "INR",
          "entity" => "order", "id" => "order_8wj0zlYP9sEA8Z", "notes" => [],
          "offer_id" => nil, "receipt" => "zap45", "status" => "created"},
        %{"amount" => 10000, "amount_due" => 10000, "amount_paid" => 0,
          "attempts" => 0, "created_at" => 1509653304, "currency" => "INR",
          "entity" => "order", "id" => "order_8wj0ELqZUjWRTE", "notes" => [],
          "offer_id" => nil, "receipt" => "zap453", "status" => "created"}]}}

  """
  def list_orders(options \\ []) do
    "https://api.razorpay.com/v1/orders"
    |> format_url(options)
    |> HTTPoison.get([], hackney: [basic_auth: {@key, @secret}])
    |> parse_response()
  end

  @doc """
  Retrieves an order by `order_id`
  
  Returns `{:ok, result}` on success, else `{:error, reason}`

  ## Example

      iex> ExRazorpay.Orders.get_order("order_73dgmoft2pWC9b")
      {:ok,
        %{"amount" => 6000, "amount_due" => 0, "amount_paid" => 6000, "attempts" => 1,
          "created_at" => 1484088799, "currency" => "INR", "entity" => "order",
          "id" => "order_73dgmoft2pWC9b", "notes" => [], "offer_id" => nil,
          "receipt" => "HkPkU1XIx", "status" => "paid"}}

  """
  def get_order(order_id) when is_binary(order_id) do
    "https://api.razorpay.com/v1/orders/#{order_id}"
    |> HTTPoison.get([], hackney: [basic_auth: {@key, @secret}])
    |> parse_response()
  end

  @doc """
  Retrieves list of payments of an order by `order_id`
  
  Returns `{:ok, result}` on success, else `{:error, reason}`

  ## Example 

      iex> ExRazorpay.Orders.fetch_payments("order_73dgmoft2pWC9b")
      {:ok,
        %{"count" => 1, "entity" => "collection",
          "items" => [%{"amount" => 6000, "amount_refunded" => 0, "bank" => nil,
          "captured" => true, "card_id" => "card_73e3HRCGtvtCW7",
          "contact" => "+917995738307", "created_at" => 1484090077,
          "currency" => "INR", "description" => "Test",
          "email" => "yadavallisasank@gmail.com", "entity" => "payment",
          "error_code" => nil, "error_description" => nil, "fee" => 173,
          "id" => "pay_73e3HQ3B2iRS6N", "international" => false,
          "invoice_id" => nil, "method" => "card", "notes" => [],
          "order_id" => "order_73dgmoft2pWC9b", "refund_status" => nil,
          "status" => "captured", "tax" => 23, "vpa" => nil, "wallet" => nil}]}}

  """
  def fetch_payments(order_id) when is_binary(order_id) do
    "https://api.razorpay.com/v1/orders/#{order_id}/payments"
    |> HTTPoison.get([], hackney: [basic_auth: {@key, @secret}])
    |> parse_response()
  end

  defp parse_response({:ok, %HTTPoison.Response{body: body, status_code: _status}}) do
    Poison.decode(body)
  end

  defp parse_response({:ok, %HTTPoison.Error{reason: reason}}) do
    {:error, reason}
  end

  defp format_url(url, options) when is_binary(url) do
    case options do
      [] ->
        url
      _ ->
        url <> "?" <> URI.encode_query(options)
    end
  end
end