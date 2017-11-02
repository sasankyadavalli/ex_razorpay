defmodule ExRazorpay.Payments do
  @moduledoc """
    Handles Razorpay payment requests like list all payments, fetch a payment, create a payment etc.
  """

  @key :ex_razorpay |> Application.fetch_env!(:key)
  @secret :ex_razorpay |> Application.fetch_env!(:secret)

  @doc """
  Retrieves list of payments based on optional parameters. 
  By default this returns recent 10 payments. 
    
  Optional parameters it supports are:
  * `from`: The timestamp in seconds after which the payments were created. Accepts only `timestamp (epoch)`
  * `to`:   The timestamp in seconds before which payments were created. Accepts only `timestamp (epoch)`
  * `count`: The number of payments to fetch. Accepts only `integer`
  * `skip`:  The number of payments to be skipped. Accepts only `integer`

  Returns `{:ok, results}` on success, else `{:error, reason}`

  ## Examples

      iex> ExRazorpay.Payments.list_payments([from: 1483438659, to: 1509493250, count: 1])
      {:ok,
        %{"count" => 1, "entity" => "collection",
          "items" => [%{"amount" => 50000, "amount_refunded" => 0, "bank" => nil,
          "captured" => true, "card_id" => "card_8vzYOiv7xQgMDQ",
          "contact" => "+917995738307", "created_at" => 1509493250,
          "currency" => "INR", "description" => "Purchase Description",
          "email" => "support@razorpay.com", "entity" => "payment",
          "error_code" => nil, "error_description" => nil, "fee" => 1250,
          "id" => "pay_8vzYOi5UjY2rmX", "international" => false,
          "invoice_id" => nil, "method" => "card", "notes" => [], "order_id" => nil,
          "refund_status" => nil, "status" => "captured", "tax" => 0, "vpa" => nil,
          "wallet" => nil}]}}

  """
  def list_payments(options \\ []) when is_list(options) do
    "https://api.razorpay.com/v1/payments"
    |> format_url(options)
    |> HTTPoison.get([], hackney: [basic_auth: {@key, @secret}])
    |> parse_response()
  end

  @doc """
  Retrieves a specific payment by `id`

  Returns `{:ok, result}` on success, else `{:error, reason}`

  ## Examples

      iex> ExRazorpay.Payments.fetch_payment("pay_8vzYOi5UjY2rmX")
      {:ok,
        %{"amount" => 50000, "amount_refunded" => 0, "bank" => nil, "captured" => true,
          "card_id" => "card_8vzYOiv7xQgMDQ", "contact" => "+917995738307",
          "created_at" => 1509493250, "currency" => "INR",
          "description" => "Purchase Description", "email" => "support@razorpay.com",
          "entity" => "payment", "error_code" => nil, "error_description" => nil,
          "fee" => 1250, "id" => "pay_8vzYOi5UjY2rmX", "international" => false,
          "invoice_id" => nil, "method" => "card", "notes" => [], "order_id" => nil,
          "refund_status" => nil, "status" => "captured", "tax" => 0, "vpa" => nil,
          "wallet" => nil}}
  """

  def fetch_payment(id) when is_binary(id) do
    "https://api.razorpay.com/v1/payments/#{id}"
    |> HTTPoison.get([], hackney: [basic_auth: {@key, @secret}])
    |> parse_response()
  end

  @doc """
  Captures a specific payment by `payment_id` and the amount(should be equal to the authorized amount, in paise) to be captured. 
  
  Returns `{:ok, result}` on success, else `{:error, reason}`

  ## Example

      iex> ExRazorpay.Payments.capture_payment("pay_8whI7Ub0O9YIjF", "50000")
      {:ok,
        %{"amount" => 50000, "amount_refunded" => 0, "bank" => nil, "captured" => true,
          "card" => %{"emi" => false, "entity" => "card",
          "id" => "card_8whI7VVaLFOImB", "international" => false,
          "issuer" => "SBIN", "last4" => "2882", "name" => "Y RAMESH",
          "network" => "Visa", "type" => "credit"},
          "card_id" => "card_8whI7VVaLFOImB", "contact" => "+917995738307",
          "created_at" => 1509647277, "currency" => "INR",
          "description" => "Purchase Description", "email" => "support@razorpay.com",
          "entity" => "payment", "error_code" => nil, "error_description" => nil,
          "fee" => 1250, "id" => "pay_8whI7Ub0O9YIjF", "international" => false,
          "invoice_id" => nil, "method" => "card", "notes" => [], "order_id" => nil,
          "refund_status" => nil, "status" => "captured", "tax" => 0, "vpa" => nil,
          "wallet" => nil}}
  """
  def capture_payment(payment_id, amount) when is_binary(payment_id) and is_binary(amount) do
    "https://api.razorpay.com/v1/payments/#{payment_id}/capture"
    |> HTTPoison.post({:form, [amount: amount]}, [], hackney: [basic_auth: {@key, @secret}])
    |> parse_response()
  end

  @doc """
    Refunds a specific payment by `payment_id` and the amount(In Paise) to be refunded.

    Returns `{:ok, result}` on success, else `{:error, reason}`

    ## Example

        iex> ExRazorpay.Payments.create_refund("pay_8wiNmKrlrzTi7D", "50000")
        {:ok,
          %{"amount" => 50000, "created_at" => 1509651274, "currency" => "INR",
            "entity" => "refund", "id" => "rfnd_8wiQVCxaC8lGza", "notes" => [],
            "payment_id" => "pay_8wiNmKrlrzTi7D", "receipt" => nil}}

  """
  def create_refund(payment_id, amount, notes \\ []) when is_binary(payment_id) do
    "https://api.razorpay.com/v1/payments/#{payment_id}/refund"
    |> HTTPoison.post({:form, [amount: amount]}, [], hackney: [basic_auth: {@key, @secret}])
    |> parse_response()
  end

  @doc """
    Retrieves list of refunds of a payment by `payment_id` and optional parameters
    By default this returns last 10 refunds.

  Optional parameters it supports are:
  * `from`: The timestamp in seconds after which the payments were created. Accepts only `timestamp (epoch)`
  * `to`:   The timestamp in seconds before which payments were created. Accepts only `timestamp (epoch)`
  * `count`: The number of payments to fetch. Accepts only `integer`
  * `skip`:  The number of payments to be skipped. Accepts only `integer`

  Returns `{:ok, results}` on success, else `{:error, reason}`

  ## Example

      iex> ExRazorpay.Payments.get_refunds("pay_8wiNmKrlrzTi7D")
      {:ok,
        %{"count" => 1, "entity" => "collection",
          "items" => [%{"amount" => 50000, "created_at" => 1509651274,
          "currency" => "INR", "entity" => "refund", "id" => "rfnd_8wiQVCxaC8lGza",
          "notes" => [], "payment_id" => "pay_8wiNmKrlrzTi7D", "receipt" => nil}]}}
  
  """
  def get_refunds(payment_id, options \\ []) when is_binary(payment_id) do
    "https://api.razorpay.com/v1/payments/#{payment_id}/refunds"
    |> format_url(options)
    |> HTTPoison.get([], hackney: [basic_auth: {@key, @secret}])
    |> parse_response()
  end

  @doc """
  Retrieves a specific refund of a specific payment by `payment_id` and `refund_id`

  Returns `{:ok, result}` on success, else `{:error, reason}`

  ## Example

      iex> ExRazorpay.Payments.get_refund("pay_8wiNmKrlrzTi7D", "rfnd_8wiQVCxaC8lGza")
      {:ok,
        %{"amount" => 50000, "created_at" => 1509651274, "currency" => "INR",
          "entity" => "refund", "id" => "rfnd_8wiQVCxaC8lGza", "notes" => [],
          "payment_id" => "pay_8wiNmKrlrzTi7D", "receipt" => nil}}
  
  """
  def get_refund(payment_id, refund_id) when is_binary(payment_id) and is_binary(refund_id)do
    "https://api.razorpay.com/v1/payments/#{payment_id}/refunds/#{refund_id}"
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
