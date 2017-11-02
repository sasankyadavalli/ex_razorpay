defmodule ExRazorpay.Orders do
  @moduledoc false

  @key :ex_razorpay |> Application.fetch_env!(:key)
  @secret :ex_razorpay |> Application.fetch_env!(:secret)

  def create(amount, currency, receipt, payment_capture, notes \\ []) do
    "https://api.razorpay.com/v1/orders"
    |> HTTPoison.post({:form, [amount: amount, currency: currency,receipt: receipt, payment_capture: payment_capture]}, [], hackney: [basic_auth: {@key, @secret}])
    |> parse_response()
  end

  def list_orders(options \\ []) do
    "https://api.razorpay.com/v1/orders"
    |> format_url(options)
    |> HTTPoison.get([], hackney: [basic_auth: {@key, @secret}])
    |> parse_response()
  end

  def get_order(id) when is_binary(id) do
    "https://api.razorpay.com/v1/orders/#{id}"
    |> HTTPoison.get([], hackney: [basic_auth: {@key, @secret}])
    |> parse_response()
  end

  def fetch_payments(id) when is_binary(id) do
    "https://api.razorpay.com/v1/orders/#{id}/payments"
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