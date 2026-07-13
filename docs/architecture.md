# UART Core Architecture

## Transmitter

```text
Parallel Data -> Start Bit -> Data Bits -> Stop Bit -> Serial Output
```

## Receiver

```text
Serial Input -> Start Detection -> Data Sampling -> Stop Bit -> Parallel Data
```

## Loopback

```text
TX Serial Output -> RX Serial Input
```

The loopback top module is used to verify that data transmitted by the UART TX module is correctly received by the UART RX module.
