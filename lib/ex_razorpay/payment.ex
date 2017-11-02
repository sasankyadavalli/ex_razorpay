defmodule ExRazorpay.Payments do
  @moduledoc """
    Handles Razorpay payment requests like list_payments, fetch_payment, create payment etc.
  """

  @key :ex_razorpay |> Application.fetch_env!(:key)
  @secret :ex_razorpay |> Application.fetch_env!(:secret)

  @doc """
  Retrives list of payments based on optional parameters. 
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

  def fetch_payment(id) when is_binary(id) do
    "https://api.razorpay.com/v1/payments/#{id}"
    |> HTTPoison.get([], hackney: [basic_auth: {@key, @secret}])
    |> parse_response()
  end

  def capture_payment(id, amount) when is_binary(id) and is_binary(amount) do
    "https://api.razorpay.com/v1/payments/#{id}/capture"
    |> HTTPoison.post({:form, [amount: amount]}, [], hackney: [basic_auth: {@key, @secret}])
    |> parse_response()
  end

  def create_refund(id, amount \\ [], notes \\ []) when is_binary(id) do
    "https://api.razorpay.com/v1/payments/#{id}/refund"
    |> HTTPoison.post({:form, [amount: amount]}, [], hackney: [basic_auth: {@key, @secret}])
    |> parse_response()
  end

  def get_refund(payment_id) when is_binary(payment_id) do
    "https://api.razorpay.com/v1/payments/#{payment_id}/refunds"
    |> HTTPoison.get([], hackney: [basic_auth: {@key, @secret}])
    |> parse_response()
  end

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
