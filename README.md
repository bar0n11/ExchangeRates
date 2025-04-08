# ExchangeRates


Currency Exchange Rate App Prototype

This is a prototype application that displays currency exchange rates based on the public API provided by the European Central Bank. Functionally, it allows the user to:
    •    View a list of available currencies
    •    Search by currency code or description
    •    Add currencies to the Home screen (favorites)
    •    Track exchange rates
    •    Remove currencies from Home screen (favorites)

The Home screen stores the user’s selected currencies locally between sessions. It automatically refreshes exchange rate data every 5 seconds and allows users to remove currencies from the list.

The server updates currency data once every 24 hours. Therefore, while the app fetches new data every 5 seconds, the exchange rates remain unchanged until the server data is updated. Once the rates change, the app calculates the percentage difference (delta) compared to the previous day’s rates.

You can use AssetsStore().mockPreviousDayAssets() to locally mock the previous day’s rates for CAD, EUR, and USD. The base currency is hardcoded as USD.

If the user selects only the base currency (USD) as a favorite, the server returns an error. In this case, the Home screen handles it gracefully by skipping the failed request and showing the last cached data instead.

The prototype is implemented following the MVVM architecture and includes unit tests for the two existing ViewModels responsible for the respective screens.



Assumption

Given the requirement to refresh exchange rates every 5 seconds on the Home screen, the ideal approach would be to use WebSockets. However, since public and free APIs like the ECB’s do not support WebSocket connections, this prototype uses a timer-based polling mechanism to repeatedly fetch data from the Latest Rates endpoint.



API

Frankfurter is a free, open-source currency data API that tracks reference exchange rates published by institutional and non-commercial sources like the European Central Bank. https://frankfurter.dev

1) Available currencies
Get supported currency symbols and their full names.

/* curl -s https://api.frankfurter.dev/v1/currencies */
{
  "AUD": "Australian Dollar",
  "BGN": "Bulgarian Lev",
  "BRL": "Brazilian Real",
  "CAD": "Canadian Dollar",
  "...": "..."
}

2) Latest Rates
Fetch the latest working day's rates, updated daily around 16:00 CET.
Limit the response to specific target currencies.

/* curl -s https://api.frankfurter.dev/v1/latest?symbols=CHF,GBP */
{
  "base": "EUR",
  "date": "2025-04-02",
  "rates": {
    "CHF": 0.9543,
    "GBP": 0.83455
  }
}

