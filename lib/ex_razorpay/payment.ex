defmodule ExRazorpay.Payments do
  @moduledoc false

  @key :ex_razorpay |> Application.fetch_env!(:key)
  @secret :ex_razorpay |> Application.fetch_env!(:secret)

  def list_payments(options \\ []) when is_list(options) do
    "https://api.razorpay.com/v1/payments"
    |> format_url(options)
    |> HTTPoison.get([], hackney: [basic_auth: {@key, @secret}])
    |> parse_response()
  end

  def get_payment(id) when is_binary(id) do
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
